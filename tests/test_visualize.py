"""Tests for utils/visualize.py — smoke-tests that PNGs get written."""
from __future__ import annotations

import numpy as np
import pytest

# matplotlib + seaborn + sklearn must all be importable
pytest.importorskip("matplotlib")
pytest.importorskip("seaborn")
pytest.importorskip("sklearn")

import matplotlib  # noqa: E402

matplotlib.use("Agg")

from visualize import (  # noqa: E402
    plot_accuracy_bar,
    plot_codebook_usage,
    plot_confusion_matrix,
    plot_feature_distribution,
)


def _png_nonempty(path):
    return path.exists() and path.stat().st_size > 0


class TestPlotConfusionMatrix:
    def test_writes_png(self, tmp_path):
        out = tmp_path / "cm.png"
        plot_confusion_matrix(
            ["a", "b", "a"], ["a", "a", "b"],
            classes=["a", "b"],
            title="cm", out_path=str(out),
        )
        assert _png_nonempty(out)

    def test_normalize_false(self, tmp_path):
        out = tmp_path / "cm_raw.png"
        plot_confusion_matrix(
            ["a", "b", "a"], ["a", "a", "b"],
            classes=["a", "b"],
            title="cm", out_path=str(out), normalize=False,
        )
        assert _png_nonempty(out)


class TestPlotAccuracyBar:
    def test_writes_png(self, tmp_path):
        out = tmp_path / "acc.png"
        plot_accuracy_bar({"mfcc": 0.7, "lpc": 0.6}, str(out))
        assert _png_nonempty(out)


class TestPlotFeatureDistribution:
    def test_writes_png(self, tmp_path, rng):
        out = tmp_path / "feat.png"
        feats = rng.standard_normal((40, 6))
        labels = ["a"] * 20 + ["b"] * 20
        plot_feature_distribution(feats, labels, str(out), title="x")
        assert _png_nonempty(out)

    def test_empty_features_noop(self, tmp_path):
        out = tmp_path / "feat.png"
        plot_feature_distribution(
            np.zeros((0, 0)), [], str(out), title="x"
        )
        # The function returns silently without writing a file.
        assert not out.exists()


class TestPlotCodebookUsage:
    def test_writes_png(self, tmp_path, rng):
        out = tmp_path / "cb.png"
        seqs = [rng.integers(0, 8, size=50) for _ in range(6)]
        labels = ["a", "b", "a", "b", "a", "b"]
        plot_codebook_usage(seqs, labels, n_clusters=8, out_path=str(out), title="x")
        assert _png_nonempty(out)
