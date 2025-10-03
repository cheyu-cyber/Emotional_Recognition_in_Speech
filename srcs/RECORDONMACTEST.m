clear, clc, close all
[x, fs]=audioread('maleAngry_12.wav');
X = x(:, 1);  
N = length(X);   
t = (0:N-1)/fs;
figure(1)
plot(X);
figure(2)
plot(abs(X));

Y = fft(abs(X));
L = 32;
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

figure(3)
plot(envX);
figure(4)
plot(Err);
startpoint = 1;
endpoint = N;
check = 0.01;
for p = 1:N-1
    if envX(p)<=check && envX(p+1)>check
        startpoint = vertcat(startpoint, p);
    end
    if envX(p)>=check && envX(p+1)<check
        endpoint = vertcat(endpoint, p);
    end
end
Nstart = length(startpoint);
Nend = length(endpoint);
if Nstart == Nend
if startpoint(2) >=endpoint(2)
    for p=1:Nstart
        
        if p==Nstart
            Xeff = vertcat(Xeff, X(startpoint(p) : endpoint(1)));
            break;
        end
        if p==1
            Xeff = X(startpoint(p):endpoint(p+1));
            Xeff = vertcat(Xeff, 100);
        else
            Xeff = vertcat(Xeff, X(startpoint(p):endpoint(p+1)));
            Xeff = vertcat(Xeff, 100);
        end
    end    
end
end
