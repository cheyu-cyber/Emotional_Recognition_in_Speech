"""Tests for core/prosodic.py."""
from __future__ import annotations

import numpy as np
import pytest

from prosodic import extract_prosodic, pitch_autocorr_frame, short_time_energy


class TestPitchAutocorrFrame:
    def test_recovers_sine_pitch(self):
        sr = 16000
        f0 = 200.0
        t = np.arange(int(0.05 * sr)) / sr  # 50 ms
        frame = np.sin(2 * np.pi * f0 * t)
        est = pitch_autocorr_frame(frame, sr, fmin=60, fmax=400, voicing_threshold=0.3)
        # Sample-quantised lag, allow ~5% relative error
        assert est == pytest.approx(f0, rel=0.05)

    def test_unvoiced_returns_zero(self, rng):
        # White noise has no periodic peak above the threshold
        sr = 16000
        frame = rng.standard_normal(800)
        est = pitch_autocorr_frame(frame, sr, voicing_threshold=0.9)
        assert est == 0.0

    def test_zero_frame(self):
        assert pitch_autocorr_frame(np.zeros(0), 16000) == 0.0
        assert pitch_autocorr_frame(np.zeros(800), 16000) == 0.0

    def test_short_frame_returns_zero(self):
        # If the frame is shorter than min_lag, we cannot estimate
        assert pitch_autocorr_frame(np.ones(5), 16000, fmin=60, fmax=400) == 0.0


class TestShortTimeEnergy:
    def test_known_values(self):
        frames = np.array([[1.0, 1.0], [2.0, 2.0], [0.0, 0.0]])
        e = short_time_energy(frames)
        np.testing.assert_array_equal(e, [2.0, 8.0, 0.0])

    def test_shape(self, rng):
        frames = rng.standard_normal((20, 400))
        assert short_time_energy(frames).shape == (20,)


class TestExtractProsodic:
    def test_shape(self, sine_wave):
        y, sr = sine_wave
        feats = extract_prosodic(y, sr)
        assert feats.shape[1] == 2
        assert feats.shape[0] > 0
        assert np.all(np.isfinite(feats))

    def test_pitch_column_close_to_truth(self, sine_wave):
        y, sr = sine_wave
        feats = extract_prosodic(y, sr, pitch_fmin=60, pitch_fmax=400)
        pitch = feats[:, 1]
        # On a clean 200 Hz sinusoid, voiced frames should report ~200 Hz
        voiced = pitch[pitch > 0]
        assert len(voiced) > 0
        assert np.median(voiced) == pytest.approx(200.0, rel=0.05)

    def test_short_signal_padded_to_one_frame(self):
        feats = extract_prosodic(np.ones(50), 16000)
        assert feats.shape == (1, 2)
        assert np.all(np.isfinite(feats))
