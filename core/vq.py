"""vq.py — k-means vector quantizer for discrete-HMM observation sequences.

Features in {MFCC, LPC, LPCC, combined} are continuous. The HMM in
hmm_classifier.py is a discrete (Categorical) HMM, so we map each frame
to one of K codewords using a k-means codebook fit on training features.
This matches the existing 16-symbol-codebook MATLAB pipeline.
"""
from __future__ import annotations

from typing import List

import numpy as np
from sklearn.cluster import KMeans


class VectorQuantizer:
    def __init__(self, n_clusters: int = 16, random_seed: int = 42, n_init: int = 10):
        self.n_clusters = n_clusters
        self.kmeans = KMeans(
            n_clusters=n_clusters,
            random_state=random_seed,
            n_init=n_init,
        )
        self._fitted = False

    def fit(self, features: np.ndarray) -> "VectorQuantizer":
        """Fit codebook on a stacked (N, D) array of training feature frames."""
        if features.ndim != 2:
            raise ValueError("features must be 2-D (N, D)")
        if features.shape[0] < self.n_clusters:
            raise ValueError(
                f"Need at least {self.n_clusters} samples to fit a {self.n_clusters}-cluster codebook"
            )
        self.kmeans.fit(features)
        self._fitted = True
        return self

    def encode(self, features: np.ndarray) -> np.ndarray:
        """(T, D) feature matrix -> (T,) sequence of codeword indices."""
        if not self._fitted:
            raise RuntimeError("VectorQuantizer must be fit() before encode()")
        if features.shape[0] == 0:
            return np.zeros(0, dtype=np.int64)
        return self.kmeans.predict(features).astype(np.int64)

    def encode_all(self, sequences: List[np.ndarray]) -> List[np.ndarray]:
        return [self.encode(s) for s in sequences]
