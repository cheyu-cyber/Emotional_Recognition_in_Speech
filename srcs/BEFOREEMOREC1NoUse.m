clear, clc, close all
wavename = "allow.wav"
[x, fs] =audioread(wavename);
X = x(:, 1);
[peaksX, indicesX] = findpeaks(X);
startpeakX = find(peaksX>=0.01, 1, 'first');
startpointX = indicesX(startpeakX);
endpeakX = find(peaksX>=0.01, 1, 'last');
endpointX = indicesX(endpeakX);
X = X(startpointX:endpointX);
N = length(X);
t = (0:N-1)/fs;
figure(1)
plot(t, X);
X2 = 0;
for p = 2:N
    if p==2
        X2 = X(p)-0.95*X(p-1);
    else
        X2 = vertcat(X2, X(p)-0.95*X(p-1));
    end
end
figure(2)
plot(t(1:N-1), X2);