"""hmm.py — Discrete (Categorical) HMM, implemented from scratch.

A first-order HMM with K hidden states and M observation symbols is
parameterised by three things:

    pi  in R^K            initial state distribution, sum_i pi_i = 1
    A   in R^{K x K}      transition matrix, A[i,j] = P(s_t=j | s_{t-1}=i)
    B   in R^{K x M}      emission matrix, B[i,k] = P(o_t=k | s_t=i)

Three classical algorithms operate on this model:

    Forward-Backward    -> P(O | lambda) and the gamma/xi posteriors needed
                           by Baum-Welch.
    Viterbi             -> argmax over state sequences given an observation.
    Baum-Welch (EM)     -> re-estimate (pi, A, B) from one or more observation
                           sequences with no state labels.

For numerical safety on long sequences we use *rescaling* (Rabiner 1989,
section V.A): at each forward step we divide alpha_t by its row sum c_t.
The likelihood is then log P(O) = sum_t log c_t, and the same c_t are
re-used to scale beta_t. No logarithms in the hot loop.

References
----------
Rabiner, "A tutorial on hidden Markov models and selected applications in
speech recognition", Proc. IEEE 77(2), 1989.
"""
from __future__ import annotations

from typing import List, Tuple

import numpy as np


class DiscreteHMM:
    """First-order discrete HMM with K states and M symbols.

    Parameters
    ----------
    n_states : int
        Number of hidden states K.
    n_symbols : int
        Size of the discrete observation alphabet M (e.g. VQ codebook size).
    n_iter : int
        Maximum number of Baum-Welch iterations.
    tol : float
        Stop when the relative log-likelihood improvement is below `tol`.
    random_state : int | None
        Seed for reproducible random initialisation.
    smoothing : float
        Add-eps Laplace smoothing applied to the emission matrix at each
        M-step. Prevents B[i,k]=0 from making future observations of symbol
        k impossible under state i (a hard-zero sticks forever in EM).
    init : {"random", "uniform"}
        Random uses Dirichlet draws; uniform makes everything 1/K or 1/M.
    """

    def __init__(
        self,
        n_states: int = 3,
        n_symbols: int = 16,
        n_iter: int = 50,
        tol: float = 1e-4,
        random_state: int | None = 42,
        smoothing: float = 1e-3,
        init: str = "random",
    ):
        self.n_states = int(n_states)
        self.n_symbols = int(n_symbols)
        self.n_iter = int(n_iter)
        self.tol = float(tol)
        self.random_state = random_state
        self.smoothing = float(smoothing)
        self.init = init

        # Filled in by fit()
        self.pi: np.ndarray | None = None
        self.A: np.ndarray | None = None
        self.B: np.ndarray | None = None
        self.history_: List[float] = []  # log-likelihood per EM iteration
        self.n_iter_run_: int = 0

    # ------------------------------------------------------------------ #
    # Initialisation
    # ------------------------------------------------------------------ #

    def _initialize(self) -> None:
        K, M = self.n_states, self.n_symbols
        rng = np.random.default_rng(self.random_state)
        if self.init == "uniform":
            self.pi = np.full(K, 1.0 / K)
            self.A = np.full((K, K), 1.0 / K)
            self.B = np.full((K, M), 1.0 / M)
        elif self.init == "random":
            self.pi = rng.dirichlet(np.ones(K))
            self.A = rng.dirichlet(np.ones(K), size=K)
            self.B = rng.dirichlet(np.ones(M), size=K)
        else:
            raise ValueError(f"Unknown init: {self.init}")

    # ------------------------------------------------------------------ #
    # Forward / backward with rescaling
    # ------------------------------------------------------------------ #

    def _forward(self, obs: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        """Scaled forward pass.

        Returns
        -------
        alpha_hat : (T, K) array.  alpha_hat[t,i] = P(s_t=i | o_{1..t}).
        c : (T,) array of scale factors.  c[t] = P(o_t | o_{1..t-1}),
            so log P(O) = sum_t log c[t].
        """
        T = len(obs)
        K = self.n_states
        alpha = np.empty((T, K))
        c = np.empty(T)

        # t = 0
        alpha[0] = self.pi * self.B[:, obs[0]]
        s = alpha[0].sum()
        c[0] = s if s > 0 else 1e-300
        alpha[0] /= c[0]

        # t = 1..T-1
        for t in range(1, T):
            # alpha_unscaled_t(i) = sum_j alpha_hat_{t-1}(j) * A[j,i] * B[i, o_t]
            alpha[t] = (alpha[t - 1] @ self.A) * self.B[:, obs[t]]
            s = alpha[t].sum()
            c[t] = s if s > 0 else 1e-300
            alpha[t] /= c[t]

        return alpha, c

    def _backward(self, obs: np.ndarray, c: np.ndarray) -> np.ndarray:
        """Scaled backward pass using forward's scale factors.

        Returns beta_hat such that gamma_t(i) = alpha_hat_t(i) * beta_hat_t(i) * c_t.
        """
        T = len(obs)
        K = self.n_states
        beta = np.empty((T, K))
        beta[T - 1] = 1.0 / c[T - 1]
        for t in range(T - 2, -1, -1):
            beta[t] = self.A @ (self.B[:, obs[t + 1]] * beta[t + 1])
            beta[t] /= c[t]
        return beta

    # ------------------------------------------------------------------ #
    # Public inference
    # ------------------------------------------------------------------ #

    def score(self, obs: np.ndarray) -> float:
        """Log-likelihood log P(O | lambda)."""
        self._check_fitted()
        obs = self._check_obs(obs)
        if len(obs) == 0:
            return 0.0
        _, c = self._forward(obs)
        return float(np.sum(np.log(c)))

    def predict_states(self, obs: np.ndarray) -> np.ndarray:
        """Viterbi: argmax over state sequences. Implemented in log-space
        because the scaled forward variables don't give us the joint."""
        self._check_fitted()
        obs = self._check_obs(obs)
        T = len(obs)
        K = self.n_states
        if T == 0:
            return np.zeros(0, dtype=np.int64)
        eps = 1e-300
        log_pi = np.log(self.pi + eps)
        log_A = np.log(self.A + eps)
        log_B = np.log(self.B + eps)

        delta = np.empty((T, K))
        psi = np.empty((T, K), dtype=np.int64)
        delta[0] = log_pi + log_B[:, obs[0]]
        psi[0] = 0
        for t in range(1, T):
            scores = delta[t - 1][:, None] + log_A  # (K_prev, K_curr)
            psi[t] = np.argmax(scores, axis=0)
            delta[t] = np.max(scores, axis=0) + log_B[:, obs[t]]

        states = np.empty(T, dtype=np.int64)
        states[T - 1] = int(np.argmax(delta[T - 1]))
        for t in range(T - 2, -1, -1):
            states[t] = psi[t + 1, states[t + 1]]
        return states

    # ------------------------------------------------------------------ #
    # Baum-Welch (EM) training over multiple sequences
    # ------------------------------------------------------------------ #

    def fit(self, sequences: List[np.ndarray]) -> "DiscreteHMM":
        """Estimate (pi, A, B) from a list of observation sequences."""
        # Sanitise input
        seqs = [np.asarray(s, dtype=np.int64).reshape(-1) for s in sequences]
        seqs = [s for s in seqs if len(s) > 0]
        if not seqs:
            raise ValueError("DiscreteHMM.fit got no non-empty sequences")
        max_obs = max(int(s.max()) for s in seqs)
        if max_obs >= self.n_symbols:
            raise ValueError(
                f"Observation index {max_obs} >= n_symbols={self.n_symbols}; "
                "did you size the codebook correctly?"
            )

        self._initialize()
        K, M = self.n_states, self.n_symbols
        prev_ll = -np.inf
        self.history_ = []

        for it in range(self.n_iter):
            # ----------- E-step accumulators (across all sequences) ----- #
            pi_num = np.zeros(K)
            A_num = np.zeros((K, K))
            A_den = np.zeros(K)
            B_num = np.zeros((K, M))
            B_den = np.zeros(K)
            total_ll = 0.0

            for obs in seqs:
                T = len(obs)
                alpha, c = self._forward(obs)
                beta = self._backward(obs, c)
                total_ll += float(np.sum(np.log(c)))

                # gamma_t(i) = alpha_hat_t(i) * beta_hat_t(i) * c_t
                # (sums to 1 over i for each t; see derivation in docstring)
                gamma = alpha * beta * c[:, None]  # (T, K)

                pi_num += gamma[0]

                # xi_t(i,j) = alpha_hat_t(i) * A[i,j] * B[j, o_{t+1}] * beta_hat_{t+1}(j)
                # Vectorised over t in [0, T-2]
                if T > 1:
                    # Shape (T-1, K, K)
                    emit_next = self.B[:, obs[1:]].T  # (T-1, K)
                    # outer product per t: alpha[t,:,None] * (A * (emit_next[t] * beta[t+1])[None,:])
                    # Build (T-1, K, K) via broadcasting:
                    rhs = self.A[None, :, :] * (emit_next * beta[1:])[:, None, :]
                    xi = alpha[:-1, :, None] * rhs  # (T-1, K, K)
                    A_num += xi.sum(axis=0)
                    A_den += gamma[:-1].sum(axis=0)

                # B accumulator: bin gamma by observation symbol
                # np.add.at handles repeated indices correctly
                np.add.at(B_num.T, obs, gamma)  # B_num.T has shape (M, K)
                B_den += gamma.sum(axis=0)

            # ----------- M-step ----------------------------------------- #
            # pi: average of gamma_0 over sequences
            self.pi = pi_num / len(seqs)
            self.pi /= max(self.pi.sum(), 1e-300)

            # A: row-normalised expected transition counts.
            # If a state was never visited (A_den[i]=0) we keep a uniform row.
            new_A = np.where(
                A_den[:, None] > 0,
                A_num / np.where(A_den[:, None] > 0, A_den[:, None], 1.0),
                1.0 / K,
            )
            new_A /= new_A.sum(axis=1, keepdims=True)
            self.A = new_A

            # B: row-normalised expected emission counts, with Laplace smoothing.
            new_B = (B_num + self.smoothing) / (
                B_den[:, None] + self.smoothing * M
            )
            new_B /= new_B.sum(axis=1, keepdims=True)
            self.B = new_B

            # ----------- Convergence check ------------------------------ #
            self.history_.append(total_ll)
            self.n_iter_run_ = it + 1
            if it > 0:
                rel = (total_ll - prev_ll) / (abs(prev_ll) + 1e-12)
                if rel < self.tol:
                    break
            prev_ll = total_ll

        return self

    # ------------------------------------------------------------------ #
    # Helpers
    # ------------------------------------------------------------------ #

    def _check_fitted(self) -> None:
        if self.pi is None or self.A is None or self.B is None:
            raise RuntimeError("DiscreteHMM has not been fit yet")

    def _check_obs(self, obs) -> np.ndarray:
        obs = np.asarray(obs, dtype=np.int64).reshape(-1)
        if obs.size > 0:
            if int(obs.max()) >= self.n_symbols or int(obs.min()) < 0:
                raise ValueError(
                    f"Observation indices must be in [0, {self.n_symbols}); "
                    f"got min={obs.min()}, max={obs.max()}"
                )
        return obs
