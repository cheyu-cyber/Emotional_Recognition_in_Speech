"""main.py — orchestrate the emotion-recognition pipeline.

Pipeline per feature set in {mfcc, lpc, lpcc, combined}:
    1. Extract per-frame features for every audio file.
    2. For each classifier in cfg["experiments"]["classifiers"]:
        - discrete_hmm: fit VQ codebook on training features -> encode all
                        utterances to symbol sequences -> train one
                        DiscreteHMM per emotion class.
        - gmm_hmm:      train one GMM-HMM per emotion class directly on
                        the continuous feature sequences (no VQ).
    3. Score every test utterance under every model; argmax wins.
    4. Compute accuracy + confusion matrix; save plots and JSON results.

Run with:
    python main.py
Configuration lives in config.json (resolved relative to the project root,
no argparse).
"""
from __future__ import annotations

import sys
import time
from collections import Counter
from pathlib import Path
from typing import Dict, List, Tuple, cast

import numpy as np


def _bootstrap_project_root() -> Path:
    """Walk up from this file to find the dir containing core/ and utils/.

    Lets ``python main.py`` work regardless of CWD, and also keeps working
    if main.py is moved into a subdirectory of the project.
    """
    here = Path(__file__).resolve().parent
    for cand in (here, *here.parents):
        if (cand / "core").is_dir() and (cand / "utils").is_dir():
            if str(cand) not in sys.path:
                sys.path.insert(0, str(cand))
            return cand
    raise RuntimeError(f"Could not locate `core/` and `utils/` near {here}")


PROJECT_ROOT = _bootstrap_project_root()

# Importing the packages triggers each __init__.py to add its own directory
# to sys.path, so the flat imports below resolve against the right modules.
import core  # noqa: F401, E402
import utils as _utils_pkg  # noqa: F401, E402

from sklearn.metrics import accuracy_score, classification_report  # noqa: E402
from tqdm import tqdm  # noqa: E402

# Local modules
from utils import (  # noqa: E402
    ensure_dirs,
    load_config,
    save_json,
    save_pickle,
    setup_logging,
    timed,
)
from dataset import AudioItem, load_dataset, split_train_test  # noqa: E402
from mfcc import extract_mfcc  # noqa: E402
from lpc import extract_lpc  # noqa: E402
from lpcc import extract_lpcc  # noqa: E402
from prosodic import extract_prosodic  # noqa: E402
from vq import VectorQuantizer  # noqa: E402
from hmm_classifier import EmotionHMMClassifier  # noqa: E402
from gmm_hmm_classifier import EmotionGMMHMMClassifier  # noqa: E402
from visualize import (  # noqa: E402
    plot_accuracy_bar,
    plot_codebook_usage,
    plot_confusion_matrix,
    plot_feature_distribution,
)


# -------- feature dispatch --------------------------------------------------- #

def extract_features_for_set(
    item: AudioItem, feature_set: str, cfg: Dict
) -> np.ndarray:
    """Extract the right kind of per-frame features for one utterance."""
    fr = cfg["framing"]
    sr = item.sample_rate
    y = item.audio

    if feature_set == "mfcc":
        c = cfg["mfcc"]
        return extract_mfcc(
            y,
            sr,
            n_mfcc=c["n_mfcc"],
            n_mels=c["n_mels"],
            n_fft=c["n_fft"],
            fmin=c["fmin"],
            fmax=c["fmax"],
            frame_length_ms=fr["frame_length_ms"],
            hop_length_ms=fr["hop_length_ms"],
            preemphasis_coeff=fr["preemphasis"],
            window=fr["window"],
            include_deltas=c["include_deltas"],
            include_delta_deltas=c["include_delta_deltas"],
            include_log_energy=c["include_log_energy"],
            apply_cmvn=c["cmvn"],
        )

    if feature_set == "lpc":
        c = cfg["lpc"]
        return extract_lpc(
            y,
            sr,
            order=c["order"],
            frame_length_ms=fr["frame_length_ms"],
            hop_length_ms=fr["hop_length_ms"],
            preemphasis_coeff=fr["preemphasis"],
            window=fr["window"],
            include_error_energy=c["include_error_energy"],
        )

    if feature_set == "lpcc":
        c = cfg["lpcc"]
        return extract_lpcc(
            y,
            sr,
            lpc_order=c["lpc_order"],
            n_cepstral=c["n_cepstral"],
            frame_length_ms=fr["frame_length_ms"],
            hop_length_ms=fr["hop_length_ms"],
            preemphasis_coeff=fr["preemphasis"],
            window=fr["window"],
            include_deltas=c["include_deltas"],
        )

    if feature_set == "combined":
        # Spectral + prosodic, all aligned by the same framing config
        feats_mfcc = extract_features_for_set(item, "mfcc", cfg)
        feats_lpcc = extract_features_for_set(item, "lpcc", cfg)
        p = cfg["prosodic"]
        feats_pros = extract_prosodic(
            y,
            sr,
            pitch_fmin=p["pitch_fmin"],
            pitch_fmax=p["pitch_fmax"],
            voicing_threshold=p["voicing_threshold"],
            frame_length_ms=fr["frame_length_ms"],
            hop_length_ms=fr["hop_length_ms"],
            preemphasis_coeff=0.0,
            window=fr["window"],
        )
        # Align frame counts (numerical edge effects can cause off-by-one)
        T = min(feats_mfcc.shape[0], feats_lpcc.shape[0], feats_pros.shape[0])
        return np.concatenate(
            [feats_mfcc[:T], feats_lpcc[:T], feats_pros[:T]], axis=1
        )

    raise ValueError(f"Unknown feature set: {feature_set}")


def extract_all(
    items: List[AudioItem], feature_set: str, cfg: Dict, logger
) -> List[np.ndarray]:
    feats: List[np.ndarray] = []
    for it in tqdm(items, desc=f"Extract [{feature_set}]", leave=False):
        feats.append(extract_features_for_set(it, feature_set, cfg))
    dims = {f.shape[1] for f in feats if f.shape[0] > 0}
    logger.info(
        "Extracted %s for %d items (feature dims: %s, mean frames: %.1f)",
        feature_set,
        len(feats),
        dims,
        float(np.mean([f.shape[0] for f in feats])) if feats else 0.0,
    )
    return feats


# -------- experiment loop ---------------------------------------------------- #

def _evaluate_predictions(
    test_labels: List[str],
    preds: List[str],
    classes: List[str],
    plots_dir: Path,
    feature_set: str,
    classifier: str,
    logger,
) -> Dict:
    """Common scoring + confusion-matrix block, shared by both classifiers."""
    acc = accuracy_score(test_labels, preds)
    logger.info("[%s | %s] test accuracy: %.4f", feature_set, classifier, acc)
    rep = cast(
        Dict,
        classification_report(
            test_labels, preds, labels=classes, zero_division=0, output_dict=True
        ),
    )
    logger.info(
        "[%s | %s] per-class F1: %s",
        feature_set,
        classifier,
        {c: round(rep[c]["f1-score"], 3) for c in classes if c in rep},
    )
    cm_path = plots_dir / f"confusion_matrix_{classifier}.png"
    plot_confusion_matrix(
        test_labels,
        preds,
        classes=classes,
        title=f"{feature_set.upper()} | {classifier} — accuracy {acc:.2%}",
        out_path=str(cm_path),
        normalize=True,
    )
    return {
        "accuracy": acc,
        "classes": classes,
        "per_class_report": rep,
        "confusion_plot": str(cm_path),
    }


def _run_discrete_hmm(
    feature_set: str,
    train_feats: List[np.ndarray],
    test_feats: List[np.ndarray],
    train_labels: List[str],
    test_labels: List[str],
    cfg: Dict,
    plots_dir: Path,
    logger,
) -> Dict:
    """VQ -> Discrete HMM per class."""
    train_stack = np.concatenate([f for f in train_feats if f.shape[0] > 0], axis=0)

    vq = VectorQuantizer(
        n_clusters=cfg["vq"]["n_clusters"],
        random_seed=cfg["vq"]["random_seed"],
        n_init=cfg["vq"]["n_init"],
    )
    with timed(f"{feature_set} | discrete_hmm: VQ fit", logger):
        vq.fit(train_stack)

    train_seqs = vq.encode_all(train_feats)
    test_seqs = vq.encode_all(test_feats)

    plot_codebook_usage(
        train_seqs,
        train_labels,
        n_clusters=cfg["vq"]["n_clusters"],
        out_path=plots_dir / "codebook_usage_train.png",
        title=f"Codebook usage by class (train) — {feature_set}",
    )

    clf = EmotionHMMClassifier(
        n_states=cfg["hmm"]["n_states"],
        n_symbols=cfg["vq"]["n_clusters"],
        n_iter=cfg["hmm"]["n_iter"],
        tol=cfg["hmm"]["tol"],
        random_seed=cfg["hmm"]["random_seed"],
    )
    with timed(
        f"{feature_set} | discrete_hmm: training ({len(set(train_labels))} models)",
        logger,
    ):
        clf.fit(train_seqs, train_labels)
    with timed(f"{feature_set} | discrete_hmm: scoring", logger):
        preds, _ = clf.predict(test_seqs)

    return _evaluate_predictions(
        test_labels,
        preds,
        clf.classes_,
        plots_dir=plots_dir,
        feature_set=feature_set,
        classifier="discrete_hmm",
        logger=logger,
    )


def _run_gmm_hmm(
    feature_set: str,
    train_feats: List[np.ndarray],
    test_feats: List[np.ndarray],
    train_labels: List[str],
    test_labels: List[str],
    cfg: Dict,
    plots_dir: Path,
    logger,
) -> Dict:
    """Continuous-density HMM directly on features (no VQ)."""
    g = cfg["gmm_hmm"]
    clf = EmotionGMMHMMClassifier(
        n_states=g["n_states"],
        n_mix=g["n_mix"],
        n_iter=g["n_iter"],
        tol=g["tol"],
        var_floor=g["var_floor"],
        weight_floor=g["weight_floor"],
        random_seed=g["random_seed"],
    )
    with timed(
        f"{feature_set} | gmm_hmm: training "
        f"({len(set(train_labels))} models, K={g['n_states']}, M={g['n_mix']})",
        logger,
    ):
        clf.fit(train_feats, train_labels)
    with timed(f"{feature_set} | gmm_hmm: scoring", logger):
        preds, _ = clf.predict(test_feats)

    iters = [m.n_iter_run_ for m in clf.models.values()]
    if iters:
        logger.info(
            "[%s | gmm_hmm] EM iterations per class — min %d, mean %.1f, max %d",
            feature_set,
            min(iters),
            float(np.mean(iters)),
            max(iters),
        )

    return _evaluate_predictions(
        test_labels,
        preds,
        clf.classes_,
        plots_dir=plots_dir,
        feature_set=feature_set,
        classifier="gmm_hmm",
        logger=logger,
    )


_CLASSIFIER_DISPATCH = {
    "discrete_hmm": _run_discrete_hmm,
    "gmm_hmm": _run_gmm_hmm,
}


def run_one_experiment(
    feature_set: str,
    train_items: List[AudioItem],
    test_items: List[AudioItem],
    cfg: Dict,
    logger,
) -> Dict:
    """Run all configured classifiers on one feature set."""
    out: Dict = {"feature_set": feature_set, "by_classifier": {}}

    plots_dir = Path(cfg["output"]["plots_dir"]) / feature_set
    ensure_dirs(plots_dir)

    with timed(f"{feature_set}: feature extraction", logger):
        train_feats = extract_all(train_items, feature_set, cfg, logger)
        test_feats = extract_all(test_items, feature_set, cfg, logger)

    valid = [f for f in train_feats if f.shape[0] > 0]
    if not valid:
        logger.error("No training frames for %s; skipping.", feature_set)
        return {"feature_set": feature_set, "error": "no training frames"}
    train_stack = np.concatenate(valid, axis=0)
    logger.info("[%s] training feature stack: %s", feature_set, train_stack.shape)

    train_labels = [it.label for it in train_items]
    test_labels = [it.label for it in test_items]

    # Shared sanity-check plot (per-utterance feature means by class)
    if train_stack.shape[1] > 0:
        per_utt_means = np.array(
            [f.mean(axis=0) for f in train_feats if f.shape[0] > 0]
        )
        per_utt_labels = [
            it.label for it, f in zip(train_items, train_feats) if f.shape[0] > 0
        ]
        plot_feature_distribution(
            per_utt_means,
            per_utt_labels,
            out_path=str(plots_dir / "feature_distribution.png"),
            title=f"Per-utterance feature means — {feature_set}",
        )

    for classifier in cfg["experiments"]["classifiers"]:
        runner = _CLASSIFIER_DISPATCH.get(classifier)
        if runner is None:
            logger.warning("Unknown classifier '%s'; skipping.", classifier)
            continue
        try:
            res = runner(
                feature_set,
                train_feats,
                test_feats,
                train_labels,
                test_labels,
                cfg,
                plots_dir,
                logger,
            )
            res["n_train"] = len(train_items)
            res["n_test"] = len(test_items)
            res["feature_dim"] = int(train_stack.shape[1])
            out["by_classifier"][classifier] = res
        except Exception as e:
            logger.exception("[%s | %s] failed: %s", feature_set, classifier, e)
            out["by_classifier"][classifier] = {"error": str(e)}

    return out


# -------- main --------------------------------------------------------------- #

def _resolve_config(name: str) -> Path:
    """Find the config file regardless of CWD.

    Order: absolute path -> CWD -> project root -> utils/.
    """
    p = Path(name)
    if p.is_absolute():
        return p
    for cand in (Path.cwd() / p, PROJECT_ROOT / p, PROJECT_ROOT / "utils" / p):
        if cand.exists():
            return cand
    raise FileNotFoundError(
        f"Could not find {name}; looked in CWD, {PROJECT_ROOT}, "
        f"and {PROJECT_ROOT / 'utils'}"
    )


def main(config_path: str = "config.json") -> int:
    cfg_path = _resolve_config(config_path)
    cfg = load_config(cfg_path)
    out_cfg = cfg["output"]
    ensure_dirs(out_cfg["log_dir"], out_cfg["results_dir"], out_cfg["plots_dir"])

    logger = setup_logging(out_cfg["log_dir"])
    logger.info("Config loaded from %s", cfg_path)
    logger.info("Feature sets to evaluate: %s", cfg["experiments"]["feature_sets"])
    logger.info("Classifiers to evaluate: %s", cfg["experiments"]["classifiers"])

    # ---- dataset ---- #
    ds_cfg = cfg["dataset"]
    with timed("dataset load", logger):
        items = load_dataset(
            ds_cfg["path"],
            sample_rate=ds_cfg["sample_rate"],
            emotions=ds_cfg["emotions"],
            max_files_per_class=ds_cfg["max_files_per_class"],
            trim_silence=ds_cfg["trim_silence"],
            trim_top_db=ds_cfg["trim_top_db"],
            random_seed=ds_cfg["random_seed"],
            logger=logger,
        )
    if len(items) < 10:
        logger.error("Loaded only %d items — too few to train HMMs.", len(items))
        return 2

    train_items, test_items = split_train_test(
        items,
        test_size=ds_cfg["test_size"],
        speaker_independent=ds_cfg["speaker_independent"],
        random_seed=ds_cfg["random_seed"],
        logger=logger,
    )

    # ---- experiments ---- #
    summary: Dict[str, float] = {}             # flat: "feature/classifier" -> acc
    summary_by_clf: Dict[str, Dict[str, float]] = {}  # nested
    all_results: List[Dict] = []
    for fs in cfg["experiments"]["feature_sets"]:
        try:
            result = run_one_experiment(fs, train_items, test_items, cfg, logger)
        except Exception as e:
            logger.exception("Experiment %s failed: %s", fs, e)
            result = {"feature_set": fs, "error": str(e)}
        all_results.append(result)
        for clf_name, clf_res in result.get("by_classifier", {}).items():
            if "accuracy" in clf_res:
                summary[f"{fs}/{clf_name}"] = clf_res["accuracy"]
                summary_by_clf.setdefault(clf_name, {})[fs] = clf_res["accuracy"]

    # ---- comparative summary ---- #
    if summary:
        for clf_name, accs in summary_by_clf.items():
            plot_accuracy_bar(
                accs,
                out_path=str(
                    Path(out_cfg["plots_dir"]) / f"accuracy_{clf_name}.png"
                ),
                title=f"Test accuracy by feature set — {clf_name}",
            )
        plot_accuracy_bar(
            summary,
            out_path=str(Path(out_cfg["plots_dir"]) / "accuracy_comparison.png"),
            title="Test accuracy: feature × classifier",
        )
        logger.info("=== FINAL ACCURACY SUMMARY ===")
        for k, v in sorted(summary.items(), key=lambda kv: -kv[1]):
            logger.info("  %-25s : %.4f", k, v)

    save_json(
        {
            "summary": summary,
            "summary_by_classifier": summary_by_clf,
            "results": all_results,
            "config": cfg,
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S"),
        },
        Path(out_cfg["results_dir"]) / "results.json",
    )
    logger.info("Wrote results to %s", Path(out_cfg["results_dir"]) / "results.json")
    return 0


if __name__ == "__main__":
    sys.exit(main("config.json"))
