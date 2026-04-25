"""prosodic.py — pitch (autocorrelation) and short-time energy.

These features are emotion-discriminative on their own (e.g., pitch range
expands for arousal-heavy emotions like anger and joy). They can be
concatenated to spectral features for a "combined" representation.
"""
from __future__ import annotations

import numpy as np

from framing import front_end


def pitch_autocorr_frame(
    frame: np.ndarray,
    sample_rate: int,
    fmin: float = 60.0,
    fmax: float = 400.0,
    voicing_threshold: float = 0.3,
) -> float:
    """Estimate pitch (Hz) for a single frame; returns 0.0 if unvoiced."""
    n = len(frame)
    if n == 0:
        return 0.0
    min_lag = max(1, int(np.floor(sample_rate / fmax)))
    max_lag = min(n - 1, int(np.ceil(sample_rate / fmin)))
    if max_lag <= min_lag:
        return 0.0

    full = np.correlate(frame, frame, mode="full")
    r = full[n - 1 :]  # r[0] is energy
    if r[0] <= 0:
        return 0.0

    segment = r[min_lag : max_lag + 1]
    if segment.size == 0:
        return 0.0
    peak_idx = int(np.argmax(segment)) + min_lag
    norm_peak = r[peak_idx] / r[0]
    if norm_peak < voicing_threshold:
        return 0.0
    return float(sample_rate) / float(peak_idx)


def short_time_energy(frames: np.ndarray) -> np.ndarray:
    return np.sum(frames ** 2, axis=1)


def extract_prosodic(
    signal: np.ndarray,
    sample_rate: int,
    pitch_fmin: float = 60.0,
    pitch_fmax: float = 400.0,
    voicing_threshold: float = 0.3,
    frame_length_ms: float = 25.0,
    hop_length_ms: float = 10.0,
    preemphasis_coeff: float = 0.0,  # NB: don't pre-emphasise for pitch
    window: str = "hamming",
) -> np.ndarray:
    """Per-frame [log_energy, pitch_hz] -> shape (T, 2)."""
    frames = front_end(
        signal, sample_rate, frame_length_ms, hop_length_ms, preemphasis_coeff, window
    )
    T = frames.shape[0]
    if T == 0:
        return np.zeros((0, 2))
    log_energy = np.log(short_time_energy(frames) + 1e-10)
    pitch = np.array(
        [
            pitch_autocorr_frame(
                frames[t], sample_rate, pitch_fmin, pitch_fmax, voicing_threshold
            )
            for t in range(T)
        ]
    )
    return np.stack([log_energy, pitch], axis=1)
