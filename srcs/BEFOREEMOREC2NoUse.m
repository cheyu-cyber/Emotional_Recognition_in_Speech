clear, clc, close all
for analysis = 1:1
wavename = "malePositive_"+analysis+".wav"
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
windowedlength = round(0.03*fs);
i = floor(N*2/windowedlength);
n = floor((N-1)/(i+1));
w = hamming(2*n, 'periodic');
EX = log(abs(X.*X));

X2 = 0;
for p = 2:N
    if p==2
        X2 = X(p)-0.9375*X(p-1);
    else
        X2 = vertcat(X2, X(p)-0.9375*X(p-1));
    end
end

for p = 1:i
    if p==1
    Xeff = X2(1:2*p*n);
    else
    Xeff = horzcat(Xeff, X2((p-1)*n+1:(p+1)*n));
    end
end

for p = 1:i
    Xeff(:,p) = Xeff(:,p).*w;
end
[Y,f] = fft(X2);
Y = abs(Y);
yy = Y(1:length(yy)/2);
melfreq = 2595*log10((f/700)+1);
figure(1)
plot(yy, melfreq);
m = 100;
r = zeros(m,1);
for p = 1:m
    for q = 1:n-m
    r(p) = r(p)+X2(q).*X2(q+p);
    end
end
figure(2)
plot(r)
end