"""framing.py — pre-emphasis, framing, and windowing.

All feature extractors use the same front-end so that comparisons across
MFCC / LPC / LPCC are not confounded by different framing choices.
"""
from __future__ import annotations

import numpy as np


def preemphasis(signal: np.ndarray, coeff: float = 0.97) -> np.ndarray:
    """First-order high-pass: y[n] = x[n] - alpha * x[n-1]."""
    if coeff <= 0:
        return signal.astype(np.float64)
    return np.append(signal[0], signal[1:] - coeff * signal[:-1]).astype(np.float64)


def frame_signal(
    signal: np.ndarray,
    frame_length: int,
    hop_length: int,
    window: str = "hamming",
) -> np.ndarray:
    """Slice a 1-D signal into overlapping windowed frames.

    Returns
    -------
    frames : (T, frame_length) array of windowed frames.
    """
    n = len(signal)
    if n < frame_length:
        # Zero-pad so we still get one frame
        pad = np.zeros(frame_length - n)
        signal = np.concatenate([signal, pad])
        n = frame_length

    n_frames = 1 + (n - frame_length) // hop_length
    idx = (
        np.tile(np.arange(frame_length), (n_frames, 1))
        + np.tile(np.arange(n_frames) * hop_length, (frame_length, 1)).T
    )
    frames = signal[idx]

    if window in ("hamming",):
        win = np.hamming(frame_length)
    elif window in ("hann", "hanning"):
        win = np.hanning(frame_length)
    elif window in ("rect", "rectangular", None, "none"):
        win = np.ones(frame_length)
    else:
        raise ValueError(f"Unknown window: {window}")

    return frames * win[np.newaxis, :]


def ms_to_samples(ms: float, sr: int) -> int:
    return int(round(ms * sr / 1000.0))


def front_end(
    signal: np.ndarray,
    sample_rate: int,
    frame_length_ms: float = 25.0,
    hop_length_ms: float = 10.0,
    preemphasis_coeff: float = 0.97,
    window: str = "hamming",
) -> np.ndarray:
    """Convenience wrapper: pre-emphasis -> framing -> windowing."""
    y = preemphasis(signal, preemphasis_coeff)
    frame_len = ms_to_samples(frame_length_ms, sample_rate)
    hop_len = ms_to_samples(hop_length_ms, sample_rate)
    return frame_signal(y, frame_len, hop_len, window)


def deltas(features: np.ndarray, N: int = 2) -> np.ndarray:
    """Regression-based delta features.

    d_t = sum_{n=1..N} n * (c_{t+n} - c_{t-n}) / (2 * sum_{n=1..N} n^2)
    Edges are padded by replication.
    """
    if features.ndim != 2:
        raise ValueError("features must be (T, D)")
    T, D = features.shape
    if T == 0:
        return features.copy()
    denom = 2.0 * sum(n * n for n in range(1, N + 1))
    padded = np.pad(features, ((N, N), (0, 0)), mode="edge")
    delta = np.zeros_like(features)
    for n in range(1, N + 1):
        delta += n * (padded[N + n : N + n + T] - padded[N - n : N - n + T])
    return delta / denom
