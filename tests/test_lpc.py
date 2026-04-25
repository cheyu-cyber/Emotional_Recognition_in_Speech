"""Tests for core/lpc.py."""
from __future__ import annotations

import numpy as np
import pytest

from lpc import (
    autocorrelation,
    extract_lpc,
    frame_lpc,
    levinson_durbin,
    lpc_spectral_envelope,
)


class TestAutocorrelation:
    def test_zero_lag_is_energy(self, rng):
        x = rng.standard_normal(100)
        r = autocorrelation(x, max_lag=10)
        assert r[0] == pytest.approx(np.dot(x, x))

    def test_length(self):
        r = autocorrelation(np.arange(50, dtype=np.float64), max_lag=12)
        assert len(r) == 13

    def test_constant_input(self):
        x = np.ones(20)
        r = autocorrelation(x, max_lag=5)
        # r[k] for x=1 over n samples is (n - k) for biased autocorr via correlate
        expected = np.array([20, 19, 18, 17, 16, 15], dtype=np.float64)
        np.testing.assert_allclose(r, expected)

    def test_symmetry_property(self, rng):
        x = rng.standard_normal(64)
        r = autocorrelation(x, max_lag=8)
        # Compare against direct sums
        for k in range(9):
            expected = float(np.dot(x[: len(x) - k], x[k:]))
            assert r[k] == pytest.approx(expected, rel=1e-9, abs=1e-12)


class TestLevinsonDurbin:
    def test_recovers_ar2_coefficients(self, ar2_signal):
        x, _sr, (c1, c2) = ar2_signal
        # Use the whole signal to estimate
        r = autocorrelation(x, max_lag=2)
        a, err, k = levinson_durbin(r, order=2)
        assert a[0] == 1.0
        # By the convention A(z) = 1 + a1 z^-1 + a2 z^-2 with x[n] = c1 x[n-1] + c2 x[n-2] + e
        # we expect a1 ≈ -c1, a2 ≈ -c2.
        assert a[1] == pytest.approx(-c1, abs=0.05)
        assert a[2] == pytest.approx(-c2, abs=0.05)
        assert err >= 0
        assert len(k) == 2
        assert (np.abs(k) <= 1.0 + 1e-9).all()

    def test_zero_input_returns_safe_defaults(self):
        r = np.zeros(5)
        a, err, k = levinson_durbin(r, order=4)
        assert a[0] == 1.0
        np.testing.assert_array_equal(a[1:], 0.0)
        assert err == 0.0
        np.testing.assert_array_equal(k, 0.0)

    def test_a0_is_one(self, rng):
        x = rng.standard_normal(200)
        r = autocorrelation(x, max_lag=8)
        a, _, _ = levinson_durbin(r, order=8)
        assert a[0] == 1.0
        assert len(a) == 9


class TestFrameLpc:
    def test_returns_three_values(self, rng):
        x = rng.standard_normal(400)
        a, err, k = frame_lpc(x, order=12)
        assert len(a) == 13
        assert isinstance(err, float)
        assert len(k) == 12


class TestLpcSpectralEnvelope:
    def test_shape(self):
        a = np.array([1.0, -0.5, 0.2])
        env = lpc_spectral_envelope(a, gain=1.0, n_fft=512)
        assert env.shape == (512 // 2 + 1,)
        assert (env >= 0).all()

    def test_gain_floor(self):
        # Negative / tiny gain should not crash
        a = np.array([1.0, -0.5])
        env = lpc_spectral_envelope(a, gain=-1.0, n_fft=64)
        assert np.all(np.isfinite(env))


class TestExtractLpc:
    def test_default_shape(self, ar2_signal):
        x, sr, _ = ar2_signal
        feats = extract_lpc(x, sr, order=12)
        # 12 LPC coeffs + 1 log error
        assert feats.shape[1] == 13
        assert feats.shape[0] > 0
        assert np.all(np.isfinite(feats))

    def test_without_error_energy(self, ar2_signal):
        x, sr, _ = ar2_signal
        feats = extract_lpc(x, sr, order=8, include_error_energy=False)
        assert feats.shape[1] == 8

    def test_short_signal_padded_to_one_frame(self):
        # Front-end zero-pads to a single frame for sub-frame inputs
        x = np.ones(50, dtype=np.float64)
        feats = extract_lpc(x, 16000, order=8)
        assert feats.shape == (1, 9)
        assert np.all(np.isfinite(feats))

    def test_a0_is_dropped(self, ar2_signal):
        # Disable pre-emphasis so the LPC sees the raw AR(2) signal.
        # First LPC column should be ~ -c1, second ~ -c2 (analysis convention).
        x, sr, (c1, c2) = ar2_signal
        feats = extract_lpc(
            x, sr, order=2, preemphasis_coeff=0.0, include_error_energy=False,
        )
        assert feats.shape[1] == 2
        # No column should be a constant 1.0 (which would mean a0 wasn't dropped)
        assert not np.allclose(feats[:, 0], 1.0)
        # On a clean AR(2) with no preemphasis the recovered coefs should match
        assert feats[:, 0].mean() == pytest.approx(-c1, abs=0.15)
        assert feats[:, 1].mean() == pytest.approx(-c2, abs=0.15)
