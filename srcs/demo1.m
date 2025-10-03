clear, clc, close all
for analysis = 1:10
wavename = "maleSad_"+analysis+".wav"
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
X2 = 0;
for p = 2:N
    if p==2
        X2 = X(p)-0.95*X(p-1);
    else
        X2 = vertcat(X2, X(p)-0.95*X(p-1));
    end
end
YX = fft(abs(X2));
L =12;
SX = zeros(N-1,1);
HX = zeros(N-1,1);
for p=1:N-1
    if p>L && p<=N-1-L
        SX(p) = 0;
        HX(p) = YX(p);
    else
        SX(p) = YX(p);
        HX(p) = 0;
    end
end
sX = ifft(SX);
hX = ifft(HX);
envX = 3*abs(sX);
ErrX = abs(hX);

figure(1)
subplot(2,5,analysis);
plot(t(1:N-1), abs(X2), t(1:N-1), envX);
ylim([0 max(X2)])
figure(2)
subplot(2,5,analysis);
plot(t, X);
figure(3)
subplot(2,5,analysis);
plot(t(1:N-1), X2);
end