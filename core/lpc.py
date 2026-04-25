"""lpc.py — Linear Predictive Coding via the autocorrelation method.

Convention: the analysis filter is

    A(z) = 1 + a_1 z^-1 + a_2 z^-2 + ... + a_p z^-p

so that the signal satisfies

    x[n] + a_1 x[n-1] + ... + a_p x[n-p] = e[n].

Equivalently, the all-pole synthesis filter is H(z) = G / A(z) where
G^2 is the prediction-error variance returned by Levinson-Durbin.

This is the same convention that scipy and librosa use, so the LPC
coefficients can be passed directly to scipy.signal.freqz to obtain the
spectral envelope.
"""
from __future__ import annotations

import numpy as np
from scipy.signal import freqz

from framing import front_end


def autocorrelation(frame: np.ndarray, max_lag: int) -> np.ndarray:
    """Biased autocorrelation r[0..max_lag]."""
    n = len(frame)
    full = np.correlate(frame, frame, mode="full")
    # full[n-1] is the zero-lag value
    return full[n - 1 : n - 1 + max_lag + 1]


def levinson_durbin(r: np.ndarray, order: int):
    """Solve the symmetric Toeplitz LPC normal equations.

    Parameters
    ----------
    r : autocorrelation of length >= order + 1.
    order : LPC order p.

    Returns
    -------
    a : (order + 1,) array, with a[0] == 1, such that A(z) = sum a[k] z^-k.
    err : prediction-error variance (scalar, >= 0).
    k_ref : (order,) array of reflection (PARCOR) coefficients.
    """
    a = np.zeros(order + 1)
    a[0] = 1.0
    k_ref = np.zeros(order)
    if r[0] <= 0:
        return a, 0.0, k_ref
    err = float(r[0])

    for i in range(order):
        # k_{i+1} = -(r[i+1] + sum_{j=1..i} a[j] r[i+1-j]) / err
        acc = r[i + 1]
        for j in range(1, i + 1):
            acc += a[j] * r[i + 1 - j]
        if err <= 0:
            break
        k = -acc / err
        k_ref[i] = k

        # Symmetric update of a
        a_new = a.copy()
        for j in range(1, i + 2):
            if j == i + 1:
                a_new[j] = k
            else:
                a_new[j] = a[j] + k * a[i + 1 - j]
        a = a_new
        err = err * (1.0 - k * k)
        if err < 0:
            err = 0.0

    return a, float(err), k_ref


def frame_lpc(frame: np.ndarray, order: int):
    """Compute LPC for one frame. Returns (a, err, k_ref)."""
    r = autocorrelation(frame, order)
    return levinson_durbin(r, order)


def lpc_spectral_envelope(a: np.ndarray, gain: float, n_fft: int = 512) -> np.ndarray:
    """Magnitude of H(z) = sqrt(gain) / A(z) on the unit circle."""
    w, h = freqz([np.sqrt(max(gain, 1e-12))], a, worN=n_fft // 2 + 1)
    return np.abs(h)


def extract_lpc(
    signal: np.ndarray,
    sample_rate: int,
    order: int = 12,
    frame_length_ms: float = 25.0,
    hop_length_ms: float = 10.0,
    preemphasis_coeff: float = 0.97,
    window: str = "hamming",
    include_error_energy: bool = True,
) -> np.ndarray:
    """Extract a (T, D) matrix of per-frame LPC coefficients.

    The constant a[0]=1 is dropped, leaving columns a_1..a_p, optionally
    appended with log(prediction-error energy + eps).
    """
    frames = front_end(
        signal, sample_rate, frame_length_ms, hop_length_ms, preemphasis_coeff, window
    )
    T = frames.shape[0]
    if T == 0:
        d = order + (1 if include_error_energy else 0)
        return np.zeros((0, d))

    out_dim = order + (1 if include_error_energy else 0)
    out = np.zeros((T, out_dim))
    for t in range(T):
        a, err, _ = frame_lpc(frames[t], order)
        out[t, :order] = a[1:]  # drop a[0] = 1
        if include_error_energy:
            out[t, order] = np.log(err + 1e-10)
    return out
