function esr_basic_plots(x, fs, titleText)
%ESR_BASIC_PLOTS Basic waveform, spectrum, spectrogram, autocorr plots.
if nargin < 3
    titleText = '';
end
x = x(:);
N = length(x);
t = (0:N-1) / fs;

figure('Name', 'Waveform');
plot(t, x, 'r');
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title(['Waveform ' titleText]);

win = blackman(N, 'periodic');
[ps, f] = periodogram(x, win, max(512, 2^nextpow2(N)), fs, 'power');
figure('Name', 'Spectrum');
semilogx(f, 10*log10(ps + eps), 'r');
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title(['Spectrum ' titleText]);

winlen = min(1024, N);
win = blackman(winlen, 'periodic');
hop = max(1, round(winlen / 4));
[~, F, T, STPS] = spectrogram(x, win, winlen-hop, max(512, 2^nextpow2(winlen)), fs, 'power');
figure('Name', 'Spectrogram');
imagesc(T, F, 10*log10(STPS + eps));
axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title(['Spectrogram ' titleText]);
colorbar;

[rx, lags] = xcorr(x, 'coeff');
tau = lags / fs;
figure('Name', 'Autocorrelation');
plot(tau, rx, 'r');
grid on;
xlabel('Delay (s)');
ylabel('Autocorrelation');
title(['Autocorrelation ' titleText]);
end
