"""gmm_hmm.py — Hidden Markov Model with Gaussian Mixture emissions.

A first-order HMM with K hidden states. Each state i has its own GMM
emission with M mixture components in D dimensions (diagonal covariance):

    p(o | s = i) = sum_{m=1..M} w_{i,m} N(o | mu_{i,m}, diag(sigma2_{i,m}))

Parameterisation (matches `hmm.py` for pi and A):

    pi      in R^K               initial state distribution
    A       in R^{K x K}         transition matrix
    weights in R^{K x M}         mixture weights per state, rows sum to 1
    means   in R^{K x M x D}     mixture means
    covars  in R^{K x M x D}     mixture variances (diagonal)

Training: Baum-Welch EM, fully in log-space to avoid underflow on long
sequences. We separately accumulate per-state-per-component posteriors
gamma_t(i, m) so we can re-estimate the GMM parameters along with pi/A.

Numerical safety
----------------
1. All forward/backward computations use log-space + scipy logsumexp.
2. Variances are floored at `var_floor` (relative to the data variance)
   to prevent a Gaussian from collapsing onto a single training frame.
3. Mixture weights and transitions get a small smoothing constant.
4. K-means initialisation: K-state assignment via k-means on all training
   data, then per-state k-means to seed the M mixture means.

References
----------
Rabiner 1989 §VI (continuous-density HMMs); Bilmes "A Gentle Tutorial on
the EM algorithm and its application to GMMs and HMMs", 1998.
"""
from __future__ import annotations

from typing import List, Tuple

import numpy as np
from scipy.special import logsumexp
from sklearn.cluster import KMeans

LOG_2PI = float(np.log(2.0 * np.pi))


def _log_gaussian_diag(
    X: np.ndarray, means: np.ndarray, covars: np.ndarray
) -> np.ndarray:
    """Log-pdf of N(X | means, diag(covars)) for every component.

    Parameters
    ----------
    X      : (T, D)
    means  : (M, D)
    covars : (M, D), strictly positive

    Returns
    -------
    log_p : (T, M) where log_p[t, m] = log N(X[t] | means[m], diag(covars[m])).
    """
    T, D = X.shape
    inv = 1.0 / covars  # (M, D)
    # log determinant: sum of log variances along D
    logdet = np.sum(np.log(covars), axis=1)  # (M,)
    # Mahalanobis distance per (t, m): (X[t]-mu_m)^T diag(1/sigma2_m) (X[t]-mu_m)
    diff = X[:, None, :] - means[None, :, :]  # (T, M, D)
    mahal = np.sum(diff * diff * inv[None, :, :], axis=2)  # (T, M)
    return -0.5 * (D * LOG_2PI + logdet[None, :] + mahal)


class GMMHMM:
    """HMM with diagonal-covariance GMM emissions per state.

    Parameters
    ----------
    n_states : int
        Number of hidden states K.
    n_mix : int
        Mixture components per state.
    n_iter : int
        Maximum Baum-Welch iterations.
    tol : float
        Stop when relative LL improvement drops below this.
    var_floor : float
        Variance floor as a fraction of the global feature variance.
        Standard speech values are 1e-3 to 1e-2.
    weight_floor : float
        Lower bound on mixture weights (Laplace-style smoothing).
    random_state : int | None
        Seed for k-means and any other randomness.
    n_kmeans_init : int
        Number of k-means restarts during initialisation.
    """

    def __init__(
        self,
        n_states: int = 3,
        n_mix: int = 4,
        n_iter: int = 30,
        tol: float = 1e-4,
        var_floor: float = 1e-3,
        weight_floor: float = 1e-3,
        random_state: int | None = 42,
        n_kmeans_init: int = 5,
    ):
        self.n_states = int(n_states)
        self.n_mix = int(n_mix)
        self.n_iter = int(n_iter)
        self.tol = float(tol)
        self.var_floor = float(var_floor)
        self.weight_floor = float(weight_floor)
        self.random_state = random_state
        self.n_kmeans_init = int(n_kmeans_init)

        # Filled in by fit()
        self.pi: np.ndarray | None = None
        self.A: np.ndarray | None = None
        self.weights: np.ndarray | None = None  # (K, M)
        self.means: np.ndarray | None = None  # (K, M, D)
        self.covars: np.ndarray | None = None  # (K, M, D)
        self._var_floor_abs: np.ndarray | None = None  # (D,)
        self.history_: List[float] = []
        self.n_iter_run_: int = 0

    # ------------------------------------------------------------------ #
    # Initialisation: k-means -> per-state k-means
    # ------------------------------------------------------------------ #

    def _initialize(self, X_all: np.ndarray) -> None:
        K, M = self.n_states, self.n_mix
        N, D = X_all.shape

        # Variance floor in absolute units, derived from the data
        global_var = X_all.var(axis=0) + 1e-12
        self._var_floor_abs = self.var_floor * global_var

        # Step 1: cluster all frames into K groups -> initial state assignment
        km_state = KMeans(
            n_clusters=K,
            n_init=self.n_kmeans_init,
            random_state=self.random_state,
        ).fit(X_all)
        state_labels = km_state.labels_  # (N,)

        # Step 2: for each state i, fit a GMM via per-state k-means for the means
        self.weights = np.full((K, M), 1.0 / M)
        self.means = np.zeros((K, M, D))
        self.covars = np.zeros((K, M, D))

        for i in range(K):
            Xi = X_all[state_labels == i]
            if len(Xi) < M:
                # Not enough points: fall back to the global means with jitter
                rng = np.random.default_rng(
                    None if self.random_state is None else self.random_state + i
                )
                self.means[i] = X_all.mean(axis=0)[None, :] + 0.01 * rng.standard_normal(
                    (M, D)
                ) * np.sqrt(global_var)
                self.covars[i] = np.tile(global_var, (M, 1))
                continue

            seed = (
                None if self.random_state is None else self.random_state + i + 1000
            )
            km_mix = KMeans(
                n_clusters=M, n_init=self.n_kmeans_init, random_state=seed
            ).fit(Xi)
            self.means[i] = km_mix.cluster_centers_

            # Per-component variance from k-means assignments
            for m in range(M):
                Xim = Xi[km_mix.labels_ == m]
                if len(Xim) > 1:
                    v = Xim.var(axis=0)
                else:
                    v = global_var.copy()
                self.covars[i, m] = np.maximum(v, self._var_floor_abs)
                self.weights[i, m] = max(len(Xim), 1) / max(len(Xi), 1)
            # Normalise weights for state i
            self.weights[i] = np.maximum(self.weights[i], self.weight_floor)
            self.weights[i] /= self.weights[i].sum()

        # Initial state distribution and transition matrix:
        # use the empirical first-state frequencies and one-step transitions
        # along the k-means state labels (works fine across multi-utterance
        # batches when this is called with all frames stacked).
        self.pi = np.full(K, 1.0 / K)
        self.A = np.full((K, K), 1.0 / K)

    # ------------------------------------------------------------------ #
    # Per-frame log-emission p(o_t | s_t = i) and per-component breakdown
    # ------------------------------------------------------------------ #

    def _log_emissions(self, X: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """Compute log b_i(o_t) and log component responsibilities.

        Returns
        -------
        log_b : (T, K)            log p(o_t | s_t = i) summed over mixtures
        log_comp : (T, K, M)      log[w_{i,m} * N(o_t | mu_{i,m}, ...)]
                                   so that logsumexp_m log_comp[t, i, :] == log_b[t, i]
        """
        T, D = X.shape
        K, M = self.n_states, self.n_mix
        log_w = np.log(self.weights + 1e-300)  # (K, M)
        log_comp = np.empty((T, K, M))
        for i in range(K):
            log_g = _log_gaussian_diag(X, self.means[i], self.covars[i])  # (T, M)
            log_comp[:, i, :] = log_w[i][None, :] + log_g
        log_b = logsumexp(log_comp, axis=2)  # (T, K)
        return log_b, log_comp

    # ------------------------------------------------------------------ #
    # Forward / backward in log-space
    # ------------------------------------------------------------------ #

    def _forward_log(
        self, log_b: np.ndarray
    ) -> Tuple[np.ndarray, float]:
        """log_alpha[t, i] = log P(o_{1..t}, s_t = i). Returns log P(O)."""
        T, K = log_b.shape
        log_pi = np.log(self.pi + 1e-300)
        log_A = np.log(self.A + 1e-300)
        log_alpha = np.empty((T, K))
        log_alpha[0] = log_pi + log_b[0]
        for t in range(1, T):
            # log_alpha[t, i] = logsumexp_j(log_alpha[t-1, j] + log_A[j, i]) + log_b[t, i]
            log_alpha[t] = logsumexp(log_alpha[t - 1][:, None] + log_A, axis=0) + log_b[t]
        log_likelihood = float(logsumexp(log_alpha[T - 1]))
        return log_alpha, log_likelihood

    def _backward_log(self, log_b: np.ndarray) -> np.ndarray:
        """log_beta[t, i] = log P(o_{t+1..T} | s_t = i)."""
        T, K = log_b.shape
        log_A = np.log(self.A + 1e-300)
        log_beta = np.zeros((T, K))  # log_beta[T-1] = 0 (i.e. beta = 1)
        for t in range(T - 2, -1, -1):
            # log_beta[t, i] = logsumexp_j(log_A[i, j] + log_b[t+1, j] + log_beta[t+1, j])
            log_beta[t] = logsumexp(
                log_A + (log_b[t + 1] + log_beta[t + 1])[None, :], axis=1
            )
        return log_beta

    # ------------------------------------------------------------------ #
    # Public inference
    # ------------------------------------------------------------------ #

    def score(self, X: np.ndarray) -> float:
        """Log-likelihood log P(X | lambda)."""
        self._check_fitted()
        X = np.asarray(X, dtype=np.float64)
        if X.ndim != 2:
            raise ValueError("X must be (T, D)")
        if X.shape[0] == 0:
            return 0.0
        log_b, _ = self._log_emissions(X)
        _, ll = self._forward_log(log_b)
        return ll

    def predict_states(self, X: np.ndarray) -> np.ndarray:
        """Viterbi over hidden states (mixtures are marginalised out)."""
        self._check_fitted()
        X = np.asarray(X, dtype=np.float64)
        T = X.shape[0]
        K = self.n_states
        if T == 0:
            return np.zeros(0, dtype=np.int64)
        log_pi = np.log(self.pi + 1e-300)
        log_A = np.log(self.A + 1e-300)
        log_b, _ = self._log_emissions(X)

        delta = np.empty((T, K))
        psi = np.empty((T, K), dtype=np.int64)
        delta[0] = log_pi + log_b[0]
        psi[0] = 0
        for t in range(1, T):
            scores = delta[t - 1][:, None] + log_A
            psi[t] = np.argmax(scores, axis=0)
            delta[t] = np.max(scores, axis=0) + log_b[t]
        states = np.empty(T, dtype=np.int64)
        states[T - 1] = int(np.argmax(delta[T - 1]))
        for t in range(T - 2, -1, -1):
            states[t] = psi[t + 1, states[t + 1]]
        return states

    # ------------------------------------------------------------------ #
    # Baum-Welch over multiple sequences
    # ------------------------------------------------------------------ #

    def fit(self, sequences: List[np.ndarray]) -> "GMMHMM":
        """Estimate parameters from a list of (T_n, D) feature matrices."""
        seqs: List[np.ndarray] = []
        for s in sequences:
            s = np.asarray(s, dtype=np.float64)
            if s.ndim == 2 and s.shape[0] > 0:
                seqs.append(s)
        if not seqs:
            raise ValueError("GMMHMM.fit got no non-empty sequences")
        D = seqs[0].shape[1]
        for s in seqs:
            if s.shape[1] != D:
                raise ValueError(
                    f"All sequences must share the same feature dim; got {s.shape[1]} vs {D}"
                )

        X_all = np.concatenate(seqs, axis=0)
        self._initialize(X_all)

        K, M = self.n_states, self.n_mix
        prev_ll = -np.inf
        self.history_ = []

        log_pi_floor = -np.inf  # not used; keep semantics simple
        for it in range(self.n_iter):
            # ---------- E-step accumulators ---------- #
            pi_num = np.zeros(K)
            A_num = np.zeros((K, K))
            A_den = np.zeros(K)
            comp_resp_sum = np.zeros((K, M))  # sum_t gamma_t(i, m)
            comp_mean_num = np.zeros((K, M, D))  # sum_t gamma_t(i,m) * o_t
            comp_var_num = np.zeros((K, M, D))  # sum_t gamma_t(i,m) * o_t^2
            total_ll = 0.0

            log_A = np.log(self.A + 1e-300)

            for X in seqs:
                T = X.shape[0]
                log_b, log_comp = self._log_emissions(X)
                log_alpha, ll = self._forward_log(log_b)
                log_beta = self._backward_log(log_b)
                total_ll += ll

                # gamma_t(i) = exp(log_alpha + log_beta - ll)
                log_gamma = log_alpha + log_beta - ll  # (T, K)
                gamma = np.exp(log_gamma)

                # Per-component posteriors:
                # gamma_t(i, m) = gamma_t(i) * w_{i,m} N(o_t|...)/ b_i(o_t)
                # In log-space: log_gamma_t(i,m) = log_gamma_t(i) + log_comp[t,i,m] - log_b[t,i]
                log_comp_resp = (
                    log_gamma[:, :, None] + log_comp - log_b[:, :, None]
                )
                comp_resp = np.exp(log_comp_resp)  # (T, K, M)

                # Initial state contribution
                pi_num += gamma[0]

                # Transition contributions
                if T > 1:
                    # log_xi[t, i, j] = log_alpha[t, i] + log_A[i, j] + log_b[t+1, j]
                    #                   + log_beta[t+1, j] - ll
                    log_xi = (
                        log_alpha[:-1, :, None]
                        + log_A[None, :, :]
                        + (log_b[1:] + log_beta[1:])[:, None, :]
                        - ll
                    )
                    xi = np.exp(log_xi)
                    A_num += xi.sum(axis=0)
                    A_den += gamma[:-1].sum(axis=0)

                # Mixture stats
                # comp_resp shape (T, K, M); X shape (T, D)
                comp_resp_sum += comp_resp.sum(axis=0)  # (K, M)
                # einsum: sum_t resp[t,i,m] * X[t,d] -> (K, M, D)
                comp_mean_num += np.einsum("tim,td->imd", comp_resp, X)
                comp_var_num += np.einsum("tim,td->imd", comp_resp, X * X)

            # ---------- M-step ---------- #
            # pi
            self.pi = pi_num / max(len(seqs), 1)
            self.pi = np.maximum(self.pi, 1e-300)
            self.pi /= self.pi.sum()

            # A
            new_A = np.where(
                A_den[:, None] > 0,
                A_num / np.where(A_den[:, None] > 0, A_den[:, None], 1.0),
                1.0 / K,
            )
            new_A = np.maximum(new_A, 1e-300)
            new_A /= new_A.sum(axis=1, keepdims=True)
            self.A = new_A

            # Mixture weights, means, variances
            state_resp = comp_resp_sum.sum(axis=1, keepdims=True)  # (K, 1)
            state_resp_safe = np.where(state_resp > 0, state_resp, 1.0)
            new_weights = comp_resp_sum / state_resp_safe
            new_weights = np.maximum(new_weights, self.weight_floor)
            new_weights /= new_weights.sum(axis=1, keepdims=True)

            comp_resp_safe = np.where(comp_resp_sum > 0, comp_resp_sum, 1.0)
            new_means = comp_mean_num / comp_resp_safe[:, :, None]
            # Var = E[X^2] - mu^2 (computed per component)
            new_var = comp_var_num / comp_resp_safe[:, :, None] - new_means ** 2
            # Where a component had zero responsibility, keep the old value
            no_data = (comp_resp_sum == 0)[:, :, None]
            new_means = np.where(no_data, self.means, new_means)
            new_var = np.where(no_data, self.covars, new_var)
            # Floor variance
            new_var = np.maximum(new_var, self._var_floor_abs[None, None, :])

            self.weights = new_weights
            self.means = new_means
            self.covars = new_var

            # ---------- Convergence ---------- #
            self.history_.append(total_ll)
            self.n_iter_run_ = it + 1
            if it > 0:
                rel = (total_ll - prev_ll) / (abs(prev_ll) + 1e-12)
                if abs(rel) < self.tol:
                    break
            prev_ll = total_ll

        return self

    # ------------------------------------------------------------------ #
    # Helpers
    # ------------------------------------------------------------------ #

    def _check_fitted(self) -> None:
        if (
            self.pi is None
            or self.A is None
            or self.weights is None
            or self.means is None
            or self.covars is None
        ):
            raise RuntimeError("GMMHMM has not been fit yet")
