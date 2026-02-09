function model = esr_train_hmm(groups, opts)
%ESR_TRAIN_HMM Train per-class HMMs from MFCC features.
if nargin < 2
    opts = struct();
end
if ~isfield(opts, 'codebookSize')
    opts.codebookSize = 16;
end
if ~isfield(opts, 'numStates')
    opts.numStates = 3;
end
if ~isfield(opts, 'maxIter')
    opts.maxIter = 20;
end
if ~isfield(opts, 'featureDims')
    opts.featureDims = 12;
end
if ~isfield(opts, 'seed')
    opts.seed = 0;
end
classes = {'sad', 'positive', 'angry'};
seqs = struct();
allFeatures = [];

rng(opts.seed);
for i = 1:numel(classes)
    files = groups.(classes{i});
    seqs.(classes{i}) = {};
    for f = 1:numel(files)
        [x, fs] = esr_load_audio(files{f});
        [cm, ~, ~, ~] = esr_mfcc(x, fs);
        if isempty(cm)
            continue;
        end
        dims = min(opts.featureDims, size(cm, 2));
        feats = cm(:, 1:dims);
        seqs.(classes{i}){end+1} = feats; %#ok<AGROW>
        allFeatures = [allFeatures; feats]; %#ok<AGROW>
    end
end
if isempty(allFeatures)
    error('No features found for HMM training.');
end
if ~exist('kmeans', 'file')
    error('kmeans is required for codebook training.');
end
[~, codebook] = kmeans(allFeatures, opts.codebookSize, 'Replicates', 3, 'MaxIter', 200);

A = cell(1, numel(classes));
B = cell(1, numel(classes));
for i = 1:numel(classes)
    classSeqs = seqs.(classes{i});
    symbolSeqs = cell(1, numel(classSeqs));
    for s = 1:numel(classSeqs)
        symbols = esr_quantize_features(classSeqs{s}, codebook);
        symbolSeqs{s} = symbols;
    end
    A0 = normalize_rows(rand(opts.numStates));
    B0 = normalize_rows(rand(opts.numStates, opts.codebookSize));
    [A{i}, B{i}] = hmmtrain(symbolSeqs, A0, B0, 'Maxiterations', opts.maxIter, 'Tolerance', 1e-4);
end
model.classes = classes;
model.codebook = codebook;
model.A = A;
model.B = B;
model.opts = opts;
end

function M = normalize_rows(M)
rowSum = sum(M, 2);
rowSum(rowSum == 0) = 1;
M = M ./ rowSum;
end
