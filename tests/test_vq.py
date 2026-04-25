"""Tests for core/vq.py."""
from __future__ import annotations

import numpy as np
import pytest

pytest.importorskip("sklearn")

from vq import VectorQuantizer  # noqa: E402


def _three_clusters(rng):
    centers = np.array([[-5.0, -5.0], [0.0, 0.0], [5.0, 5.0]])
    pts = np.concatenate(
        [c + rng.standard_normal((50, 2)) * 0.2 for c in centers], axis=0
    )
    return pts, centers


class TestVectorQuantizer:
    def test_fit_then_encode_recovers_clusters(self, rng):
        pts, _centers = _three_clusters(rng)
        vq = VectorQuantizer(n_clusters=3, random_seed=0, n_init=5)
        vq.fit(pts)
        codes = vq.encode(pts)
        # Each of the three groups of 50 should have a single dominant code
        assert codes.shape == (150,)
        for i in range(3):
            block = codes[i * 50 : (i + 1) * 50]
            most_common = np.bincount(block).max()
            assert most_common >= 48  # allow a couple of edge points

    def test_encode_dtype(self, rng):
        pts, _ = _three_clusters(rng)
        vq = VectorQuantizer(n_clusters=3, random_seed=0).fit(pts)
        codes = vq.encode(pts[:10])
        assert codes.dtype == np.int64

    def test_encode_before_fit_raises(self):
        vq = VectorQuantizer(n_clusters=3, random_seed=0)
        with pytest.raises(RuntimeError, match="must be fit"):
            vq.encode(np.zeros((5, 2)))

    def test_encode_empty(self, rng):
        pts, _ = _three_clusters(rng)
        vq = VectorQuantizer(n_clusters=3, random_seed=0).fit(pts)
        out = vq.encode(np.zeros((0, 2)))
        assert out.shape == (0,)
        assert out.dtype == np.int64

    def test_fit_rejects_1d(self):
        vq = VectorQuantizer(n_clusters=2, random_seed=0)
        with pytest.raises(ValueError, match="2-D"):
            vq.fit(np.zeros(20))

    def test_fit_rejects_too_few_samples(self):
        vq = VectorQuantizer(n_clusters=10, random_seed=0)
        with pytest.raises(ValueError, match="at least 10"):
            vq.fit(np.zeros((5, 3)))

    def test_encode_all(self, rng):
        pts, _ = _three_clusters(rng)
        vq = VectorQuantizer(n_clusters=3, random_seed=0).fit(pts)
        seqs = [pts[:5], pts[60:80], np.zeros((0, 2))]
        out = vq.encode_all(seqs)
        assert len(out) == 3
        assert out[0].shape == (5,)
        assert out[1].shape == (20,)
        assert out[2].shape == (0,)

    def test_codes_in_range(self, rng):
        pts, _ = _three_clusters(rng)
        vq = VectorQuantizer(n_clusters=4, random_seed=0).fit(pts)
        codes = vq.encode(pts)
        assert codes.min() >= 0
        assert codes.max() < 4
