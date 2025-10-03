clear, clc, close all
for analysis = 1:1
wavename = "maleAngry_"+analysis+".wav"
[x, fs] =audioread(wavename);
X = x(:, 1);  
N = length(X);
t = (0:N-1)/fs;
windowed = hamming(size(X,1), 'periodic');
figure(2)
plot(windowed)
Xfft=abs(fft(X.*windowed)).^2;

points = 8000*N/fs;
P1 = Xfft(1:points);
Xfreq = fs*(0:points-1)/N;
q=8000;
p=18;
r = 2595*log10(q/700+1);
fm = linspace(1,r,p);
fm = fm.';
f = (10.^(fm/2595)-1)*700
B = zeros(floor(max(f)), p);
for m = 2:p-1
    for k = 1:points
        if k*fs/N<f(m-1)||k*fs/N>f(m+1)
        B(k,m) = 0;
        elseif k*fs/N<=f(m)&&k*fs/N>=f(m-1)
        B(k,m) = (k*fs/N-f(m-1))/(f(m)-f(m-1));
        elseif k*fs/N>=f(m)&&k*fs/N<=f(m+1)
        B(k,m) = (f(m+1)-k*fs/N)/(f(m+1)-f(m));
        end
    end
end
figure(3)
plot(Xfreq,P1)

figure(4)
plot(Xfreq,B)
xlabel('Frequency(Hz)')
ylabel('Magnitude')
title('Mel-filter banks')
Xmfcc=B.*P1;
figure(5)
plot(Xfreq,Xmfcc)
end