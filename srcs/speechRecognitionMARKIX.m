clear, clc, close all
fid = fopen('maleAngry_1.txt', 'w+')
for analysis = 1:10
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
EX = log(abs(X.*X));

X2 = 0;
for p = 2:N
    if p==2
        X2 = X(p)-0.95*X(p-1);
    else
        X2 = vertcat(X2, X(p)-0.95*X(p-1));
    end
end
YX = fft(abs(X2));
L =8;
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

%Xcorr = zeros(4*n-1, i);
%lagsX = zeros(4*n-1, i);

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
for p = 1:i
    if p==1
       tcX = lagsX(:,p)/fs;
    else
       tcX = horzcat(tcX, lagsX(:,p));
    end
    
end
F = 0;
windowedX = X.*hann(length(X));
[XC, lagsXC] = xcorr(X, 'coeff');
[peaksXCcorr, indicesXCcorr] = findpeaks(XC);
[~, indexXCcorr] = sort(peaksXCcorr, 'descend');
RTS = abs(indicesXCcorr(indexXCcorr(3))-length(X))/fs;
FS = 1/RTS

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
FA = vertcat(FA, 1/RT);
if 1/RT<1200 && 1/RT>80
FR = vertcat(FR, 1/RT);
else
    FR = vertcat(FR, 0);
end
if FS<1200 && FS>50
if 1/RT <=FS+150 && 1/RT>=FS-150
F = vertcat(F, 1/RT);
else
    F = vertcat(F, 0);
end
end
end
%end
%F=F/c;
tF = N*(1:i)/(fs*(i));
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

NF = length(FR);
tFR = (0:NF-1)/NF;
Y = fft(FR);
L =8;
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
figure(1)
subplot(2,5,analysis);
line(t(1:N-1),envX,'Color','r');
ax1 = gca; % current axes
ax1.XColor = 'r';
ax1.YColor = 'r';
ax1_pos = ax1.Position; % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
line(tF, envF(2:NF),'Parent',ax2,'Color','k')


%findpeaks(envF)
[posenvFpeaks, posindicesFpeaks] = findpeaks(envF);
[negenvFpeaks, negindicesFpeaks] = findpeaks(-envF);
negenvFpeaks = abs(negenvFpeaks);
indicesFpeaks = vertcat(posindicesFpeaks, negindicesFpeaks);
[B, indexFpeaks] = sort(indicesFpeaks);
Fpeaks = 0;
for p = 1:length(B)
    if envF(B(p))>=60
        if Fpeaks == 0
            Fpeaks = envF(B(p));
        else
        Fpeaks = vertcat(Fpeaks, envF(B(p)));
        end
    end
end
Fpeaks = vertcat(Fpeaks, envF(end));
%scale
pitch = zeros(1200,1);
for f = 1:1200
pitch(f) = 69+12*log2(f/440);
end
notes = mod(pitch, 12);

Fscale = zeros(length(Fpeaks), 1);
for p = 1:length(Fscale)
    if Fpeaks(p)>0
    Fscale(p) = floor(pitch(ceil(Fpeaks(p))));
    Fnotes(p) = floor(notes(ceil(Fpeaks(p))));
    else
        Fscale(p) = -1;
    end
end
chords = diff(Fscale);


val = zeros(12,1);
for p=0:11
    val(p+1) = nnz(Fnotes == p);
end
%figure(1)
%ylim([0 1.5*max(val)])
%subplot(2,5,analysis);
%plot(val);
[valval,valindice]=sort(val,'descend');
valindice = valindice-1;
DelFpeaks = max(Fpeaks)-min(Fpeaks);
DelScale = max(Fscale)-min(Fscale);
m = 2595*log10((Fpeaks/700)+1);
fprintf(fid, '%s\n', "Track "+analysis);
fprintf(fid, '%s\t', "Fpeaks");
fprintf(fid, '%4.1f\t', Fpeaks);
fprintf(fid, '\n');
fprintf(fid, '%s\t', "Fscale");
fprintf(fid, '%d\t\t', Fscale);
fprintf(fid, '\n');
fprintf(fid, '%s\t', "DelFscale");
fprintf(fid, '%d\t\t', chords);
fprintf(fid, '\n');
fprintf(fid, '%s\t', "Fnotes");
fprintf(fid, '%d\t\t', Fnotes);
fprintf(fid, '\n');
fprintf(fid, '%s\t', "notes");
fprintf(fid, '%d\t\t', valindice);
fprintf(fid, '\n');
fprintf(fid, '%s\t', "quant");
fprintf(fid, '%d\t\t', valval);
fprintf(fid, '\n');
fprintf(fid, '%s\t', "melfreq");
fprintf(fid, '%4.1f\t', m);
fprintf(fid, '\n');
end
fclose(fid)