"""visualize.py — confusion matrices, per-class accuracy, codebook plots."""
from __future__ import annotations

from pathlib import Path
from typing import Dict, List, Sequence

import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from sklearn.metrics import confusion_matrix


# Use a clean, publication-friendly default style
sns.set_theme(style="whitegrid", context="notebook")


def plot_confusion_matrix(
    y_true: Sequence[str],
    y_pred: Sequence[str],
    classes: Sequence[str],
    title: str,
    out_path: str,
    normalize: bool = True,
) -> None:
    cm = confusion_matrix(y_true, y_pred, labels=list(classes))
    if normalize:
        row_sums = cm.sum(axis=1, keepdims=True)
        with np.errstate(divide="ignore", invalid="ignore"):
            cm_norm = np.where(row_sums > 0, cm / row_sums, 0.0)
        data = cm_norm
        fmt = ".2f"
    else:
        data = cm
        fmt = "d"

    fig, ax = plt.subplots(figsize=(1.2 * len(classes) + 2, 1.0 * len(classes) + 1.5))
    sns.heatmap(
        data,
        annot=True,
        fmt=fmt,
        cmap="Blues",
        xticklabels=classes,
        yticklabels=classes,
        vmin=0,
        vmax=1 if normalize else None,
        ax=ax,
        cbar=True,
    )
    ax.set_xlabel("Predicted")
    ax.set_ylabel("True")
    ax.set_title(title)
    plt.tight_layout()
    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(out_path, dpi=150)
    plt.close(fig)


def plot_accuracy_bar(
    results: Dict[str, float],
    out_path: str,
    title: str = "Recognition accuracy by feature set",
) -> None:
    names = list(results.keys())
    vals = [results[k] for k in names]

    fig, ax = plt.subplots(figsize=(6, 4))
    bars = ax.bar(names, vals, color=sns.color_palette("deep", len(names)))
    ax.set_ylim(0, 1.0)
    ax.set_ylabel("Accuracy")
    ax.set_title(title)
    for b, v in zip(bars, vals):
        ax.text(
            b.get_x() + b.get_width() / 2,
            v + 0.01,
            f"{v:.2f}",
            ha="center",
            va="bottom",
            fontweight="bold",
        )
    plt.tight_layout()
    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(out_path, dpi=150)
    plt.close(fig)


def plot_feature_distribution(
    features: np.ndarray,
    labels: List[str],
    out_path: str,
    title: str,
    max_dims: int = 6,
) -> None:
    """Box-plot the first `max_dims` dimensions split by class."""
    if features.size == 0:
        return
    D = min(max_dims, features.shape[1])
    fig, axes = plt.subplots(1, D, figsize=(2.5 * D, 3.5), sharey=False)
    if D == 1:
        axes = [axes]
    classes = sorted(set(labels))
    palette = sns.color_palette("deep", len(classes))
    color_map = {c: palette[i] for i, c in enumerate(classes)}

    for d, ax in enumerate(axes):
        data_by_class = [features[np.array(labels) == c, d] for c in classes]
        ax.boxplot(data_by_class, labels=classes, showfliers=False)
        ax.set_title(f"dim {d}")
        ax.tick_params(axis="x", rotation=30)

    fig.suptitle(title)
    plt.tight_layout()
    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(out_path, dpi=150)
    plt.close(fig)


def plot_codebook_usage(
    sequences: List[np.ndarray],
    labels: List[str],
    n_clusters: int,
    out_path: str,
    title: str,
) -> None:
    """Stacked bar chart of how each class uses the codewords."""
    classes = sorted(set(labels))
    counts = np.zeros((len(classes), n_clusters))
    for seq, lab in zip(sequences, labels):
        if lab not in classes:
            continue
        i = classes.index(lab)
        for s in seq:
            counts[i, int(s)] += 1
    # Normalise per class
    row_sums = counts.sum(axis=1, keepdims=True)
    with np.errstate(divide="ignore", invalid="ignore"):
        counts = np.where(row_sums > 0, counts / row_sums, 0.0)

    fig, ax = plt.subplots(figsize=(8, 4))
    x = np.arange(n_clusters)
    bottom = np.zeros(n_clusters)
    palette = sns.color_palette("deep", len(classes))
    for i, c in enumerate(classes):
        ax.bar(x, counts[i], bottom=bottom, label=c, color=palette[i])
        bottom += counts[i]
    ax.set_xlabel("Codeword index")
    ax.set_ylabel("Per-class proportion")
    ax.set_title(title)
    ax.legend(loc="upper right", fontsize=8)
    plt.tight_layout()
    Path(out_path).parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(out_path, dpi=150)
    plt.close(fig)
