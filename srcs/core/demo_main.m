clear; clc; close all

rootDir = fileparts(fileparts(mfilename('fullpath')));
datasetDir = fullfile(rootDir, 'dataset');

sampleFile = fullfile(datasetDir, 'femaleSad_1.wav');
if ~exist(sampleFile, 'file')
    files = dir(fullfile(datasetDir, '*.wav'));
    if isempty(files)
        error('No wav files found in dataset folder.');
    end
    sampleFile = fullfile(datasetDir, files(1).name);
end

[x, fs] = esr_load_audio(sampleFile);
[x, trimIdx] = esr_trim_silence(x, fs, 0.02);

esr_basic_plots(x, fs, ['(' sampleFile ')']);

[C, q] = esr_cepstrum(x, fs);
figure('Name', 'Cepstrum');
plot(q * 1000, C, 'r');
grid on;
xlabel('Quefrency (ms)');
ylabel('Amplitude');
title('Cepstrum');

win = hanning(min(1024, length(x)), 'periodic');
hop = round(length(win) / 4);
[Cgram, qg, tg] = esr_cepstrogram(x, win, hop, fs);
qg = qg * 1000;
figure('Name', 'Cepstrogram');
imagesc(tg, qg, Cgram);
axis xy;
xlabel('Time (s)');
ylabel('Quefrency (ms)');
title('Cepstrogram');
colorbar;

f0 = esr_pitch_autocorr(x, fs, 60, 400);
if ~isnan(f0)
    disp(['Estimated pitch (Hz): ' num2str(f0, '%.1f')]);
else
    disp('Estimated pitch (Hz): NaN');
end

[cm, delcm, ym, delym] = esr_mfcc(x, fs); %#ok<ASGLU>
disp(['MFCC frames: ' num2str(size(cm, 1)) ', coeffs: ' num2str(size(cm, 2))]);

if exist('hmmtrain', 'file') && exist('hmmdecode', 'file') && exist('kmeans', 'file')
    [groups, label] = esr_pick_emotion_files(datasetDir, 8);
    if ~isempty(groups.sad) && ~isempty(groups.positive) && ~isempty(groups.angry)
        opts = struct('codebookSize', 16, 'numStates', 3, 'maxIter', 20, 'featureDims', 12, 'seed', 0);
        model = esr_train_hmm(groups, opts);
        [predLabel, scores] = esr_predict_emotion(sampleFile, model);
        disp(['HMM voice set: ' label]);
        disp(['HMM prediction: ' predLabel]);
        disp(['HMM scores: ' num2str(scores)]);
    else
        disp('Not enough emotion files found to train HMM.');
    end
else
    disp('HMM demo skipped (missing hmmtrain/hmmdecode/kmeans).');
end
