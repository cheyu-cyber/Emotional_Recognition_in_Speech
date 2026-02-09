clear, clc, close all
fid = fopen('femalePositive_1.txt', 'w+')
FS = zeros(10, 1);
FS2 = zeros(10,1);
RTS2 = zeros(10,1);
for analysis = 1:10
wavename = "femalePositive_"+analysis+".wav"
[x, fs] =audioread(wavename);
X = x(:, 1);    
%[peaksX, indicesX] = findpeaks(X);
%startpeakX = find(peaksX>=0.01, 1, 'first');
%startpointX = indicesX(startpeakX);
%endpeakX = find(peaksX>=0.01, 1, 'last');
%endpointX = indicesX(endpeakX);
%X = X(startpointX:endpointX);
N = length(X);
t = (0:N-1)/fs;
i = 128;
n = floor(length(X)/(i+1));
w = hamming(2*n, 'periodic');

windowedX = X.*hann(length(X));
[XC, lagsXC] = xcorr(windowedX, 'coeff');
[peaksXCcorr, indicesXCcorr] = findpeaks(XC);
[~, indexXCcorr] = sort(peaksXCcorr, 'descend');
RTS = abs(indicesXCcorr(indexXCcorr(2))-N)/fs;
p = 3;
while 1/RTS>900
   RTS = abs(indicesXCcorr(indexXCcorr(p))-N)/fs; 
   p=p+1;
end
FS(analysis) = 1/RTS;
tc = lagsXC/fs;

lagsX2 = 1200;
XC2 = autocorr(X, 'NumLags', lagsX2);
[peaksX2Ccorr, indicesX2Ccorr] = findpeaks(XC2);
[~, indexX2Ccorr] = sort(peaksX2Ccorr, 'descend');
RTS2(analysis) = abs(indicesX2Ccorr(indexX2Ccorr(2)))*N/(fs*lagsX2);
FS2(analysis) = 1/RTS2(analysis);
tc2 = (0:lagsX2)*N/(fs*lagsX2);
figure(1)
subplot(2,5,analysis);
plot(tc, XC)
end