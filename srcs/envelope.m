clear, clc, close all
for analysis = 1:10
wavename = "femaleAngry_"+analysis+".wav"
[x, fs] = audioread(wavename);  % �פJ���T��
X = x(:, 1); 
max((X))% ���Ĥ@�n�D
N = length(X);                      % �`����
t = (0:N-1)/fs;   
Y = fft(abs(X));
L = 16;
S = zeros(N,1);
H = zeros(N,1);
for p=1:N
    if p>L && p<=N-L
        S(p) = 0;
        H(p) = Y(p);
    else
        S(p) = Y(p);
        H(p) = 0;
    end
end
s = ifft(S);
h = ifft(H);
envX = real(s);
Err = real(h);

figure(1)
subplot(2,5,analysis);
plot(envX);
end