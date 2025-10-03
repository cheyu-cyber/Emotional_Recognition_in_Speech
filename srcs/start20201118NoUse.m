clear, clc, close all
for analysis = 32:32
wavename = "maleAngry_"+analysis+".wav"
[x, fs] =audioread(wavename);
X = x(:, 1);  
N = length(X);
t = (0:N-1)/fs;
figure(1)
plot(t,X);
 %%framing
 framinglength =1024;
n=1;
while(n<N-framinglength)
   if n==1
     s=x(n:n+framinglength-1,1);
   else
       s=horzcat(s,x(n:n+framinglength-1,1));
   end
   n=n+framinglength/2;
end 
n=1;  
s2=s.^2;
%%frame energy
while(n<=size(s,2))
    if n==1
    energy=log(sum(s(:,n).^2));
    else
        energy = horzcat(energy,log(sum(s(:,n).^2)));
    end
    n=n+1;
end  
%%cancel noise
k=find(energy<0.1); 
n=size(k,2);  
S=s;
%while(n>=1)
 %   S(:,k(n)) = [];
 %   n=n-1;
%end
%%windowing
windowed = hann(framinglength, 'periodic');
figure(2)
plot((0:framinglength-1)/fs,S.*windowed)
xlabel('time(s)')
ylabel('Magnitude')
title('Windowed Signal')
%mfcc
q=8000;
points=q*size(S,1)/fs;
%abs fft
Sfft=((fft(S.*windowed)));
%Sfft=Sfft(1:points, 1:end)
%Triangular filter
p=15;
r = 2595*log10(q/700+1);
fm = linspace(1,r,p);
fm = fm.';
f = (10.^(fm/2595)-1)*700;
%B = zeros(floor(framinglength), p);
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
plot(f,B);
Sffttran = Sfft.';
SfftB = log(Sffttran*B);
SfftBtran = SfftB.';
CC = abs(ifft(SfftBtran(2:p-1,:)));

end