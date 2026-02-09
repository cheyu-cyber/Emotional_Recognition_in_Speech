function [x, fs, info] = esr_load_audio(filePath)
%ESR_LOAD_AUDIO Load audio and return mono signal.
info = audioinfo(filePath);
[x, fs] = audioread(filePath);
if size(x, 2) > 1
    x = x(:, 1);
end
x = x(:);
end
