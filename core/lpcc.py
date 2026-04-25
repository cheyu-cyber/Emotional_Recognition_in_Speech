"""lpcc.py — LP-Cepstral Coefficients from LPC via the standard recursion.

For the all-pole model H(z) = G / A(z) with A(z) = 1 - sum_{k=1..p} alpha_k z^-k
(predictor convention), the cepstrum c_m of the impulse response satisfies

    c_m = alpha_m + sum_{k=1..m-1} (k/m) c_k alpha_{m-k}        for 1 <= m <= p
    c_m = sum_{k=m-p..m-1} (k/m) c_k alpha_{m-k}                for m > p

We get alpha from the LPC coefficients of `lpc.py` via alpha_k = -a_k, since
the analysis filter there is A(z) = 1 + sum a_k z^-k.
"""
from __future__ import annotations

import numpy as np

from framing import front_end, deltas
from lpc import frame_lpc


def lpc_to_lpcc(a: np.ndarray, n_cepstral: int) -> np.ndarray:
    """Convert LPC coefficients [1, a_1, ..., a_p] to LPCC c_1..c_q.

    `c_0 = ln(G^2)` is excluded; we only return the spectral-shape part.
    """
    p = len(a) - 1
    # Predictor convention: alpha_k = -a_k (1-indexed; alpha[0] unused)
    alpha = np.zeros(p + 1)
    for k in range(1, p + 1):
        alpha[k] = -a[k]

    q = n_cepstral
    c = np.zeros(q + 1)  # c[0] left as 0
    for m in range(1, q + 1):
        if m <= p:
            s = 0.0
            for k in range(1, m):
                s += (k / m) * c[k] * alpha[m - k]
            c[m] = alpha[m] + s
        else:
            s = 0.0
            for k in range(max(1, m - p), m):
                s += (k / m) * c[k] * alpha[m - k]
            c[m] = s
    return c[1:]


def extract_lpcc(
    signal: np.ndarray,
    sample_rate: int,
    lpc_order: int = 12,
    n_cepstral: int = 12,
    frame_length_ms: float = 25.0,
    hop_length_ms: float = 10.0,
    preemphasis_coeff: float = 0.97,
    window: str = "hamming",
    include_deltas: bool = True,
) -> np.ndarray:
    """Per-frame LPCC features, optionally with first-order deltas appended."""
    frames = front_end(
        signal, sample_rate, frame_length_ms, hop_length_ms, preemphasis_coeff, window
    )
    T = frames.shape[0]
    if T == 0:
        d = n_cepstral * (2 if include_deltas else 1)
        return np.zeros((0, d))

    base = np.zeros((T, n_cepstral))
    for t in range(T):
        a, _err, _k = frame_lpc(frames[t], lpc_order)
        base[t] = lpc_to_lpcc(a, n_cepstral)

    if include_deltas:
        d1 = deltas(base, N=2)
        return np.concatenate([base, d1], axis=1)
    return base
