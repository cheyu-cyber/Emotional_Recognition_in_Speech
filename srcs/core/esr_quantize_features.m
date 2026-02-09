function symbols = esr_quantize_features(features, codebook)
%ESR_QUANTIZE_FEATURES Quantize feature frames into symbol indices.
if isempty(features) || isempty(codebook)
    symbols = [];
    return;
end
if exist('pdist2', 'file')
    D = pdist2(features, codebook, 'squaredeuclidean');
    [~, symbols] = min(D, [], 2);
else
    numFrames = size(features, 1);
    numCodes = size(codebook, 1);
    symbols = zeros(numFrames, 1);
    for i = 1:numFrames
        diffs = codebook - features(i, :);
        d2 = sum(diffs .* diffs, 2);
        [~, symbols(i)] = min(d2);
    end
end
symbols = symbols(:).';
end
