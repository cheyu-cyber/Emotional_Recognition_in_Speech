function [C, q] = esr_cepstrum(x, fs)
%ESR_CEPSTRUM Real cepstrum of a signal.
x = x(:);
N = length(x);
win = hanning(N, 'periodic');
x = x .* win;
numUnique = ceil((N + 1) / 2);
C = real(ifft(log(abs(fft(x)) + eps)));
C = C(1:numUnique);
q = (0:numUnique-1).' / fs;
end
