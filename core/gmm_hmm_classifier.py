"""gmm_hmm_classifier.py — one GMM-HMM per emotion class.

Mirrors the public interface of `hmm_classifier.EmotionHMMClassifier`,
so `main.py` can swap classifiers without any other code changes.
The key behavioural difference: this classifier consumes **continuous**
feature sequences (T, D) and skips the VQ codebook entirely.
"""
from __future__ import annotations

from typing import Dict, List, Tuple

import numpy as np

from gmm_hmm import GMMHMM


class EmotionGMMHMMClassifier:
    def __init__(
        self,
        n_states: int = 3,
        n_mix: int = 4,
        n_iter: int = 30,
        tol: float = 1e-4,
        var_floor: float = 1e-3,
        weight_floor: float = 1e-3,
        random_seed: int = 42,
    ):
        self.n_states = n_states
        self.n_mix = n_mix
        self.n_iter = n_iter
        self.tol = tol
        self.var_floor = var_floor
        self.weight_floor = weight_floor
        self.random_seed = random_seed
        self.models: Dict[str, GMMHMM] = {}
        self.classes_: List[str] = []

    def _new_model(self) -> GMMHMM:
        return GMMHMM(
            n_states=self.n_states,
            n_mix=self.n_mix,
            n_iter=self.n_iter,
            tol=self.tol,
            var_floor=self.var_floor,
            weight_floor=self.weight_floor,
            random_state=self.random_seed,
        )

    def fit(
        self, sequences: List[np.ndarray], labels: List[str]
    ) -> "EmotionGMMHMMClassifier":
        """Train one GMM-HMM per unique label."""
        if len(sequences) != len(labels):
            raise ValueError("sequences and labels must be the same length")
        self.classes_ = sorted(set(labels))
        for c in self.classes_:
            seqs = [
                np.asarray(s, dtype=np.float64)
                for s, lab in zip(sequences, labels)
                if lab == c and len(s) > 0
            ]
            if not seqs:
                continue
            model = self._new_model()
            model.fit(seqs)
            self.models[c] = model
        return self

    def predict_one(self, sequence: np.ndarray) -> Tuple[str, Dict[str, float]]:
        """Return (predicted_label, {class: log_likelihood})."""
        scores: Dict[str, float] = {}
        seq = np.asarray(sequence, dtype=np.float64)
        for c, m in self.models.items():
            try:
                scores[c] = float(m.score(seq))
            except Exception:
                scores[c] = -np.inf
        if not scores:
            return ("unknown", scores)
        pred = max(scores, key=scores.get)
        return pred, scores

    def predict(
        self, sequences: List[np.ndarray]
    ) -> Tuple[List[str], List[Dict[str, float]]]:
        preds, all_scores = [], []
        for s in sequences:
            p, sc = self.predict_one(s)
            preds.append(p)
            all_scores.append(sc)
        return preds, all_scores
