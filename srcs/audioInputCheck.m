%x = getfield(audiodevinfo, 'Input')
clear, clc, close all
%[x, fs] = audioread('sunday.wav');
%playsound = audioplayer(x, fs)
          % play(playsound)
        % recordobj = audiorecorder(44100, 16, 1, -1)
        info = audiodevinfo
        fs = 44100;
        nBits = 24;
        nChannels = 1;
       x=0;
        recObj = audiorecorder(fs, nBits, nChannels);
        for input = 1:3
        record(recObj)
        disp('Start speaking.')
        pause(2)
        %recordblocking(recObj,2);
        stop(recObj)
        if input == 1
            x=getaudiodata(recObj);
        else
        x = vertcat(x,getaudiodata(recObj));
        end
disp('End of Recording.');
N = length(x);
w = hann(N, 'periodic'); %symmetric for filter design, periodic for generic design
[Xx, f] = periodogram(x, w, N, fs, 'power');
Xx = 10*log10(Xx/sqrt(2));
figure(1)
plot(f, Xx)
xlim([0 max(f)])
grid on
title('Frequency Domain')
xlabel('Frequency(Hz)')
ylabel('Magnitude(dB)')
figure(2)
plot(x);
        end
        x(10000)
soundsc(x, fs);