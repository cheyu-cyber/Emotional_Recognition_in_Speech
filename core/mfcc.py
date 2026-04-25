"""mfcc.py — Mel-Frequency Cepstral Coefficients.

Standard pipeline: pre-emph -> frame/window -> |FFT|^2 -> mel filterbank ->
log -> DCT -> truncate. Optional deltas, delta-deltas, log-energy, CMVN.
"""
from __future__ import annotations

import numpy as np
from scipy.fftpack import dct

from framing import front_end, deltas


def hz_to_mel(f: np.ndarray | float) -> np.ndarray | float:
    return 2595.0 * np.log10(1.0 + f / 700.0)


def mel_to_hz(m: np.ndarray | float) -> np.ndarray | float:
    return 700.0 * (10.0 ** (m / 2595.0) - 1.0)


def mel_filterbank(
    n_mels: int,
    n_fft: int,
    sample_rate: int,
    fmin: float = 0.0,
    fmax: float | None = None,
) -> np.ndarray:
    """Construct a triangular mel filterbank of shape (n_mels, n_fft//2 + 1)."""
    if fmax is None:
        fmax = sample_rate / 2.0
    mel_min = hz_to_mel(fmin)
    mel_max = hz_to_mel(fmax)
    mel_points = np.linspace(mel_min, mel_max, n_mels + 2)
    hz_points = mel_to_hz(mel_points)
    bin_pts = np.floor((n_fft + 1) * hz_points / sample_rate).astype(int)
    bin_pts = np.clip(bin_pts, 0, n_fft // 2)

    fb = np.zeros((n_mels, n_fft // 2 + 1))
    for m in range(1, n_mels + 1):
        fl, fc, fr = bin_pts[m - 1], bin_pts[m], bin_pts[m + 1]
        if fc > fl:
            fb[m - 1, fl:fc] = (np.arange(fl, fc) - fl) / max(fc - fl, 1)
        if fr > fc:
            fb[m - 1, fc:fr] = (fr - np.arange(fc, fr)) / max(fr - fc, 1)
    return fb


def cmvn(features: np.ndarray) -> np.ndarray:
    """Per-utterance cepstral mean and variance normalisation."""
    if features.shape[0] == 0:
        return features
    mu = features.mean(axis=0, keepdims=True)
    sd = features.std(axis=0, keepdims=True) + 1e-8
    return (features - mu) / sd


def extract_mfcc(
    signal: np.ndarray,
    sample_rate: int,
    n_mfcc: int = 12,
    n_mels: int = 26,
    n_fft: int = 512,
    fmin: float = 0.0,
    fmax: float | None = None,
    frame_length_ms: float = 25.0,
    hop_length_ms: float = 10.0,
    preemphasis_coeff: float = 0.97,
    window: str = "hamming",
    include_deltas: bool = True,
    include_delta_deltas: bool = True,
    include_log_energy: bool = True,
    apply_cmvn: bool = True,
) -> np.ndarray:
    """Extract a (T, D) matrix of MFCC + optional dynamic features."""
    frames = front_end(
        signal, sample_rate, frame_length_ms, hop_length_ms, preemphasis_coeff, window
    )
    if frames.shape[0] == 0:
        return np.zeros((0, n_mfcc))

    # Power spectrum
    spec = np.abs(np.fft.rfft(frames, n=n_fft, axis=1))
    power = (spec ** 2) / n_fft

    # Mel filterbank energies
    fb = mel_filterbank(n_mels, n_fft, sample_rate, fmin, fmax)
    mel_energies = power @ fb.T
    log_mel = np.log(mel_energies + 1e-10)

    # DCT-II, orthonormal
    mfcc = dct(log_mel, type=2, axis=1, norm="ortho")[:, :n_mfcc]

    blocks = [mfcc]
    if include_log_energy:
        # Energy of the windowed frame (not the spectrum) — matches Davis/Mermelstein
        energy = np.log(np.sum(frames ** 2, axis=1) + 1e-10).reshape(-1, 1)
        blocks.append(energy)

    base = np.concatenate(blocks, axis=1)

    if include_deltas:
        d1 = deltas(base, N=2)
        if include_delta_deltas:
            d2 = deltas(d1, N=2)
            features = np.concatenate([base, d1, d2], axis=1)
        else:
            features = np.concatenate([base, d1], axis=1)
    else:
        features = base

    if apply_cmvn:
        features = cmvn(features)
    return features
