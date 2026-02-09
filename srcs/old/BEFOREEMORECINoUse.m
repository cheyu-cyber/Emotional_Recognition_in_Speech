clear, clc, close all
[x, fs]=audioread('forward.wav');
X = x(:, 1);  
N = length(X);   
t = (0:N-1)/fs;
w = hann(N, 'periodic');
windowed=X.*w;
figure(1)
plot(t,X)
Y = fft(X);
P1 = abs(Y/N);
P2 = P1(1:1200);
%logP1 = log(P1);
%P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:length(P2)-1)/N;
figure(2)
plot(f,P2); 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

YP1 = fft(P1);
YP2 = fft(P2);
NP1 = length(YP1);
NP2 = length(YP2);
PP11 = abs(YP1/NP1);
PP22 = abs(YP2/NP2);
logPP11 = log(PP11);
logPP22 = log(PP22);
fP1 = (0:NP1-1)/NP1;
fP2 = (0:NP2-1)/NP2;
figure(3)
plot(fP1, PP11);
figure(4)
plot(fP2, PP22);
figure(5)
plot(fP1, logPP11);
figure(6)
plot(fP2, logPP22);


logYP1 = log(YP1);
logYP2 = log(YP2);
l=64;
for p =1:NP1
    if p>l && p<=NP1-l
        YP1(p)=  0;
        logYP1(p) = 0;
    end
end
for p = 1:NP2
    if p>l && p<=NP2-l
        YP2(p) = 0;
        logYP2(p) = 0;
    end
end
XlogP1 = ifft(logYP1);
XlogP2 = ifft(logYP2);
XP1 = ifft(YP1);
XP2 = ifft(YP2);
envlogP1 = abs(XlogP1/length(logYP1));
envlogP2 = abs(XlogP2/length(logYP2));
envP1 = abs(XP1/length(YP1));
envP2 = abs(XP2/length(YP2));
fP2 = fs*(0:length(envP2)-1)/N;
figure(7)
plot(envlogP1);
figure(8)
plot(envlogP2);
figure(9)
plot(envP1);
figure(10)
plot(fP2,envP2);















