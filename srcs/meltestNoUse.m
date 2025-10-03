clear, clc, close all
for analysis = 1:38
fid = fopen('a.txt', 'r')
a = fscanf(fid, '%f');
fclose(fid)
wavename = "femalePositive_"+analysis+".wav"
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
W = hann(N, 'periodic');
X2 = X;
%X2 = 0;
%for s = 2:N
%    if p==2
%        X2 = X(s)-0.95*X(s-1);
%    else
%        X2 = vertcat(X2, X(s)-0.95*X(s-1));
%   end
%end
X2 = X2.*W;
q = 1200;
r = 2595*log10(q/700+1);
p=16;

fm = linspace(1,r,p);
fm = fm.';
fm = fm;
f = (10.^(fm/2595)-1)*700;
B = zeros(floor(max(f)), p);
for m = 2:p-1
    for k = 1:floor(max(f))
        if k<f(m-1)&&k>f(m+1)
        B(k,m) = 0;
        elseif k<=f(m)&&k>=f(m-1)
        B(k,m) = (k-f(m-1))/(f(m)-f(m-1));
        elseif k>=f(m)&&k<=f(m+1)
        B(k,m) = (f(m+1)-k)/(f(m+1)-f(m));
        end
    end
end
Xk = fft(X2);
Xk = (Xk(1:q).^2);
absXk = abs(Xk);
figure(1)
plot(absXk);

figure(2)
plot(B)
Y = absXk.*B;
yy = zeros(p,1);
for m = 1:p
    for k = 1:q
        yy(m) = yy(m)+Y(k, m);
    end
end
logyy = log10(yy);
yydct = idct(logyy(2:p-1));
yydct = a.*yydct;
femaleSad = fopen('femaleSadmfcctest.txt', 'r')
femalePositive = fopen('femalePositivemfcctest.txt', 'r')
femaleAngry = fopen('femaleAngrymfcctest.txt', 'r')
Sad = fscanf(femaleSad, '%f');
Positive = fscanf(femalePositive, '%f');
Angry = fscanf(femaleAngry, '%f');
Sadpoints = sqrt(mean((yydct-Sad).^2));
Positivepoints = sqrt(mean((yydct-Positive).^2));
Angrypoints = sqrt(mean((yydct-Angry).^2));
fclose(femaleSad)
fclose(femaleAngry)
fclose(femalePositive)
while Positivepoints>=Angrypoints||Positivepoints>=Sadpoints
    for m = 1:p-2
        if a(m)>=0
        if abs((yydct(m)-Positive(m)))>=abs((yydct(m)-Angry(m)))||abs(yydct(m)-Positive(m))>=abs(yydct(m)-Sad(m))
            a(m) = a(m)-0.001
        else
            a(m) = a(m)+0.001
        end
        else
        if abs((yydct(m)-Positive(m)))>=abs((yydct(m)-Angry(m)))||abs(yydct(m)-Positive(m))>=abs(yydct(m)-Sad(m))
            a(m) = a(m)+0.001
        else
            a(m) = a(m)-0.001
        end   
        end
    end
    yydct = a.*yydct;
    Sadpoints = sqrt(mean((yydct-Sad).^2));
    Positivepoints = sqrt(mean((yydct-Positive).^2));
    Angrypoints = sqrt(mean((yydct-Angry).^2));
end
fid = fopen('a.txt', 'w+')
fprintf(fid, '%4.4f\t', a);
fprintf(fid, '\n');
fclose(fid)
end
