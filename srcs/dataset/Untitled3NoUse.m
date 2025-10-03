clear, clc, close all
for analysis = 32:32
wavename = "maleAngry_"+analysis+".wav";
[x, fs] =audioread(wavename);
X = x(:, 1);  %get first channel
N = length(X);
t = (0:N-1)/fs;
 %%framing
n=1;
while(n<N-1024)
   if n==1
     s=x(n:n+1024,1);
   else
       s=horzcat(s,x(n:n+1024,1));
   end
   n=n+512;
end
%%frame energy
n=1;
s2=s.^2;
while(n<=size(s,2))
    if n==1
    energy=(sum(s(:,n).^2));
    else
        energy = horzcat(energy,(sum(s(:,n).^2)));
    end
    n=n+1;
end
%%cancel noise
k=find(energy<0.1);
n=size(k,2);
S=s;
while(n>=1)
    S(:,k(n)) = [];
    n=n-1;
end
%mfcc
q=8000;
points=q*size(S,1)/fs;
%%windowing
windowed = hann(size(s,1), 'periodic');
%abs fft
Swindowed=S.*windowed;
Sfft=(abs(fft(Swindowed,[],1))).^2;
Sfft=Sfft(1:points, 1:end);
figure(2)
Sffttran=Sfft.';
poi=q*(0:points-1)/points;
poi=poi.';
plot(poi,Sfft(:,1))
%Triangular filter
p=18;
r = 2595*log10(q/700+1);
fm = linspace(1,r,p);
fm = fm.';
f = (10.^(fm/2595)-1)*700;
B = zeros(floor(points), p);
for m = 2:p-1
    for k = 1:points
        if k*fs/size(S,1)<f(m-1)&&k*fs/size(S,1)>f(m+1)
        B(k,m) = 0;
        elseif k*fs/size(S,1)<=f(m)&&k*fs/size(S,1)>=f(m-1)
        B(k,m) = (k*fs/size(S,1)-f(m-1))/(f(m)-f(m-1));
        elseif k*fs/size(S,1)>=f(m)&&k*fs/size(S,1)<=f(m+1)
        B(k,m) = (f(m+1)-k*fs/size(S,1))/(f(m+1)-f(m));
        end
    end
end
figure(3)
plot(B)
SfftBt=(B.*Sfft(:,3));
figure(4)
plot(SfftBt);
Ym = log(sum(SfftBt));
Cm=dct(Ym(2:p-1));
end
[cm, del]=mfccfunc(wavename);