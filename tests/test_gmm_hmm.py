"""Tests for core/gmm_hmm.py — the from-scratch GMM-HMM."""
from __future__ import annotations

import numpy as np
import pytest

pytest.importorskip("scipy")
pytest.importorskip("sklearn")

from gmm_hmm import GMMHMM, _log_gaussian_diag


def _sample_gmm_hmm(pi, A, weights, means, covars, T, rng):
    """Generate one (T, D) sequence from a known GMM-HMM."""
    K = len(pi)
    M, D = means.shape[1], means.shape[2]
    states = np.empty(T, dtype=np.int64)
    obs = np.empty((T, D))
    states[0] = rng.choice(K, p=pi)
    for t in range(T):
        if t > 0:
            states[t] = rng.choice(K, p=A[states[t - 1]])
        m = rng.choice(M, p=weights[states[t]])
        obs[t] = rng.normal(loc=means[states[t], m], scale=np.sqrt(covars[states[t], m]))
    return obs


class TestLogGaussianDiag:
    def test_matches_scipy_norm(self):
        from scipy.stats import multivariate_normal as mvn

        rng = np.random.default_rng(0)
        D = 3
        X = rng.standard_normal((10, D))
        mean = rng.standard_normal((1, D))
        var = np.abs(rng.standard_normal((1, D))) + 0.1
        log_p = _log_gaussian_diag(X, mean, var)  # (T, 1)
        expected = mvn.logpdf(X, mean=mean[0], cov=np.diag(var[0]))
        np.testing.assert_allclose(log_p[:, 0], expected, atol=1e-9)

    def test_shape(self):
        X = np.zeros((5, 2))
        means = np.zeros((3, 2))
        covars = np.ones((3, 2))
        log_p = _log_gaussian_diag(X, means, covars)
        assert log_p.shape == (5, 3)


class TestInit:
    def test_initialize_shapes(self, rng):
        m = GMMHMM(n_states=2, n_mix=3, random_state=0)
        X = rng.standard_normal((100, 4))
        m._initialize(X)
        assert m.weights.shape == (2, 3)
        assert m.means.shape == (2, 3, 4)
        assert m.covars.shape == (2, 3, 4)
        # Weights are valid probability rows
        np.testing.assert_allclose(m.weights.sum(axis=1), 1.0)
        # Variances are positive
        assert (m.covars > 0).all()


class TestForwardBackward:
    def _setup(self, rng):
        K, M, D = 2, 2, 2
        m = GMMHMM(n_states=K, n_mix=M, random_state=0)
        X_init = rng.standard_normal((50, D))
        m._initialize(X_init)
        # Override pi/A so we have a well-defined model
        m.pi = np.array([0.6, 0.4])
        m.A = np.array([[0.8, 0.2], [0.3, 0.7]])
        return m

    def test_score_returns_finite(self, rng):
        m = self._setup(rng)
        X = rng.standard_normal((30, 2))
        ll = m.score(X)
        assert np.isfinite(ll)

    def test_score_matches_brute_force(self, rng):
        # P(X) = sum over all state paths: product of transitions and emissions.
        m = self._setup(rng)
        X = rng.standard_normal((3, 2))
        K = m.n_states
        log_b, _ = m._log_emissions(X)
        # Brute force log P(X)
        total = 0.0
        for s0 in range(K):
            for s1 in range(K):
                for s2 in range(K):
                    p = (
                        m.pi[s0] * np.exp(log_b[0, s0])
                        * m.A[s0, s1] * np.exp(log_b[1, s1])
                        * m.A[s1, s2] * np.exp(log_b[2, s2])
                    )
                    total += p
        assert m.score(X) == pytest.approx(np.log(total), rel=1e-9)

    def test_score_empty_sequence(self, rng):
        m = self._setup(rng)
        assert m.score(np.zeros((0, 2))) == 0.0


class TestViterbi:
    def test_predict_states_shape(self, rng):
        m = GMMHMM(n_states=3, n_mix=2, random_state=0)
        m._initialize(rng.standard_normal((60, 2)))
        states = m.predict_states(rng.standard_normal((10, 2)))
        assert states.shape == (10,)
        assert states.dtype == np.int64
        assert states.min() >= 0 and states.max() < 3

    def test_predict_states_empty(self, rng):
        m = GMMHMM(n_states=2, n_mix=2, random_state=0)
        m._initialize(rng.standard_normal((40, 2)))
        out = m.predict_states(np.zeros((0, 2)))
        assert out.shape == (0,)


class TestFit:
    def test_likelihood_non_decreasing(self, rng):
        # EM is supposed to be monotone; allow a hair of numerical slack.
        D = 2
        K, M = 2, 2
        true_pi = np.array([0.7, 0.3])
        true_A = np.array([[0.9, 0.1], [0.2, 0.8]])
        true_weights = np.array([[0.6, 0.4], [0.3, 0.7]])
        true_means = np.array([
            [[-3.0, 0.0], [3.0, 0.0]],
            [[0.0, -3.0], [0.0, 3.0]],
        ])
        true_covars = np.full((K, M, D), 0.5)
        seqs = [
            _sample_gmm_hmm(true_pi, true_A, true_weights, true_means, true_covars, T=200, rng=rng)
            for _ in range(8)
        ]
        m = GMMHMM(n_states=K, n_mix=M, n_iter=20, tol=1e-8, random_state=0)
        m.fit(seqs)
        diffs = np.diff(m.history_)
        assert (diffs >= -1e-3).all()
        assert m.n_iter_run_ >= 1

    def test_fit_preserves_simplex(self, rng):
        seqs = [rng.standard_normal((80, 3)) for _ in range(4)]
        m = GMMHMM(n_states=2, n_mix=2, n_iter=5, random_state=0).fit(seqs)
        assert m.pi.sum() == pytest.approx(1.0, abs=1e-9)
        np.testing.assert_allclose(m.A.sum(axis=1), 1.0, atol=1e-9)
        np.testing.assert_allclose(m.weights.sum(axis=1), 1.0, atol=1e-9)

    def test_variance_floor_enforced(self, rng):
        seqs = [rng.standard_normal((80, 2)) for _ in range(4)]
        m = GMMHMM(
            n_states=2, n_mix=2, n_iter=5, var_floor=0.5, random_state=0
        ).fit(seqs)
        # All variances must be at least the absolute floor (0.5 * data var)
        floor = m._var_floor_abs
        assert (m.covars >= floor[None, None, :] - 1e-12).all()

    def test_fit_rejects_empty(self):
        m = GMMHMM(n_states=2, n_mix=2)
        with pytest.raises(ValueError, match="no non-empty sequences"):
            m.fit([])
        with pytest.raises(ValueError, match="no non-empty sequences"):
            m.fit([np.zeros((0, 3))])

    def test_fit_rejects_dim_mismatch(self, rng):
        seqs = [rng.standard_normal((30, 2)), rng.standard_normal((30, 3))]
        m = GMMHMM(n_states=2, n_mix=2)
        with pytest.raises(ValueError, match="same feature dim"):
            m.fit(seqs)

    def test_classification_with_two_models(self, rng):
        # Two well-separated GMM-HMMs; each model should prefer its own data.
        D = 2
        pi = np.array([0.5, 0.5])
        A = np.array([[0.85, 0.15], [0.15, 0.85]])
        weights = np.array([[0.5, 0.5], [0.5, 0.5]])
        means_a = np.array([
            [[-4.0, 0.0], [-4.0, 4.0]],
            [[4.0, 0.0], [4.0, 4.0]],
        ])
        means_b = means_a * -1.0
        covars = np.full((2, 2, D), 0.3)

        train_a = [_sample_gmm_hmm(pi, A, weights, means_a, covars, T=300, rng=rng) for _ in range(5)]
        train_b = [_sample_gmm_hmm(pi, A, weights, means_b, covars, T=300, rng=rng) for _ in range(5)]

        ma = GMMHMM(n_states=2, n_mix=2, n_iter=15, random_state=0).fit(train_a)
        mb = GMMHMM(n_states=2, n_mix=2, n_iter=15, random_state=1).fit(train_b)

        test_a = _sample_gmm_hmm(pi, A, weights, means_a, covars, T=400, rng=rng)
        test_b = _sample_gmm_hmm(pi, A, weights, means_b, covars, T=400, rng=rng)

        assert ma.score(test_a) > mb.score(test_a)
        assert mb.score(test_b) > ma.score(test_b)


class TestUnfittedErrors:
    def test_score_before_fit_raises(self):
        m = GMMHMM(n_states=2, n_mix=2)
        with pytest.raises(RuntimeError, match="not been fit"):
            m.score(np.zeros((5, 2)))

    def test_predict_before_fit_raises(self):
        m = GMMHMM(n_states=2, n_mix=2)
        with pytest.raises(RuntimeError, match="not been fit"):
            m.predict_states(np.zeros((5, 2)))

    def test_score_rejects_1d(self, rng):
        m = GMMHMM(n_states=2, n_mix=2, random_state=0)
        m._initialize(rng.standard_normal((40, 2)))
        with pytest.raises(ValueError, match="X must be"):
            m.score(np.zeros(5))
