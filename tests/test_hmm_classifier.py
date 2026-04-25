"""Tests for core/hmm_classifier.py."""
from __future__ import annotations

import numpy as np
import pytest

from hmm_classifier import EmotionHMMClassifier


def _sample(pi, A, B, T, rng):
    K = len(pi)
    s = rng.choice(K, p=pi)
    out = [rng.choice(B.shape[1], p=B[s])]
    for _ in range(T - 1):
        s = rng.choice(K, p=A[s])
        out.append(rng.choice(B.shape[1], p=B[s]))
    return np.array(out, dtype=np.int64)


class TestEmotionHMMClassifier:
    def _make_two_class_data(self, rng):
        pi = np.array([0.5, 0.5])
        A = np.array([[0.9, 0.1], [0.1, 0.9]])
        B_happy = np.array([[0.9, 0.1, 0.0], [0.0, 0.5, 0.5]])
        B_sad = np.array([[0.0, 0.1, 0.9], [0.5, 0.5, 0.0]])
        seqs, labels = [], []
        for _ in range(6):
            seqs.append(_sample(pi, A, B_happy, 200, rng))
            labels.append("happy")
            seqs.append(_sample(pi, A, B_sad, 200, rng))
            labels.append("sad")
        return seqs, labels

    def test_fit_creates_one_model_per_label(self, rng):
        seqs, labels = self._make_two_class_data(rng)
        clf = EmotionHMMClassifier(n_states=2, n_symbols=3, n_iter=15, random_seed=0)
        clf.fit(seqs, labels)
        assert clf.classes_ == ["happy", "sad"]
        assert set(clf.models.keys()) == {"happy", "sad"}

    def test_predict_one_returns_label_and_scores(self, rng):
        seqs, labels = self._make_two_class_data(rng)
        clf = EmotionHMMClassifier(n_states=2, n_symbols=3, n_iter=15, random_seed=0)
        clf.fit(seqs, labels)
        pred, scores = clf.predict_one(seqs[0])
        assert pred in {"happy", "sad"}
        assert set(scores.keys()) == {"happy", "sad"}
        assert all(np.isfinite(v) for v in scores.values())

    def test_predict_batch_shape(self, rng):
        seqs, labels = self._make_two_class_data(rng)
        clf = EmotionHMMClassifier(n_states=2, n_symbols=3, n_iter=15, random_seed=0)
        clf.fit(seqs, labels)
        preds, all_scores = clf.predict(seqs[:4])
        assert len(preds) == 4
        assert len(all_scores) == 4

    def test_classification_above_chance(self, rng):
        # On well-separated classes, accuracy should be very high.
        train_seqs, train_labels = self._make_two_class_data(rng)
        test_seqs, test_labels = self._make_two_class_data(rng)
        clf = EmotionHMMClassifier(n_states=2, n_symbols=3, n_iter=20, random_seed=0)
        clf.fit(train_seqs, train_labels)
        preds, _ = clf.predict(test_seqs)
        acc = np.mean(np.array(preds) == np.array(test_labels))
        assert acc >= 0.8

    def test_length_mismatch_raises(self):
        clf = EmotionHMMClassifier(n_states=2, n_symbols=3)
        with pytest.raises(ValueError, match="same length"):
            clf.fit([np.array([0, 1])], ["a", "b"])

    def test_skips_empty_sequences(self, rng):
        seqs = [np.zeros(0, dtype=np.int64), rng.integers(0, 3, size=50)]
        labels = ["a", "b"]
        clf = EmotionHMMClassifier(n_states=2, n_symbols=3, n_iter=5, random_seed=0)
        clf.fit(seqs, labels)
        # 'a' had no non-empty data so no model should be trained for it
        assert "b" in clf.models
        assert "a" not in clf.models

    def test_predict_with_no_models_returns_unknown(self):
        clf = EmotionHMMClassifier(n_states=2, n_symbols=3)
        # No fit() call -> no models
        pred, scores = clf.predict_one(np.array([0, 1, 2]))
        assert pred == "unknown"
        assert scores == {}
