# Emotional Speech Recognition — Classical Features + Discrete HMM

Python reimplementation and extension of the existing MATLAB pipeline
(`srcs/core/demo_main.m`). Compares **MFCC**, **LPC**, **LP-cepstral**,
and a **combined** feature representation under a shared 3-state,
16-symbol-codebook discrete HMM classifier.

## 1. Recommended dataset

**Primary recommendation: RAVDESS**
(Ryerson Audio-Visual Database of Emotional Speech and Song)

- 7,356 files, ~1,440 speech-only WAVs, 24 actors (12 M / 12 F), 8 emotions
  (neutral, calm, happy, sad, angry, fearful, disgust, surprised), two
  intensity levels.
- Free, CC BY-NC-SA, native 48 kHz studio quality.
- Filename encodes everything (`03-01-06-01-02-01-12.wav`), so the loader
  in `dataset.py` parses emotion + actor automatically.
- Download: <https://zenodo.org/record/1188976> — grab `Audio_Speech_Actors_01-24.zip`.

**Alternates worth considering**

| Dataset  | Lang | Emotions | Notes                                                  |
|----------|------|----------|--------------------------------------------------------|
| TESS     | EN   | 7        | Two female speakers; cleaner but no speaker variation. |
| CREMA-D  | EN   | 6        | 91 actors; good for speaker-independent generalisation.|
| EMO-DB   | DE   | 7        | German; small (535 utterances) but classic baseline.   |
| SAVEE    | EN   | 7        | Four male speakers; useful as a held-out cross-corpus. |

**Setup**: extract RAVDESS into `data/RAVDESS/` so the WAVs sit
directly under it (any sub-folder structure is fine, the loader walks
recursively).

## 2. Quickstart

```bash
pip install -r requirements.txt
# put RAVDESS WAVs under data/RAVDESS/
python main.py
```

All knobs live in `config.json` — no `argparse`. After the run you get:

```
logs/esr_<timestamp>.log              # full timestamped log
results/results.json                  # accuracy + per-class report + config
plots/accuracy_comparison.png         # bar chart, all 4 feature sets
plots/<feature_set>/confusion_matrix.png
plots/<feature_set>/codebook_usage_train.png
plots/<feature_set>/feature_distribution.png
```

## 3. File map

| File                  | Role                                                            |
|-----------------------|-----------------------------------------------------------------|
| `config.json`         | All hyperparameters; edit and re-run.                           |
| `main.py`             | Orchestrates load -> features -> VQ -> HMM -> plots, per set.   |
| `utils.py`            | Logging, JSON, pickle, timing helpers.                          |
| `framing.py`          | Pre-emphasis, framing/windowing, delta-feature regression.      |
| `dataset.py`          | RAVDESS / folder-per-class loader with speaker-independent split. |
| `mfcc.py`             | Mel filterbank + DCT MFCC, optional deltas / log-energy / CMVN. |
| `lpc.py`              | Autocorrelation method + Levinson-Durbin; spectral envelope util.|
| `lpcc.py`             | LPCC via the standard recursion from LPC.                       |
| `prosodic.py`         | Autocorrelation pitch + short-time log-energy.                  |
| `vq.py`               | k-means VQ codebook (16 by default).                            |
| `hmm.py`              | From-scratch discrete HMM: Forward, Backward, Viterbi, Baum-Welch. |
| `hmm_classifier.py`   | One DiscreteHMM per class; argmax-of-log-likelihood predict.    |
| `visualize.py`        | Confusion matrices, accuracy bars, codebook usage plots.        |

## 4. Things you didn't list that would strengthen the project

These are ordered roughly by impact-per-effort:

1. **Speaker-independent splits.** Already on by default
   (`dataset.speaker_independent: true`). Otherwise the HMM can
   memorise speaker identity and accuracy becomes meaningless. RAVDESS
   has 24 actors — split actors, not files.
2. **Statistical significance.** Set `experiments.n_repeats` and run
   k-fold CV across actors (e.g. leave-2-actors-out). Report mean ± std
   accuracy and a paired McNemar test between feature sets — your
   "comparative table" needs error bars to be defensible.
3. **Continuous (GMM-)HMM as an alternative.** Discrete HMM with a
   16-codeword VQ throws away most of the cepstral resolution. Add a
   `hmmlearn.hmm.GaussianHMM` variant; this typically gains 5–15%
   absolute accuracy and is the more common choice in the literature.
4. **Voice-quality features.** Jitter, shimmer, harmonics-to-noise
   ratio. These are emotion-discriminative on their own and complement
   spectral envelopes — easy to add in a `voice_quality.py` module
   (use Praat via `parselmouth`).
5. **Spectral shape stats.** Spectral centroid, rolloff, flux, flatness.
   Cheap to compute, often improve the "combined" set.
6. **Functionals over time.** HMMs model dynamics, but utterance-level
   functionals (mean, std, range, slope of pitch / energy / formants)
   are exactly what eGeMAPS uses and what almost every emotion-
   recognition paper since 2010 reports. Add an SVM or random-forest
   baseline on functionals — you want a non-HMM number to anchor your
   comparison.
7. **Voice activity detection.** `librosa.effects.trim` is a
   peak-energy hack. Webrtcvad or `pyannote.audio` give frame-level VAD
   and remove silences inside utterances, not just at the edges.
8. **Per-frame normalisation.** CMVN (already on for MFCC) should be
   applied to LPCC too — without it, an utterance with louder average
   energy biases the codebook. Worth ablating.
9. **Codebook size sensitivity.** 16 is a legacy choice. Try
   {8, 16, 32, 64, 128} — the optimum depends on feature dimensionality.
   Plot accuracy vs K. Cheap experiment, good chart for the report.
10. **HMM topology.** Left-to-right vs ergodic. For phoneme-level units
    left-to-right wins; for emotion (utterance-level prosody) ergodic
    often does better. `hmmlearn.CategoricalHMM` is ergodic by default;
    you can constrain `transmat_` after `init_params` to enforce
    left-to-right and compare.
11. **Cross-corpus eval.** Train on RAVDESS, test on TESS or EMO-DB.
    This is the question reviewers always ask, and a single
    add-another-config-block change for you.
12. **LPC order sweep.** The proposal says order 10–14. At 16 kHz the
    rule of thumb is `2 + sample_rate/1000` ≈ 18, so sweep {10, 12, 14,
    16, 18} and report — defensible against the question
    "why 12?".
13. **Reflection (PARCOR) coefficients.** `lpc.frame_lpc` already
    returns these. Bounded in [-1, 1], much better-behaved
    statistically than raw LPC coefs — try them as an alternative
    feature, costs nothing extra.
14. **Caching.** Feature extraction dominates wall-clock once you sweep
    hyperparameters. The `output.cache_features` flag is reserved in
    the config — wire it to pickle per-utterance feature matrices keyed
    by file path + framing config hash. Saves hours during the report
    phase.
15. **Confusion-matrix qualitative analysis.** Most failure modes will
    be sad↔neutral and angry↔happy (low/high-arousal pairs that share
    valence). Report which pairs confuse most and tie that back to
    what each feature representation captures (LPC for vocal tract
    shape, prosodic for arousal). That's the "demonstrate whether LPC
    offers complementary information" claim from your proposal,
    actually defended.

## 5. Reproducing the existing MATLAB results

Mirror the MATLAB defaults by setting in `config.json`:

```json
"vq":  { "n_clusters": 16 },
"hmm": { "n_states": 3, "n_iter": 20 },
"mfcc": { "n_mfcc": 12 }
```

These are already the defaults. The Python pipeline should reproduce
the MATLAB MFCC-only number to within VQ initialisation noise. Then
flip on `lpc` and `lpcc` to get the new numbers your proposal promises.
