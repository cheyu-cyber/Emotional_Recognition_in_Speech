
clear, clc, close all
[x, fs] =audioread('back.wav');
X = x(:, 1);                        % ���Ĥ@�n�D
[peaksX, indicesX] = findpeaks(X);
startpeakX = find(peaksX>=0.01, 1, 'first');
startpointX = indicesX(startpeakX);
endpeakX = find(peaksX>=0.01, 1, 'last');
endpointX = indicesX(endpeakX);
Xeff = X(startpointX:endpointX);
[Xeffcorr, lagsX] = xcorr(Xeff, 'coeff');


[y1, fsy1]=audioread('forward.wav');
Y1 = y1(:, 1);                        % ���Ĥ@�n�D
[peaksY1, indicesY1] = findpeaks(Y1);
startpeakY1 = find(peaksY1>=0.01, 1, 'first');
startpointY1 = indicesY1(startpeakY1);
endpeakY1 = find(peaksY1>=0.01, 1, 'last');
endpointY1 = indicesY1(endpeakY1);
Y1eff = Y1(startpointY1:endpointY1);
[Y1effcorr, lagsY2] = xcorr(Y1eff, 'coeff');

%��h
[y2, fsy2]=audioread('back.wav');
Y2 = y2(:, 1);                        % ���Ĥ@�n�D
[peaksY2, indicesY2] = findpeaks(Y2);
startpeakY2 = find(peaksY2>=0.01, 1, 'first');
startpointY2 = indicesY2(startpeakY2);
endpeakY2 = find(peaksY2>=0.01, 1, 'last');
endpointY2 = indicesY2(endpeakY2);
Y2eff = Y2(startpointY2:endpointY2);
[Y2effcorr, lagsY2] = xcorr(Y2eff, 'coeff');



%����
[y3, fsy3]=audioread('left.wav');
Y3 = y3(:, 1);                        % ���Ĥ@�n�D
[peaksY3, indicesY3] = findpeaks(Y3);
startpeakY3 = find(peaksY3>=0.01, 1, 'first');
startpointY3 = indicesY3(startpeakY3);
endpeakY3 = find(peaksY3>=0.01, 1, 'last');
endpointY3 = indicesY3(endpeakY3);
Y3eff = Y3(startpointY3:endpointY3);
[Y3effcorr, lagsY3] = xcorr(Y3eff, 'coeff');


%�k��
[y4, fsy4]=audioread('right.wav');
Y4 = y4(:, 1);                        % ���Ĥ@�n�D
[peaksY4, indicesY4] = findpeaks(Y4);
startpeakY4 = find(peaksY4>=0.01, 1, 'first');
startpointY4 = indicesY4(startpeakY4);
endpeakY4 = find(peaksY4>=0.01, 1, 'last');
endpointY4 = indicesY4(endpeakY4);
Y4eff = Y4(startpointY4:endpointY4);
[Y4effcorr, lagsY4] = xcorr(Y4eff, 'coeff');

%����
[y5, fsy5]=audioread('stop.wav');
Y5 = y5(:, 1);                        % ���Ĥ@�n�D
[peaksY5, indicesY5] = findpeaks(Y5);
startpeakY5 = find(peaksY5>=0.01, 1, 'first');
startpointY5 = indicesY5(startpeakY5);
endpeakY5 = find(peaksY5>=0.01, 1, 'last');
endpointY5 = indicesY5(endpeakY5);
Y5eff = Y5(startpointY5:endpointY5);
[Y5effcorr, lagsY5] = xcorr(Y5eff, 'coeff');

forward = xcorr(Xeffcorr, Y1effcorr);
back = xcorr(Xeffcorr, Y2effcorr);
left = xcorr(Xeffcorr, Y3effcorr);
right = xcorr(Xeffcorr, Y4effcorr);
stop = xcorr(Xeffcorr, Y5effcorr);
figure(1)
plot(forward);
figure(2)
plot(back);
figure(3)
plot(left);
figure(4)
plot(right);
figure(5)
plot(stop);
m1 = max(forward);
m2 = max(back);
m3 = max(left);
m4 = max(right);
m5 = max(stop);
a = [m1, m2, m3, m4, m5];
h=audioread('allow.wav');
m = max(a);
if m==m1
    soundsc(Y1eff,fsy1)
        soundsc(h,44100)
elseif m == m2
    soundsc(Y2eff,fsy2)
        soundsc(h,44100)
elseif m==m3
    soundsc(Y3eff,fsy3)
        soundsc(h,44100)
elseif m == m4
    soundsc(Y4eff,fsy4)
        soundsc(h,44100)
elseif m==m5
    soundsc(Y5eff,fsy5)
        soundsc(h,44100)
else
   soundsc(audioread('denied.wav'),44100)
   
end