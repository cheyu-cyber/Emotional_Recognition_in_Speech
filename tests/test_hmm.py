"""Tests for core/hmm.py — the from-scratch DiscreteHMM."""
from __future__ import annotations

import numpy as np
import pytest

from hmm import DiscreteHMM


def _sample_from_hmm(pi, A, B, T, rng):
    """Generate one observation sequence from a known HMM."""
    K = len(pi)
    states = np.empty(T, dtype=np.int64)
    obs = np.empty(T, dtype=np.int64)
    states[0] = rng.choice(K, p=pi)
    obs[0] = rng.choice(B.shape[1], p=B[states[0]])
    for t in range(1, T):
        states[t] = rng.choice(K, p=A[states[t - 1]])
        obs[t] = rng.choice(B.shape[1], p=B[states[t]])
    return obs


class TestInit:
    def test_uniform_init(self):
        m = DiscreteHMM(n_states=3, n_symbols=4, init="uniform")
        m._initialize()
        np.testing.assert_allclose(m.pi, 1 / 3)
        np.testing.assert_allclose(m.A, 1 / 3)
        np.testing.assert_allclose(m.B, 1 / 4)

    def test_random_init_normalized(self):
        m = DiscreteHMM(n_states=3, n_symbols=4, init="random", random_state=0)
        m._initialize()
        assert m.pi.sum() == pytest.approx(1.0)
        np.testing.assert_allclose(m.A.sum(axis=1), 1.0)
        np.testing.assert_allclose(m.B.sum(axis=1), 1.0)

    def test_unknown_init_raises(self):
        m = DiscreteHMM(n_states=3, n_symbols=4, init="bogus")
        with pytest.raises(ValueError, match="Unknown init"):
            m._initialize()


class TestForwardBackward:
    def _setup(self):
        m = DiscreteHMM(n_states=2, n_symbols=2, random_state=0)
        m.pi = np.array([0.6, 0.4])
        m.A = np.array([[0.7, 0.3], [0.4, 0.6]])
        m.B = np.array([[0.5, 0.5], [0.1, 0.9]])
        return m

    def test_forward_alpha_normalized(self):
        m = self._setup()
        obs = np.array([0, 1, 0, 1, 1])
        alpha, c = m._forward(obs)
        np.testing.assert_allclose(alpha.sum(axis=1), 1.0, atol=1e-12)
        assert c.shape == (5,)
        assert (c > 0).all()

    def test_score_matches_brute_force(self):
        # P(O) = sum over all state paths: product of transitions and emissions.
        m = self._setup()
        obs = np.array([0, 1, 0])
        K = m.n_states
        T = len(obs)
        total = 0.0
        for s0 in range(K):
            for s1 in range(K):
                for s2 in range(K):
                    p = (
                        m.pi[s0] * m.B[s0, obs[0]]
                        * m.A[s0, s1] * m.B[s1, obs[1]]
                        * m.A[s1, s2] * m.B[s2, obs[2]]
                    )
                    total += p
        ll = m.score(obs)
        assert ll == pytest.approx(np.log(total), rel=1e-9)

    def test_score_empty_sequence(self):
        m = self._setup()
        assert m.score(np.zeros(0, dtype=np.int64)) == 0.0


class TestViterbi:
    def test_predict_states_known_solution(self):
        # Highly diagonal A, peaky B: Viterbi should follow the maximum-emission states.
        m = DiscreteHMM(n_states=2, n_symbols=2)
        m.pi = np.array([0.5, 0.5])
        m.A = np.array([[0.9, 0.1], [0.1, 0.9]])
        m.B = np.array([[0.95, 0.05], [0.05, 0.95]])
        obs = np.array([0, 0, 0, 1, 1, 1])
        states = m.predict_states(obs)
        np.testing.assert_array_equal(states, [0, 0, 0, 1, 1, 1])

    def test_predict_states_shape_and_dtype(self):
        m = DiscreteHMM(n_states=3, n_symbols=4, random_state=0, init="uniform")
        m._initialize()
        states = m.predict_states(np.array([0, 1, 2, 3, 0]))
        assert states.shape == (5,)
        assert states.dtype == np.int64
        assert states.min() >= 0 and states.max() < 3

    def test_predict_states_empty(self):
        m = DiscreteHMM(n_states=2, n_symbols=2, init="uniform")
        m._initialize()
        out = m.predict_states(np.zeros(0, dtype=np.int64))
        assert out.shape == (0,)


class TestFit:
    def test_recovers_likelihood_increases(self, rng):
        # Fit on data sampled from a true HMM and check log-likelihood is monotone non-decreasing.
        true_pi = np.array([0.7, 0.3])
        true_A = np.array([[0.8, 0.2], [0.3, 0.7]])
        true_B = np.array([[0.7, 0.2, 0.1], [0.1, 0.3, 0.6]])
        seqs = [
            _sample_from_hmm(true_pi, true_A, true_B, T=200, rng=rng)
            for _ in range(20)
        ]
        m = DiscreteHMM(
            n_states=2, n_symbols=3, n_iter=30, tol=1e-6, random_state=0
        )
        m.fit(seqs)
        # EM never decreases the lower bound; allow tiny numerical slack.
        diffs = np.diff(m.history_)
        assert (diffs >= -1e-6).all()
        assert m.n_iter_run_ >= 1

    def test_fit_preserves_simplex(self, rng):
        seqs = [rng.integers(0, 4, size=120) for _ in range(5)]
        m = DiscreteHMM(n_states=3, n_symbols=4, n_iter=10, random_state=0).fit(seqs)
        assert m.pi.sum() == pytest.approx(1.0)
        np.testing.assert_allclose(m.A.sum(axis=1), 1.0, atol=1e-12)
        np.testing.assert_allclose(m.B.sum(axis=1), 1.0, atol=1e-12)

    def test_fit_rejects_empty_input(self):
        m = DiscreteHMM(n_states=2, n_symbols=3)
        with pytest.raises(ValueError, match="no non-empty sequences"):
            m.fit([])
        with pytest.raises(ValueError, match="no non-empty sequences"):
            m.fit([np.zeros(0, dtype=np.int64)])

    def test_fit_rejects_out_of_range_symbol(self):
        m = DiscreteHMM(n_states=2, n_symbols=3)
        with pytest.raises(ValueError, match=">= n_symbols"):
            m.fit([np.array([0, 1, 2, 3])])

    def test_classification_with_two_models(self, rng):
        # Train two HMMs on data with different emission profiles; each model
        # should give the higher score to its own data.
        pi = np.array([0.5, 0.5])
        A = np.array([[0.9, 0.1], [0.1, 0.9]])
        B_a = np.array([[0.9, 0.1], [0.5, 0.5]])
        B_b = np.array([[0.1, 0.9], [0.5, 0.5]])

        train_a = [_sample_from_hmm(pi, A, B_a, T=300, rng=rng) for _ in range(5)]
        train_b = [_sample_from_hmm(pi, A, B_b, T=300, rng=rng) for _ in range(5)]

        ma = DiscreteHMM(n_states=2, n_symbols=2, n_iter=30, random_state=0).fit(train_a)
        mb = DiscreteHMM(n_states=2, n_symbols=2, n_iter=30, random_state=1).fit(train_b)

        test_a = _sample_from_hmm(pi, A, B_a, T=400, rng=rng)
        test_b = _sample_from_hmm(pi, A, B_b, T=400, rng=rng)

        assert ma.score(test_a) > mb.score(test_a)
        assert mb.score(test_b) > ma.score(test_b)


class TestObservationValidation:
    def test_score_before_fit_raises(self):
        m = DiscreteHMM(n_states=2, n_symbols=3)
        with pytest.raises(RuntimeError, match="not been fit"):
            m.score(np.array([0, 1]))

    def test_predict_before_fit_raises(self):
        m = DiscreteHMM(n_states=2, n_symbols=3)
        with pytest.raises(RuntimeError, match="not been fit"):
            m.predict_states(np.array([0, 1]))

    def test_score_rejects_out_of_range(self):
        m = DiscreteHMM(n_states=2, n_symbols=3, init="uniform")
        m._initialize()
        with pytest.raises(ValueError, match="must be in"):
            m.score(np.array([0, 5]))
        with pytest.raises(ValueError, match="must be in"):
            m.score(np.array([-1, 1]))
