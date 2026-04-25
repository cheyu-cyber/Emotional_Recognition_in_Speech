"""Tests for core/gmm_hmm_classifier.py."""
from __future__ import annotations

import numpy as np
import pytest

pytest.importorskip("sklearn")

from gmm_hmm_classifier import EmotionGMMHMMClassifier


def _sample(pi, A, weights, means, covars, T, rng):
    K = len(pi)
    M, D = means.shape[1], means.shape[2]
    s = rng.choice(K, p=pi)
    out = np.empty((T, D))
    for t in range(T):
        if t > 0:
            s = rng.choice(K, p=A[s])
        m = rng.choice(M, p=weights[s])
        out[t] = rng.normal(loc=means[s, m], scale=np.sqrt(covars[s, m]))
    return out


class TestEmotionGMMHMMClassifier:
    def _make_two_class_data(self, rng):
        D = 2
        pi = np.array([0.5, 0.5])
        A = np.array([[0.85, 0.15], [0.15, 0.85]])
        weights = np.array([[0.5, 0.5], [0.5, 0.5]])
        means_happy = np.array([
            [[-4.0, 0.0], [-4.0, 4.0]],
            [[4.0, 0.0], [4.0, 4.0]],
        ])
        means_sad = means_happy * -1.0
        covars = np.full((2, 2, D), 0.3)
        seqs, labels = [], []
        for _ in range(4):
            seqs.append(_sample(pi, A, weights, means_happy, covars, 200, rng))
            labels.append("happy")
            seqs.append(_sample(pi, A, weights, means_sad, covars, 200, rng))
            labels.append("sad")
        return seqs, labels

    def test_fit_creates_one_model_per_label(self, rng):
        seqs, labels = self._make_two_class_data(rng)
        clf = EmotionGMMHMMClassifier(n_states=2, n_mix=2, n_iter=10, random_seed=0)
        clf.fit(seqs, labels)
        assert clf.classes_ == ["happy", "sad"]
        assert set(clf.models.keys()) == {"happy", "sad"}

    def test_predict_one_returns_label_and_scores(self, rng):
        seqs, labels = self._make_two_class_data(rng)
        clf = EmotionGMMHMMClassifier(n_states=2, n_mix=2, n_iter=10, random_seed=0)
        clf.fit(seqs, labels)
        pred, scores = clf.predict_one(seqs[0])
        assert pred in {"happy", "sad"}
        assert set(scores.keys()) == {"happy", "sad"}
        assert all(np.isfinite(v) for v in scores.values())

    def test_predict_batch_shape(self, rng):
        seqs, labels = self._make_two_class_data(rng)
        clf = EmotionGMMHMMClassifier(n_states=2, n_mix=2, n_iter=10, random_seed=0)
        clf.fit(seqs, labels)
        preds, all_scores = clf.predict(seqs[:4])
        assert len(preds) == 4
        assert len(all_scores) == 4

    def test_classification_above_chance(self, rng):
        train_seqs, train_labels = self._make_two_class_data(rng)
        test_seqs, test_labels = self._make_two_class_data(rng)
        clf = EmotionGMMHMMClassifier(n_states=2, n_mix=2, n_iter=15, random_seed=0)
        clf.fit(train_seqs, train_labels)
        preds, _ = clf.predict(test_seqs)
        acc = np.mean(np.array(preds) == np.array(test_labels))
        assert acc >= 0.8

    def test_length_mismatch_raises(self):
        clf = EmotionGMMHMMClassifier(n_states=2, n_mix=2)
        with pytest.raises(ValueError, match="same length"):
            clf.fit([np.zeros((10, 2))], ["a", "b"])

    def test_skips_empty_sequences(self, rng):
        seqs = [np.zeros((0, 2)), rng.standard_normal((50, 2))]
        labels = ["a", "b"]
        clf = EmotionGMMHMMClassifier(n_states=2, n_mix=2, n_iter=3, random_seed=0)
        clf.fit(seqs, labels)
        assert "b" in clf.models
        assert "a" not in clf.models

    def test_predict_with_no_models_returns_unknown(self):
        clf = EmotionGMMHMMClassifier(n_states=2, n_mix=2)
        pred, scores = clf.predict_one(np.zeros((5, 2)))
        assert pred == "unknown"
        assert scores == {}
