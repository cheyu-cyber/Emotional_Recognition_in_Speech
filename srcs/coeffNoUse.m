clear, clc, close all
for analysis = 1:1
wavename = "maleAngry_"+analysis+".wav"
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
i = 128;
n = floor((N-1)/(i+1));
w = hamming(2*n, 'periodic');

X2 = 0;
for p = 2:N
    if p==2
        X2 = X(p)-0.95*X(p-1);
    else
        X2 = vertcat(X2, X(p)-0.95*X(p-1));
    end
end
[coeffs, delta, deltaDelta, loc] = mfcc(X2, fs);
m = size(coeffs,2);
for p = 1:size(coeffs,2)
    figure(1)
    subplot(2, size(coeffs,2)/2, p)
    plot(coeffs(:,p));
end

end