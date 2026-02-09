function [label, scores] = esr_predict_emotion(filePath, model)
%ESR_PREDICT_EMOTION Predict emotion label for a file.
[x, fs] = esr_load_audio(filePath);
[cm, ~, ~, ~] = esr_mfcc(x, fs);
if isempty(cm)
    label = '';
    scores = [];
    return;
end
dims = min(model.opts.featureDims, size(cm, 2));
feats = cm(:, 1:dims);
symbols = esr_quantize_features(feats, model.codebook);
scores = esr_score_hmm(symbols, model);
[~, idx] = max(scores);
label = model.classes{idx};
end
