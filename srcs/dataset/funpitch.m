function fundamentalpitch = funpitch(wavename)
[x, fs] =audioread(wavename);
X = x(:, 1);    
[peaksX, indicesX] = findpeaks(X);
startpeakX = find(peaksX>=0.01, 1, 'first');
startpointX = indicesX(startpeakX);
endpeakX = find(peaksX>=0.01, 1, 'last');
endpointX = indicesX(endpeakX);
X = X(startpointX:endpointX);
N = length(X);
[XC, lagsXC] = xcorr(X, 'coeff');
[peaksXCcorr, indicesXCcorr] = findpeaks(XC);
[~, indexXCcorr] = sort(peaksXCcorr, 'descend');
RTS = abs(indicesXCcorr(indexXCcorr(2))-N)/fs;
p = 3;
while 1/RTS>1500
   RTS = abs(indicesXCcorr(indexXCcorr(p))-N)/fs; 
   p=p+1;
end
fundamentalpitch = 1/RTS;
end