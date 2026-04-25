"""Shared test setup: put core/ and utils/ on sys.path so flat imports work."""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
import pytest

ROOT = Path(__file__).resolve().parent.parent
for sub in ("core", "utils"):
    p = str(ROOT / sub)
    if p not in sys.path:
        sys.path.insert(0, p)


@pytest.fixture
def rng():
    return np.random.default_rng(0)


@pytest.fixture
def sine_wave():
    """1-second sine wave at 200 Hz, 16 kHz sample rate."""
    sr = 16000
    t = np.arange(sr) / sr
    y = 0.5 * np.sin(2 * np.pi * 200.0 * t).astype(np.float64)
    return y, sr


@pytest.fixture
def white_noise(rng):
    sr = 16000
    y = rng.standard_normal(sr).astype(np.float64) * 0.1
    return y, sr


@pytest.fixture
def ar2_signal(rng):
    """Synthetic AR(2) signal generated as x[n] = c1 x[n-1] + c2 x[n-2] + e[n].

    Under the analysis convention A(z) = 1 + a1 z^-1 + a2 z^-2 used by lpc.py,
    this yields a1 = -c1, a2 = -c2.
    """
    sr = 16000
    n = sr  # 1 second
    c1, c2 = 1.4, -0.6  # poles inside the unit circle
    e = rng.standard_normal(n) * 0.01
    x = np.zeros(n)
    for i in range(2, n):
        x[i] = c1 * x[i - 1] + c2 * x[i - 2] + e[i]
    return x, sr, (c1, c2)
