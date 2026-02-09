# Emotional_Recognition_in_Speech
NCU Capstone

## Clean demo (audio analysis + cepstrum + HMM)
The cleaned, runnable demo lives in [srcs/core](srcs/core).

### Quick start (MATLAB)
1) Add the folder to your path:
	addpath(fullfile(pwd, 'srcs', 'clean'))
2) Run the demo:
	demo_main

### What the demo shows
- Basic waveform, spectrum, spectrogram, and autocorrelation plots.
- Cepstrum and cepstrogram visualization.
- Simple pitch estimation (autocorrelation).
- MFCC extraction.
- HMM-based emotion recognition using a small subset of the dataset.

### Notes
- The demo uses wav files under [srcs/dataset](srcs/dataset).
- HMM training requires `hmmtrain`, `hmmdecode`, and `kmeans` to be available.
