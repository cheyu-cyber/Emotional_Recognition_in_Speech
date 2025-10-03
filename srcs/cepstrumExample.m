clear, clc, close all
% load a sound file
[x, fs] = audioread('forward.wav');  % load an audio file
x = x(:, 1);                        % get the first channel
x = x/max(abs(x));                  % normalize the signal
N = length(x);                      % signal length
t = (0:N-1)/fs;                     % time vector
% spectral analysis
win = hanning(N, 'periodic');
[PS, f] = periodogram(x, win, N, fs, 'power');
Xm = 20*log10(sqrt(PS)*sqrt(2));
% convert the frequency to kHz
f = f/1000;   
% cepstral analysis
[C, q] = cepstrum(x, fs);
% convert the quefrency to ms
q = q*1000;                         
% time domain analysis
figure(1)
subplot(3, 1, 1)
plot(t, x, 'r')
xlim([0 max(t)])
ylim([-1.1*max(abs(x)) 1.1*max(abs(x))])
grid on
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Time, s')
ylabel('Normalized amplitude')
title('The signal in the time domain')
% plot of the spectrum
subplot(3, 1, 2)
plot(f, Xm, 'r')
grid on
xlim([0 max(f)])
ylim([min(Xm)-10 max(Xm)+10])
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
title('Amplitude spectrum of the signal')
xlabel('Frequency, kHz')
ylabel('Magnitude, dB')
% plot of the cepstrum
% quefrencies from 1 ms (1000 Hz) to 50 ms (20 Hz)
subplot(3, 1, 3)
plot(q, C, 'r')
grid on
xlim([1 50])      
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Quefrency, ms')
ylabel('Amplitude')
title('Real cepstrum of the signal (quefrencies from 1 ms to 50 ms)')