clear, clc, close all
for analysis = 32:32
    wavename = "maleAngry_"+analysis+".wav"
    [x, fs] =audioread(wavename);
    X = x(:, 1);  
    N = length(X);
    t = (0:N-1)/fs;
    framinglength =1024;
    n=1;
    while(n<=N-framinglength)
    if n==1
       s=x(n:n+framinglength-1,1);
    else
       s=horzcat(s,x(n:n+framinglength-1,1));
    end
    n=n+framinglength/2;
    end 
    windowed = hann(size(s,1), 'periodic');
    Xfft = fft(s.*windowed);
    Xstft = stft(X,"Window",windowed,"OverlapLength",512,"Centered",false);
    fftcoeffs = mfcc(Xfft,fs);
    logfftcoeffs = mfcc(Xfft,fs);%,'LogEnergy',"Ignore");
    L = 2^nextpow2(N);
    [coeffs,delta,deltaDelta,loc] = mfcc(Xfft,fs,"LogEnergy","Ignore");
       
end



%target=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3];
%input2=floor(input1(1,:))%-min(input1);    
%[estimateTR,estimateEm] = hmmestimate(input2,target);