function [cm, delcm, ym, delym] = esr_mfcc(x, fs, opts)
%ESR_MFCC Compute MFCC features.
if nargin < 3
    opts = struct();
end
if ~isfield(opts, 'frameLength')
    opts.frameLength = 1024;
end
if ~isfield(opts, 'numFilters')
    opts.numFilters = 18;
end
if ~isfield(opts, 'maxHz')
    opts.maxHz = 8000;
end
x = x(:);
N = length(x);
if N < opts.frameLength
    cm = [];
    delcm = [];
    ym = [];
    delym = [];
    return;
end
hop = opts.frameLength / 2;
frames = [];
for n = 1:hop:N-opts.frameLength+1
    frames = [frames, x(n:n+opts.frameLength-1)];
end
energy = sum(frames .* frames, 1);
if isempty(energy)
    cm = [];
    delcm = [];
    ym = [];
    delym = [];
    return;
end
% mask = energy >= 0.1 * max(energy);
mask = energy >= 0.05 * max(energy);
frames = frames(:, mask);
if isempty(frames)
    cm = [];
    delcm = [];
    ym = [];
    delym = [];
    return;
end
win = hamming(size(frames, 1), 'periodic');
frames = frames .* win;
Sfft = abs(fft(frames, [], 1)).^2;

p = opts.numFilters;
q = opts.maxHz;
points = round(q * opts.frameLength / fs);
r = 2595 * log10(q/700 + 1);
fm = linspace(1, r, p).';
f = (10.^(fm/2595) - 1) * 700;
B = zeros(points, p);
for m = 2:p-1
    for k = 1:points
        fk = k * fs / opts.frameLength;
        if fk <= f(m-1) || fk >= f(m+1)
            B(k, m) = 0;
        elseif fk <= f(m)
            B(k, m) = (fk - f(m-1)) / (f(m) - f(m-1));
        else
            B(k, m) = (f(m+1) - fk) / (f(m+1) - f(m));
        end
    end
end
ym = Sfft(1:points, :).';
ym = ym * B;
ym = log(ym(:, 2:p-1) + eps);
delym = ym(2:end, :) - ym(1:end-1, :);
cm = dct(ym, [], 2);
delcm = cm(2:end, :) - cm(1:end-1, :);
end
