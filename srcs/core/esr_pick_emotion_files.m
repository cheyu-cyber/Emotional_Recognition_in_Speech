function [groups, label] = esr_pick_emotion_files(datasetDir, maxFiles)
%ESR_PICK_EMOTION_FILES Pick female or male emotion file groups.
if nargin < 2 || isempty(maxFiles)
    maxFiles = 8;
end
[groups, label] = pickByPrefix(datasetDir, 'female', maxFiles);
if isempty(groups.sad)
    [groups, label] = pickByPrefix(datasetDir, 'male', maxFiles);
end
end

function [groups, label] = pickByPrefix(datasetDir, prefix, maxFiles)
label = prefix;
classes = {'Sad', 'Positive', 'Angry'};
fields = {'sad', 'positive', 'angry'};
groups = struct('sad', {{}}, 'positive', {{}}, 'angry', {{}});
for i = 1:numel(classes)
    pattern = fullfile(datasetDir, [prefix classes{i} '_*.wav']);
    files = dir(pattern);
    names = sort({files.name});
    if ~isempty(names)
        names = names(1:min(maxFiles, numel(names)));
        fullPaths = cellfun(@(n) fullfile(datasetDir, n), names, 'UniformOutput', false);
        groups.(fields{i}) = fullPaths;
    end
end
end
