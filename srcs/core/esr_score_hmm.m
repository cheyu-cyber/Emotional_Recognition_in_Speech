function scores = esr_score_hmm(symbols, model)
%ESR_SCORE_HMM Score symbol sequence against HMM models.
classes = model.classes;
scores = -inf(1, numel(classes));
for i = 1:numel(classes)
    try
        [~, logp] = hmmdecode(symbols, model.A{i}, model.B{i});
        if ~isfinite(logp)
            scores(i) = -inf;
        else
            scores(i) = logp;
        end
    catch
        scores(i) = -inf;
    end
end
end
