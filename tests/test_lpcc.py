"""Tests for core/lpcc.py."""
from __future__ import annotations

import numpy as np
import pytest

from lpcc import extract_lpcc, lpc_to_lpcc


class TestLpcToLpcc:
    def test_length(self):
        a = np.array([1.0, -0.5, 0.2, -0.1])
        c = lpc_to_lpcc(a, n_cepstral=12)
        assert c.shape == (12,)

    def test_first_coef_matches_alpha(self):
        # By the recursion, c_1 = alpha_1 = -a_1.
        a = np.array([1.0, -0.7, 0.3])
        c = lpc_to_lpcc(a, n_cepstral=4)
        assert c[0] == pytest.approx(-a[1])

    def test_extends_beyond_lpc_order(self):
        # With p=2 and q=6 we exercise the m>p branch
        a = np.array([1.0, -0.5, 0.1])
        c = lpc_to_lpcc(a, n_cepstral=6)
        assert c.shape == (6,)
        assert np.all(np.isfinite(c))


class TestExtractLpcc:
    def test_shape_with_deltas(self, ar2_signal):
        x, sr, _ = ar2_signal
        feats = extract_lpcc(x, sr, lpc_order=12, n_cepstral=12, include_deltas=True)
        assert feats.shape[1] == 24
        assert feats.shape[0] > 0
        assert np.all(np.isfinite(feats))

    def test_shape_without_deltas(self, ar2_signal):
        x, sr, _ = ar2_signal
        feats = extract_lpcc(x, sr, lpc_order=12, n_cepstral=12, include_deltas=False)
        assert feats.shape[1] == 12

    def test_short_signal_padded_to_one_frame(self):
        feats = extract_lpcc(np.ones(80), 16000, lpc_order=8, n_cepstral=10, include_deltas=False)
        assert feats.shape == (1, 10)
        assert np.all(np.isfinite(feats))
