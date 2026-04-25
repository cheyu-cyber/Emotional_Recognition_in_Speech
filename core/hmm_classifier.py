"""hmm_classifier.py — one discrete HMM per emotion class.

Each class trains its own HMM (from `hmm.py`, no external HMM library)
on its VQ-encoded observation sequences. At test time, every model
scores the test sequence under log-likelihood and the argmax wins.
"""
from __future__ import annotations

from typing import Dict, List, Tuple

import numpy as np

from hmm import DiscreteHMM


class EmotionHMMClassifier:
    def __init__(
        self,
        n_states: int = 3,
        n_symbols: int = 16,
        n_iter: int = 50,
        tol: float = 1e-4,
        random_seed: int = 42,
        smoothing: float = 1e-3,
    ):
        self.n_states = n_states
        self.n_symbols = n_symbols
        self.n_iter = n_iter
        self.tol = tol
        self.random_seed = random_seed
        self.smoothing = smoothing
        self.models: Dict[str, DiscreteHMM] = {}
        self.classes_: List[str] = []

    def _new_model(self) -> DiscreteHMM:
        return DiscreteHMM(
            n_states=self.n_states,
            n_symbols=self.n_symbols,
            n_iter=self.n_iter,
            tol=self.tol,
            random_state=self.random_seed,
            smoothing=self.smoothing,
            init="random",
        )

    def fit(
        self, sequences: List[np.ndarray], labels: List[str]
    ) -> "EmotionHMMClassifier":
        """Train one HMM per unique label."""
        if len(sequences) != len(labels):
            raise ValueError("sequences and labels must be the same length")
        self.classes_ = sorted(set(labels))
        for c in self.classes_:
            seqs = [
                np.asarray(s).reshape(-1).astype(np.int64)
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
        seq = np.asarray(sequence).reshape(-1).astype(np.int64)
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
