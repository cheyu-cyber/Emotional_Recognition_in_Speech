clear, clc, close all
number = 38;
p=74;
yy = zeros(p,number);
fid = fopen('femalePositivemfcctest.txt', 'w+')
for analysis = 1:number
wavename = "femalePositive_"+analysis+".wav"
q = 1200;
r = 2595*log10(q/700+1);
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

fm = linspace(1,r,p);
fm = fm.';
fm = fm;
f = (10.^(fm/2595)-1)*700
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
plot(absXk);

figure(2)
plot(B)
Y = absXk.*B;

for m = 1:p
    for k = 1:q
        yy(m, analysis) = yy(m, analysis)+Y(k, m);
    end
end
end
logyy = log10(yy);
figure(3)
plot(logyy);
yydct = zeros(p-2, number);
for m = 1:number
    yydct(:,m) = idct(logyy(2:p-1, m));
end
figure(4)
plot(yydct)
sumyy=zeros(p-2,1);
for k = 1:p-2
    for m = 1:number
        sumyy(k) = sumyy(k) + yydct(k,m);
    end
end
sumyy = sumyy/number;
figure(5)
plot(sumyy(1:p-2))
fprintf(fid, '%4.1f\t', sumyy);
fprintf(fid, '\n');
fclose(fid);
%Y = idct(Y);
%Y = abs(Y);
%figure(4)
%plot(Y)
