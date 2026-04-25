"""Tests for core/mfcc.py."""
from __future__ import annotations

import numpy as np
import pytest

from mfcc import cmvn, extract_mfcc, hz_to_mel, mel_filterbank, mel_to_hz


class TestMelConversions:
    def test_zero_hz_is_zero_mel(self):
        assert hz_to_mel(0.0) == pytest.approx(0.0)

    def test_roundtrip_scalar(self):
        for f in [50.0, 200.0, 1000.0, 4000.0, 8000.0]:
            assert mel_to_hz(hz_to_mel(f)) == pytest.approx(f, rel=1e-9)

    def test_roundtrip_array(self):
        f = np.array([50.0, 440.0, 1000.0, 4000.0])
        np.testing.assert_allclose(mel_to_hz(hz_to_mel(f)), f, rtol=1e-9)

    def test_monotonic(self):
        f = np.linspace(0, 8000, 50)
        m = hz_to_mel(f)
        assert np.all(np.diff(m) > 0)


class TestMelFilterbank:
    def test_shape(self):
        fb = mel_filterbank(n_mels=26, n_fft=512, sample_rate=16000)
        assert fb.shape == (26, 512 // 2 + 1)

    def test_nonnegative(self):
        fb = mel_filterbank(n_mels=20, n_fft=512, sample_rate=16000)
        assert (fb >= 0).all()

    def test_each_filter_has_nonzero_support(self):
        fb = mel_filterbank(n_mels=26, n_fft=512, sample_rate=16000)
        # All triangles should integrate to something positive
        assert (fb.sum(axis=1) > 0).all()

    def test_default_fmax_is_nyquist(self):
        fb_default = mel_filterbank(n_mels=20, n_fft=512, sample_rate=16000)
        fb_explicit = mel_filterbank(
            n_mels=20, n_fft=512, sample_rate=16000, fmax=8000.0
        )
        np.testing.assert_array_equal(fb_default, fb_explicit)


class TestCMVN:
    def test_zero_mean_unit_var(self, rng):
        x = rng.standard_normal((100, 13)) * 5 + 3
        y = cmvn(x)
        np.testing.assert_allclose(y.mean(axis=0), 0.0, atol=1e-9)
        np.testing.assert_allclose(y.std(axis=0), 1.0, atol=1e-6)

    def test_empty_input_passthrough(self):
        x = np.zeros((0, 5))
        y = cmvn(x)
        assert y.shape == (0, 5)

    def test_constant_column_safe(self):
        # std=0 must not blow up because of the +1e-8 floor
        x = np.ones((50, 4))
        y = cmvn(x)
        assert np.all(np.isfinite(y))


class TestExtractMfcc:
    def test_default_shape(self, sine_wave):
        y, sr = sine_wave
        feats = extract_mfcc(y, sr)
        # 12 MFCC + 1 log_energy + deltas + delta-deltas = 13 * 3 = 39
        assert feats.ndim == 2
        assert feats.shape[1] == 39
        assert feats.shape[0] > 0

    def test_no_dynamics_no_energy(self, sine_wave):
        y, sr = sine_wave
        feats = extract_mfcc(
            y, sr, n_mfcc=12,
            include_deltas=False,
            include_delta_deltas=False,
            include_log_energy=False,
            apply_cmvn=False,
        )
        assert feats.shape[1] == 12

    def test_deltas_only(self, sine_wave):
        y, sr = sine_wave
        feats = extract_mfcc(
            y, sr, n_mfcc=12,
            include_deltas=True,
            include_delta_deltas=False,
            include_log_energy=False,
            apply_cmvn=False,
        )
        # 12 base + 12 deltas
        assert feats.shape[1] == 24

    def test_short_signal_padded_to_one_frame(self):
        # Sub-frame input gets zero-padded to a single frame
        feats = extract_mfcc(
            np.ones(100), 16000, n_mfcc=12,
            include_deltas=False, include_delta_deltas=False,
            include_log_energy=False, apply_cmvn=False,
        )
        assert feats.shape == (1, 12)

    def test_finite(self, white_noise):
        y, sr = white_noise
        feats = extract_mfcc(y, sr)
        assert np.all(np.isfinite(feats))

    def test_cmvn_applied(self, white_noise):
        y, sr = white_noise
        feats = extract_mfcc(y, sr, apply_cmvn=True)
        np.testing.assert_allclose(feats.mean(axis=0), 0.0, atol=1e-6)
        np.testing.assert_allclose(feats.std(axis=0), 1.0, atol=1e-3)
