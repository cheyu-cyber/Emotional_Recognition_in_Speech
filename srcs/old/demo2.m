clear, clc, close all
for analysis = 6:6
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
i = 128;
n = floor((N-1)/(i+1));
w = hamming(2*n, 'periodic');
figure(3)
plot(X)
X2 = 0;
for p = 2:N
    if p==2
        X2 = X(p)-0.95*X(p-1);
    else
        X2 = vertcat(X2, X(p)-0.95*X(p-1));
    end
end

for p = 1:i
    if p==1
    Xeff = X(1:2*p*n);
    else
    Xeff = horzcat(Xeff, X((p-1)*n+1:(p+1)*n));
    end
end

for p = 1:i
    Xeff(:,p) = Xeff(:,p).*w;
end

for p=1:i
    [XCORR, LAGSX] = xcorr(Xeff(:,p), 'coeff');
    if p==1
       Xcorr = XCORR; 
       lagsX = LAGSX;
    else
        Xcorr = horzcat(Xcorr, XCORR);
        lagsX = horzcat(lagsX, LAGSX);
    end
end
%Create a standard
windowedX = X.*hann(length(X));
[XC, lagsXC] = xcorr(X, 'coeff');
[peaksXCcorr, indicesXCcorr] = findpeaks(XC);
[~, indexXCcorr] = sort(peaksXCcorr, 'descend');
RTS = abs(indicesXCcorr(indexXCcorr(3))-length(X))/fs;
FS = 1/RTS;

F = 0;
FR = 0;
FA = 0;
for p=1:i
[peaksXcorr, indicesXcorr] = findpeaks(Xcorr(:,p));
[~, indexXcorr] = sort(peaksXcorr, 'descend');
if length(indexXcorr)<3
 RT = 1;
else
RT = abs(indicesXcorr(indexXcorr(3))-2*n)/fs;
end
%All Frequencies
FA = vertcat(FA, 1/RT);
%Frequency at range
if 1/RT<900 && 1/RT>70
FR = vertcat(FR, 1/RT);
else
    FR = vertcat(FR, 0);
end
%Frequency as standard
if FS<1200 && FS>50
if 1/RT <=FS+150 && 1/RT>=FS-150
F = vertcat(F, 1/RT);
else
    F = vertcat(F, 0);
end
else
   F = vertcat(F, 0); 
end
end

%FR trim
sum = 0;
for p=1:i
    sum = sum+FR(p+1);
end
sum = sum/i;
for p=1:i+1
    if FR(p)>=sum-150 && FR(p)<=sum+150
        FR(p) = FR(p);
    else
        FR(p) = 0;
    end
end
for p=1:i-1
    if FR(p+1) == 0 && FR(p)~=0 && FR(p+2)~=0
        FR(p+1) = (FR(p)+FR(p+2))/2;
    elseif FR(p+1) == 0
        FR(p+1) = FR(p);
    end   
end
%envelope
NF = length(FR);
Y = fft(FR);
L = 16;
S = zeros(NF,1);
H = zeros(NF,1);
for p=1:NF
    if p>L && p<=NF-L
        S(p) = 0;
        H(p) = Y(p);
    else
        S(p) = Y(p);
        H(p) = 0;
    end
end
s = ifft(S);
h = ifft(H);
envF = abs(s);
Err = abs(h);
tF = N*(1:i)/(fs*(i));

figure(1)
%subplot(2,5,analysis);
plot(tF, FR(2:i+1), tF,envF(2:NF));
ylim([0 1.1*max(FR)]);
xlabel('time(s)')
ylabel('Frequency(Hz)')
title('Cepstrum of basic frequency')
windowedlength = round(0.03*fs);
overlaplength = round(0.015*fs);
f0=0;
f0 = pitch(X,fs, 'WindowLength', windowedlength, 'OverlapLength', overlaplength, 'Range',[sum-150,sum+150]);
figure(2)
subplot(2,5,analysis);
timevector = linspace(startpointX/fs,endpointX/fs,numel(f0));
plot(timevector,f0);












end