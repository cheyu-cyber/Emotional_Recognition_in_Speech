function [cm, delcm, ym, delym] = mfccfunc(wavename)
[x, fs] = audioread(wavename);
X = x(:,1);
N = length(X);
%t = (0:N-1)/fs;
%framing
framinglength = 1024;
n=1;
while(n<=N-framinglength)
    if n==1
    s = X(n:n+framinglength-1,1);
    else
        s=horzcat(s,X(n:n+framinglength-1,1));
    end
    n = n+framinglength/2;
end
%frame energy
energy = sum(s.*s);
%cancel noise
k=find(energy<0.1);
n=size(k,2);
S=s;
while(n>=1)
    S(:,k(n)) = [];
    n=n-1;
end
%windowing
windowed=  hamming(size(s,1), 'periodic');
Swin = S.*windowed;
%abs fft
Sfft = fft(Swin, [],1);
Sfft = abs(Sfft).^2;
%B
p = 18;
q = 8000;
points = round(q*framinglength/fs);
r = 2595*log10(q/700+1);
fm = linspace(1,r,p);
fm = fm.';
f = (10.^(fm/2595)-1)*700;
B = zeros(points, p);
for m = 2:p-1
    for k = 1:points
        if k*fs/framinglength<f(m-1)&&k*fs/framinglength>f(m+1)
        B(k,m) = 0;
        elseif k*fs/framinglength<=f(m)&&k*fs/framinglength>=f(m-1)
        B(k,m) = (k*fs/framinglength-f(m-1))/(f(m)-f(m-1));
        elseif k*fs/framinglength>=f(m)&&k*fs/framinglength<=f(m+1)
        B(k,m) = (f(m+1)-k*fs/framinglength)/(f(m+1)-f(m));
        end
    end
end
%mfcc
ym=Sfft(1:points,:).'*B;
ym = log(ym(:, 2:p-1));
delym = ym(2:end, :)-ym(1:end-1,:);
%dct
cm=dct(ym, [], 2);
delcm = cm(2:end,:)-cm(1:end-1,:);
end