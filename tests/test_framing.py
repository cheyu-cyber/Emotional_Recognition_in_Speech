"""Tests for core/framing.py."""
from __future__ import annotations

import numpy as np
import pytest

from framing import (
    deltas,
    frame_signal,
    front_end,
    ms_to_samples,
    preemphasis,
)


class TestPreemphasis:
    def test_zero_coeff_returns_float_copy(self):
        x = np.array([1, 2, 3, 4], dtype=np.int32)
        y = preemphasis(x, coeff=0.0)
        assert y.dtype == np.float64
        np.testing.assert_array_equal(y, x.astype(np.float64))

    def test_negative_coeff_treated_as_no_op(self):
        x = np.array([1.0, 2.0, 3.0])
        y = preemphasis(x, coeff=-0.5)
        np.testing.assert_array_equal(y, x)

    def test_first_sample_preserved(self):
        x = np.array([0.5, 1.0, 2.0, 3.0])
        y = preemphasis(x, coeff=0.97)
        assert y[0] == pytest.approx(0.5)

    def test_filter_formula(self):
        x = np.array([1.0, 2.0, 4.0, 8.0])
        coeff = 0.97
        y = preemphasis(x, coeff)
        expected = np.array(
            [1.0, 2.0 - coeff * 1.0, 4.0 - coeff * 2.0, 8.0 - coeff * 4.0]
        )
        np.testing.assert_allclose(y, expected)


class TestFrameSignal:
    def test_basic_shape(self):
        sig = np.arange(100, dtype=np.float64)
        frames = frame_signal(sig, frame_length=20, hop_length=10, window="rect")
        # n_frames = 1 + (100 - 20) // 10 = 9
        assert frames.shape == (9, 20)

    def test_zero_pad_when_signal_shorter_than_frame(self):
        sig = np.ones(5, dtype=np.float64)
        frames = frame_signal(sig, frame_length=10, hop_length=5, window="rect")
        assert frames.shape == (1, 10)
        np.testing.assert_array_equal(frames[0, :5], 1.0)
        np.testing.assert_array_equal(frames[0, 5:], 0.0)

    def test_hamming_window_applied(self):
        sig = np.ones(40, dtype=np.float64)
        frames = frame_signal(sig, frame_length=20, hop_length=10, window="hamming")
        np.testing.assert_allclose(frames[0], np.hamming(20))

    def test_hann_window(self):
        sig = np.ones(40, dtype=np.float64)
        frames = frame_signal(sig, frame_length=20, hop_length=10, window="hann")
        np.testing.assert_allclose(frames[0], np.hanning(20))

    def test_rect_window_is_identity(self):
        sig = np.arange(40, dtype=np.float64)
        frames = frame_signal(sig, frame_length=20, hop_length=10, window="rect")
        np.testing.assert_array_equal(frames[0], sig[:20])
        np.testing.assert_array_equal(frames[1], sig[10:30])

    def test_unknown_window_raises(self):
        with pytest.raises(ValueError, match="Unknown window"):
            frame_signal(np.ones(20), frame_length=10, hop_length=5, window="bogus")


class TestMsToSamples:
    def test_known_values(self):
        assert ms_to_samples(25.0, 16000) == 400
        assert ms_to_samples(10.0, 16000) == 160
        assert ms_to_samples(20.0, 8000) == 160

    def test_rounds_not_truncates(self):
        # 25 * 22050 / 1000 = 551.25 -> 551
        assert ms_to_samples(25.0, 22050) == 551
        # 12.5 * 16000 / 1000 = 200
        assert ms_to_samples(12.5, 16000) == 200


class TestFrontEnd:
    def test_pipeline_shape(self, sine_wave):
        y, sr = sine_wave
        frames = front_end(
            y, sr, frame_length_ms=25, hop_length_ms=10,
            preemphasis_coeff=0.97, window="hamming",
        )
        # frame_length = 400, hop = 160
        expected_n = 1 + (len(y) - 400) // 160
        assert frames.shape == (expected_n, 400)

    def test_no_preemph_passthrough(self, sine_wave):
        y, sr = sine_wave
        frames = front_end(
            y, sr, preemphasis_coeff=0.0, window="rect",
        )
        np.testing.assert_allclose(frames[0], y[:400])


class TestDeltas:
    def test_constant_input_gives_zero(self):
        feats = np.ones((20, 5))
        d = deltas(feats, N=2)
        np.testing.assert_allclose(d, 0.0, atol=1e-12)

    def test_linear_ramp_gives_constant_slope(self):
        # f[t,d] = t -> d_t should be 1 (after the standard regression formula)
        T = 20
        feats = np.tile(np.arange(T)[:, None], (1, 3)).astype(np.float64)
        d = deltas(feats, N=2)
        # In the interior, d should be exactly 1
        np.testing.assert_allclose(d[5:15], 1.0)

    def test_shape_preserved(self):
        feats = np.random.RandomState(0).randn(30, 7)
        d = deltas(feats, N=2)
        assert d.shape == feats.shape

    def test_empty_input(self):
        feats = np.zeros((0, 4))
        d = deltas(feats, N=2)
        assert d.shape == (0, 4)

    def test_rejects_1d(self):
        with pytest.raises(ValueError, match="must be"):
            deltas(np.zeros(10), N=2)
