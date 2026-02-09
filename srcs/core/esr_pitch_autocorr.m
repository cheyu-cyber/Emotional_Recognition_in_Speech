function f0 = esr_pitch_autocorr(x, fs, minHz, maxHz)
%ESR_PITCH_AUTOCORR Estimate pitch from autocorrelation.
if nargin < 3 || isempty(minHz)
    minHz = 60;
end
if nargin < 4 || isempty(maxHz)
    maxHz = 400;
end
x = x(:);
if isempty(x)
    f0 = NaN;
    return;
end
x = x - mean(x);
[rx, lags] = xcorr(x, 'coeff');
mid = ceil(length(rx) / 2);
rx = rx(mid:end);
lags = lags(mid:end);
minLag = floor(fs / maxHz);
maxLag = ceil(fs / minHz);
if maxLag > numel(rx)
    maxLag = numel(rx);
end
search = rx(minLag:maxLag);
[pk, idx] = max(search);
if isempty(pk) || pk <= 0
    f0 = NaN;
    return;
end
lag = lags(minLag - 1 + idx);
f0 = fs / lag;
end
