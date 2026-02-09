function [y, idx] = esr_trim_silence(x, fs, threshold)
%ESR_TRIM_SILENCE Trim leading and trailing silence.
if nargin < 3 || isempty(threshold)
    threshold = 0.02;
end
x = x(:);
if isempty(x)
    y = x;
    idx = [1 0];
    return;
end
absx = abs(x);
limit = threshold * max(absx);
firstIdx = find(absx >= limit, 1, 'first');
lastIdx = find(absx >= limit, 1, 'last');
if isempty(firstIdx) || isempty(lastIdx)
    y = x;
    idx = [1 numel(x)];
    return;
end
y = x(firstIdx:lastIdx);
idx = [firstIdx lastIdx];
end
