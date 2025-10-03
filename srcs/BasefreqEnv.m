clear, clc, close all
goal = 13;
for analysis = 4:goal
wavename = "femalePositive_"+analysis+".wav"
[x, fs] =audioread(wavename);
X = x(:, 1);    
N = length(X);
t = (0:N-1)/fs;
i = 96;
n = floor(length(X)/(i+1));
W = hann(N, 'periodic');
w = hann(2*n, 'periodic');  
for p = 1:i
    if p==1
    Xeff = X(1:2*p*n);
    else
    Xeff = horzcat(Xeff, X((p-1)*n+1:(p+1)*n));
    end
end
%fft
Y = zeros(floor(n/2)+1,i);
basef = zeros(i,1);
[test,ftest]= periodogram(X,W,N,fs);
for p = 1:i
    
    [Y(:,p),f] = periodogram(Xeff(:,p),w,n,fs);
    
    [~,indices]=max(Y(:,p));
    if f(indices)>=60&&f(indices)<=1200
    basef(p) = f(indices);
    else
        basef(p) = 0;
    end
end
sum = 0;
for p=1:i
    sum = sum+basef(p);
end
sum = sum/i;
for p=1:i
    if basef(p)>=sum-200 && basef(p)<=sum+200
        basef(p) = basef(p);
    else
        basef(p) = 0;
    end
end
for p=1:i-2
    if basef(p+1) == 0 && basef(p)~=0 && basef(p+2)~=0
        basef(p+1) = (basef(p)+basef(p+2))/2;
    elseif basef(p+1) == 0
        basef(p+1) = basef(p);
    end   
end
tF = N*(1:i)/(fs*(i));
NF = length(basef);
Y = fft(abs(basef));
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


figure(1)
subplot(2,5,(analysis-3));
plot(tF,basef,tF,envF);









end