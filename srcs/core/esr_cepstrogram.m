function [C, q, t] = esr_cepstrogram(x, win, hop, fs)
%ESR_CEPSTROGRAM Cepstrogram of a signal.
x = x(:);
if nargin < 2 || isempty(win)
    win = hanning(1024, 'periodic');
end
if nargin < 3 || isempty(hop)
    hop = round(length(win) / 4);
end
wlen = length(win);
xlen = length(x);
numUnique = ceil((1 + wlen) / 2);
L = 1 + fix((xlen - wlen) / hop);
C = zeros(numUnique, L);
for l = 0:L-1
    xw = x(1 + l*hop : wlen + l*hop) .* win;
    c = real(ifft(log(abs(fft(xw)) + eps)));
    C(:, 1 + l) = c(1:numUnique);
end
t = (wlen/2:hop:wlen/2 + (L-1)*hop) / fs;
q = (0:numUnique-1) / fs;
end
