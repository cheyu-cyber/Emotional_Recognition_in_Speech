
clear, clc, close all
[x, fs] =audioread('mySpeech.wav');
X = x(:, 1);                        % ���Ĥ@�n�D
[peaksX, indicesX] = findpeaks(X);
startpeakX = find(peaksX>=0.01, 1, 'first');
startpointX = indicesX(startpeakX);
endpeakX = find(peaksX>=0.01, 1, 'last');
endpointX = indicesX(endpeakX);
Xeff = X(startpointX:endpointX);
[y1, fsy1]=audioread('forward.wav');
Y1 = y1(:, 1);                        % ���Ĥ@�n�D
[peaksY1, indicesY1] = findpeaks(Y1);
startpeakY1 = find(peaksY1>=0.01, 1, 'first');
startpointY1 = indicesY1(startpeakY1);
endpeakY1 = find(peaksY1>=0.01, 1, 'last');
endpointY1 = indicesY1(endpeakY1);
Y1eff = Y1(startpointY1:endpointY1);
[z1, lags1]=xcorr(Xeff,Y1eff);
tc1 = lags1/fs;
Z1 = findpeaks(findpeaks(findpeaks(findpeaks(findpeaks(z1)))))
dz1 = diff(Z1)
figure(2)
plot(dz1);
title('Y1xcorr')
figure(3)
plot(Z1)
title('peaksz1')

[y2, fsy2]=audioread('back.wav');
Y2 = y2(:, 1);                        % ���Ĥ@�n�D
[peaksY2, indicesY2] = findpeaks(Y2);
startpeakY2 = find(peaksY2>=0.01, 1, 'first');
startpointY2 = indicesY2(startpeakY2);
endpeakY2 = find(peaksY2>=0.01, 1, 'last');
endpointY2 = indicesY2(endpeakY2);
Y2eff = Y2(startpointY2:endpointY2);
[z2, lags2]=xcorr(Xeff,Y2eff);
tc2 = lags2/fs;
Z2 = findpeaks(findpeaks(findpeaks(findpeaks(findpeaks(z2)))))
dz2 = diff(Z2)
figure(4)
plot(dz2);
title('Y2xcorr')
figure(5)
plot(Z2)
title('peaksz2')

[y3, fsy3]=audioread('left.wav');
Y3 = y3(:, 1);                        % ���Ĥ@�n�D
[peaksY3, indicesY3] = findpeaks(Y3);
startpeakY3 = find(peaksY3>=0.01, 1, 'first');
startpointY3 = indicesY3(startpeakY3);
endpeakY3 = find(peaksY3>=0.01, 1, 'last');
endpointY3 = indicesY3(endpeakY3);
Y3eff = Y3(startpointY3:endpointY3);
[z3, lags3] =xcorr(Xeff,Y3eff);
tc3 = lags3/fs;
Z3 = findpeaks(findpeaks(findpeaks(findpeaks(findpeaks(z3)))))
dz3 = diff(Z3)
figure(6)
plot(dz3);
title('Y3xcorr')
figure(7)
plot(Z3)
title('peaksz3')

[y4, fsy4]=audioread('right.wav');
Y4 = y4(:, 1);                        % ���Ĥ@�n�D
[peaksY4, indicesY4] = findpeaks(Y4);
startpeakY4 = find(peaksY4>=0.01, 1, 'first');
startpointY4 = indicesY4(startpeakY4);
endpeakY4 = find(peaksY4>=0.01, 1, 'last');
endpointY4 = indicesY4(endpeakY4);
Y4eff = Y4(startpointY4:endpointY4);
[z4, lags4] =xcorr(Xeff,Y4eff);
tc4 = lags4/fs;
Z4 = findpeaks(findpeaks(findpeaks(findpeaks(findpeaks(z4)))))
dz4 = diff(Z4)
figure(8)
plot(dz4);
title('Y4xcorr')
figure(9)
plot(Z4)
title('peaksz4')
