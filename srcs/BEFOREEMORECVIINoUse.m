clear, clc, close all
[x, fs] =audioread('mySpeech.wav');
X = x(:, 1);                      
[peaksX, indicesX] = findpeaks(X);
startpeakX = find(peaksX>=0.01, 1, 'first');
startpointX = indicesX(startpeakX);
endpeakX = find(peaksX>=0.01, 1, 'last');
endpointX = indicesX(endpeakX);
Xeff = X(startpointX:endpointX);

Xeff1 = Xeff(1:floor(length(Xeff)/7));
Xeff2 = Xeff(ceil(length(Xeff)/7):floor(length(Xeff)*2/7));
Xeff3 = Xeff(ceil(length(Xeff)*2/7):floor(length(Xeff)*3/7));
Xeff4 = Xeff(ceil(length(Xeff)*3/7):floor(length(Xeff)*4/7));
Xeff5 = Xeff(ceil(length(Xeff)*4/7):floor(length(Xeff)*5/7));
Xeff6 = Xeff(ceil(length(Xeff)*5/7):floor(length(Xeff)*6/7));
Xeff7 = Xeff(ceil(length(Xeff)*6/7):floor(length(Xeff)));

[Xeff1corr, lagsXeff1] = xcorr(Xeff1, 'coeff');
tcXeff1 = lagsXeff1/fs;
[Xeff2corr, lagsXeff2] = xcorr(Xeff2, 'coeff');
tcXeff2 = lagsXeff2/fs;
[Xeff3corr, lagsXeff3] = xcorr(Xeff3, 'coeff');
tcXeff3 = lagsXeff3/fs;
[Xeff4corr, lagsXeff4] = xcorr(Xeff4, 'coeff');
tcXeff4 = lagsXeff4/fs;
[Xeff5corr, lagsXeff5] = xcorr(Xeff5, 'coeff');
tcXeff5 = lagsXeff5/fs;
[Xeff6corr, lagsXeff6] = xcorr(Xeff6, 'coeff');
tcXeff6 = lagsXeff6/fs;
[Xeff7corr, lagsXeff7] = xcorr(Xeff7, 'coeff');
tcXeff7 = lagsXeff7/fs;


%forward
[y1, fsy1]=audioread('forward.wav');
Y1 = y1(:, 1);                      
[peaksY1, indicesY1] = findpeaks(Y1);
startpeakY1 = find(peaksY1>=0.01, 1, 'first');
startpointY1 = indicesY1(startpeakY1);
endpeakY1 = find(peaksY1>=0.01, 1, 'last');
endpointY1 = indicesY1(endpeakY1);
Y1eff = Y1(startpointY1:endpointY1);

Y1eff1 = Y1eff(1:floor(length(Y1eff)/7));
Y1eff2 = Y1eff(ceil(length(Y1eff)/7):floor(length(Y1eff)*2/7));
Y1eff3 = Y1eff(ceil(length(Y1eff)*2/7):floor(length(Y1eff)*3/7));
Y1eff4 = Y1eff(ceil(length(Y1eff)*3/7):floor(length(Y1eff)*4/7));
Y1eff5 = Y1eff(ceil(length(Y1eff)*4/7):floor(length(Y1eff)*5/7));
Y1eff6 = Y1eff(ceil(length(Y1eff)*5/7):floor(length(Y1eff)*6/7));
Y1eff7 = Y1eff(ceil(length(Y1eff)*6/7):floor(length(Y1eff)));

[Y1eff1corr, lagsY1eff1] = xcorr(Y1eff1, 'coeff');
tcY1eff1 = lagsY1eff1/fs;
[Y1eff2corr, lagsY1eff2] = xcorr(Y1eff2, 'coeff');
tcY1eff2 = lagsY1eff2/fs;
[Y1eff3corr, lagsY1eff3] = xcorr(Y1eff3, 'coeff');
tcY1eff3 = lagsY1eff3/fs;
[Y1eff4corr, lagsY1eff4] = xcorr(Y1eff4, 'coeff');
tcY1eff4 = lagsY1eff4/fs;
[Y1eff5corr, lagsY1eff5] = xcorr(Y1eff5, 'coeff');
tcY1eff5 = lagsY1eff5/fs;
[Y1eff6corr, lagsY1eff6] = xcorr(Y1eff6, 'coeff');
tcY1eff6 = lagsY1eff6/fs;
[Y1eff7corr, lagsY1eff7] = xcorr(Y1eff7, 'coeff');
tcY1eff7 = lagsY1eff7/fs;


%back
[y2, fsy2]=audioread('back.wav');
Y2 = y2(:, 1);                        % ���Ĥ@�n�D
[peaksY2, indicesY2] = findpeaks(Y2);
startpeakY2 = find(peaksY2>=0.01, 1, 'first');
startpointY2 = indicesY2(startpeakY2);
endpeakY2 = find(peaksY2>=0.01, 1, 'last');
endpointY2 = indicesY2(endpeakY2);
Y2eff = Y2(startpointY2:endpointY2);

Y2eff1 = Y2eff(1:floor(length(Y2eff)/7));
Y2eff2 = Y2eff(ceil(length(Y2eff)/7):floor(length(Y2eff)*2/7));
Y2eff3 = Y2eff(ceil(length(Y2eff)*2/7):floor(length(Y2eff)*3/7));
Y2eff4 = Y2eff(ceil(length(Y2eff)*3/7):floor(length(Y2eff)*4/7));
Y2eff5 = Y2eff(ceil(length(Y2eff)*4/7):floor(length(Y2eff)*5/7));
Y2eff6 = Y2eff(ceil(length(Y2eff)*5/7):floor(length(Y2eff)*6/7));
Y2eff7 = Y2eff(ceil(length(Y2eff)*6/7):floor(length(Y2eff)));

[Y2eff1corr, lagsY2eff1] = xcorr(Y2eff1, 'coeff');
tcY2eff1 = lagsY2eff1/fs;
[Y2eff2corr, lagsY2eff2] = xcorr(Y2eff2, 'coeff');
tcY2eff2 = lagsY2eff2/fs;
[Y2eff3corr, lagsY2eff3] = xcorr(Y2eff3, 'coeff');
tcY2eff3 = lagsY2eff3/fs;
[Y2eff4corr, lagsY2eff4] = xcorr(Y2eff4, 'coeff');
tcY2eff4 = lagsY2eff4/fs;
[Y2eff5corr, lagsY2eff5] = xcorr(Y2eff5, 'coeff');
tcY2eff5 = lagsY2eff5/fs;
[Y2eff6corr, lagsY2eff6] = xcorr(Y2eff6, 'coeff');
tcY2eff6 = lagsY2eff6/fs;
[Y2eff7corr, lagsY2eff7] = xcorr(Y2eff7, 'coeff');
tcY2eff7 = lagsY2eff7/fs;


%left
[y3, fsy3]=audioread('left.wav');
Y3 = y3(:, 1);                        % ���Ĥ@�n�D
[peaksY3, indicesY3] = findpeaks(Y3);
startpeakY3 = find(peaksY3>=0.01, 1, 'first');
startpointY3 = indicesY3(startpeakY3);
endpeakY3 = find(peaksY3>=0.01, 1, 'last');
endpointY3 = indicesY3(endpeakY3);
Y3eff = Y3(startpointY3:endpointY3);

Y3eff1 = Y3eff(1:floor(length(Y3eff)/7));
Y3eff2 = Y3eff(ceil(length(Y3eff)/7):floor(length(Y3eff)*2/7));
Y3eff3 = Y3eff(ceil(length(Y3eff)*2/7):floor(length(Y3eff)*3/7));
Y3eff4 = Y3eff(ceil(length(Y3eff)*3/7):floor(length(Y3eff)*4/7));
Y3eff5 = Y3eff(ceil(length(Y3eff)*4/7):floor(length(Y3eff)*5/7));
Y3eff6 = Y3eff(ceil(length(Y3eff)*5/7):floor(length(Y3eff)*6/7));
Y3eff7 = Y3eff(ceil(length(Y3eff)*6/7):floor(length(Y3eff)));

[Y3eff1corr, lagsY3eff1] = xcorr(Y3eff1, 'coeff');
tcY3eff1 = lagsY3eff1/fs;
[Y3eff2corr, lagsY3eff2] = xcorr(Y3eff2, 'coeff');
tcY3eff2 = lagsY3eff2/fs;
[Y3eff3corr, lagsY3eff3] = xcorr(Y3eff3, 'coeff');
tcY3eff3 = lagsY3eff3/fs;
[Y3eff4corr, lagsY3eff4] = xcorr(Y3eff4, 'coeff');
tcY3eff4 = lagsY3eff4/fs;
[Y3eff5corr, lagsY3eff5] = xcorr(Y3eff5, 'coeff');
tcY3eff5 = lagsY3eff5/fs;
[Y3eff6corr, lagsY3eff6] = xcorr(Y3eff6, 'coeff');
tcY3eff6 = lagsY3eff6/fs;
[Y3eff7corr, lagsY3eff7] = xcorr(Y3eff7, 'coeff');
tcY3eff7 = lagsY3eff7/fs;

%right
[y4, fsy4]=audioread('right.wav');
Y4 = y4(:, 1);                        % ���Ĥ@�n�D
[peaksY4, indicesY4] = findpeaks(Y4);
startpeakY4 = find(peaksY4>=0.01, 1, 'first');
startpointY4 = indicesY4(startpeakY4);
endpeakY4 = find(peaksY4>=0.01, 1, 'last');
endpointY4 = indicesY4(endpeakY4);
Y4eff = Y4(startpointY4:endpointY4);

Y4eff1 = Y4eff(1:floor(length(Y4eff)/7));
Y4eff2 = Y4eff(ceil(length(Y4eff)/7):floor(length(Y4eff)*2/7));
Y4eff3 = Y4eff(ceil(length(Y4eff)*2/7):floor(length(Y4eff)*3/7));
Y4eff4 = Y4eff(ceil(length(Y4eff)*3/7):floor(length(Y4eff)*4/7));
Y4eff5 = Y4eff(ceil(length(Y4eff)*4/7):floor(length(Y4eff)*5/7));
Y4eff6 = Y4eff(ceil(length(Y4eff)*5/7):floor(length(Y4eff)*6/7));
Y4eff7 = Y4eff(ceil(length(Y4eff)*6/7):floor(length(Y4eff)));

[Y4eff1corr, lagsY4eff1] = xcorr(Y4eff1, 'coeff');
tcY4eff1 = lagsY4eff1/fs;
[Y4eff2corr, lagsY4eff2] = xcorr(Y4eff2, 'coeff');
tcY4eff2 = lagsY4eff2/fs;
[Y4eff3corr, lagsY4eff3] = xcorr(Y4eff3, 'coeff');
tcY4eff3 = lagsY4eff3/fs;
[Y4eff4corr, lagsY4eff4] = xcorr(Y4eff4, 'coeff');
tcY4eff4 = lagsY4eff4/fs;
[Y4eff5corr, lagsY4eff5] = xcorr(Y4eff5, 'coeff');
tcY4eff5 = lagsY4eff5/fs;
[Y4eff6corr, lagsY4eff6] = xcorr(Y4eff6, 'coeff');
tcY4eff6 = lagsY4eff6/fs;
[Y4eff7corr, lagsY4eff7] = xcorr(Y4eff7, 'coeff');
tcY4eff7 = lagsY4eff7/fs;


%right
[y5, fsy5]=audioread('stop.wav');
Y5 = y5(:, 1);                        % ���Ĥ@�n�D
[peaksY5, indicesY5] = findpeaks(Y5);
startpeakY5 = find(peaksY5>=0.01, 1, 'first');
startpointY5 = indicesY5(startpeakY5);
endpeakY5 = find(peaksY5>=0.01, 1, 'last');
endpointY5 = indicesY5(endpeakY5);
Y5eff = Y5(startpointY5:endpointY5);

Y5eff1 = Y5eff(1:floor(length(Y5eff)/7));
Y5eff2 = Y5eff(ceil(length(Y5eff)/7):floor(length(Y5eff)*2/7));
Y5eff3 = Y5eff(ceil(length(Y5eff)*2/7):floor(length(Y5eff)*3/7));
Y5eff4 = Y5eff(ceil(length(Y5eff)*3/7):floor(length(Y5eff)*4/7));
Y5eff5 = Y5eff(ceil(length(Y5eff)*4/7):floor(length(Y5eff)*5/7));
Y5eff6 = Y5eff(ceil(length(Y5eff)*5/7):floor(length(Y5eff)*6/7));
Y5eff7 = Y5eff(ceil(length(Y5eff)*6/7):floor(length(Y5eff)));

[Y5eff1corr, lagsY5eff1] = xcorr(Y5eff1, 'coeff');
tcY5eff1 = lagsY5eff1/fs;
[Y5eff2corr, lagsY5eff2] = xcorr(Y5eff2, 'coeff');
tcY5eff2 = lagsY5eff2/fs;
[Y5eff3corr, lagsY5eff3] = xcorr(Y5eff3, 'coeff');
tcY5eff3 = lagsY5eff3/fs;
[Y5eff4corr, lagsY5eff4] = xcorr(Y5eff4, 'coeff');
tcY5eff4 = lagsY5eff4/fs;
[Y5eff5corr, lagsY5eff5] = xcorr(Y5eff5, 'coeff');
tcY5eff5 = lagsY5eff5/fs;
[Y5eff6corr, lagsY5eff6] = xcorr(Y5eff6, 'coeff');
tcY5eff6 = lagsY5eff6/fs;
[Y5eff7corr, lagsY5eff7] = xcorr(Y5eff7, 'coeff');
tcY5eff7 = lagsY5eff7/fs;

forward1 = Xeff1corr((length(Xeff1corr)+1)/2-1750 : (length(Xeff1corr)+1)/2+1750) - Y1eff1corr((length(Y1eff1corr)+1)/2-1750 : (length(Y1eff1corr)+1)/2+1750);
forward2 = Xeff2corr((length(Xeff2corr)+1)/2-1750 : (length(Xeff2corr)+1)/2+1750) - Y1eff2corr((length(Y1eff2corr)+1)/2-1750 : (length(Y1eff2corr)+1)/2+1750);
forward3 = Xeff3corr((length(Xeff3corr)+1)/2-1750 : (length(Xeff3corr)+1)/2+1750) - Y1eff3corr((length(Y1eff3corr)+1)/2-1750 : (length(Y1eff3corr)+1)/2+1750);
forward4 = Xeff4corr((length(Xeff4corr)+1)/2-1750 : (length(Xeff4corr)+1)/2+1750) - Y1eff4corr((length(Y1eff4corr)+1)/2-1750 : (length(Y1eff4corr)+1)/2+1750);
forward5 = Xeff5corr((length(Xeff5corr)+1)/2-1750 : (length(Xeff5corr)+1)/2+1750) - Y1eff5corr((length(Y1eff5corr)+1)/2-1750 : (length(Y1eff5corr)+1)/2+1750);
forward6 = Xeff6corr((length(Xeff6corr)+1)/2-1750 : (length(Xeff6corr)+1)/2+1750) - Y1eff6corr((length(Y1eff6corr)+1)/2-1750 : (length(Y1eff6corr)+1)/2+1750);
forward7 = Xeff7corr((length(Xeff7corr)+1)/2-1750 : (length(Xeff7corr)+1)/2+1750) - Y1eff7corr((length(Y1eff7corr)+1)/2-1750 : (length(Y1eff7corr)+1)/2+1750);

back1 = Xeff1corr((length(Xeff1corr)+1)/2-1750 : (length(Xeff1corr)+1)/2+1750) - Y2eff1corr((length(Y2eff1corr)+1)/2-1750 : (length(Y2eff1corr)+1)/2+1750);
back2 = Xeff2corr((length(Xeff2corr)+1)/2-1750 : (length(Xeff2corr)+1)/2+1750) - Y2eff2corr((length(Y2eff2corr)+1)/2-1750 : (length(Y2eff2corr)+1)/2+1750);
back3 = Xeff3corr((length(Xeff3corr)+1)/2-1750 : (length(Xeff3corr)+1)/2+1750) - Y2eff3corr((length(Y2eff3corr)+1)/2-1750 : (length(Y2eff3corr)+1)/2+1750);
back4 = Xeff4corr((length(Xeff4corr)+1)/2-1750 : (length(Xeff4corr)+1)/2+1750) - Y2eff4corr((length(Y2eff4corr)+1)/2-1750 : (length(Y2eff4corr)+1)/2+1750);
back5 = Xeff5corr((length(Xeff5corr)+1)/2-1750 : (length(Xeff5corr)+1)/2+1750) - Y2eff5corr((length(Y2eff5corr)+1)/2-1750 : (length(Y2eff5corr)+1)/2+1750);
back6 = Xeff6corr((length(Xeff6corr)+1)/2-1750 : (length(Xeff6corr)+1)/2+1750) - Y2eff6corr((length(Y2eff6corr)+1)/2-1750 : (length(Y2eff6corr)+1)/2+1750);
back7 = Xeff7corr((length(Xeff7corr)+1)/2-1750 : (length(Xeff7corr)+1)/2+1750) - Y2eff7corr((length(Y2eff7corr)+1)/2-1750 : (length(Y2eff7corr)+1)/2+1750);

left1 = Xeff1corr((length(Xeff1corr)+1)/2-1750 : (length(Xeff1corr)+1)/2+1750) - Y3eff1corr((length(Y3eff1corr)+1)/2-1750 : (length(Y3eff1corr)+1)/2+1750);
left2 = Xeff2corr((length(Xeff2corr)+1)/2-1750 : (length(Xeff2corr)+1)/2+1750) - Y3eff2corr((length(Y3eff2corr)+1)/2-1750 : (length(Y3eff2corr)+1)/2+1750);
left3 = Xeff3corr((length(Xeff3corr)+1)/2-1750 : (length(Xeff3corr)+1)/2+1750) - Y3eff3corr((length(Y3eff3corr)+1)/2-1750 : (length(Y3eff3corr)+1)/2+1750);
left4 = Xeff4corr((length(Xeff4corr)+1)/2-1750 : (length(Xeff4corr)+1)/2+1750) - Y3eff4corr((length(Y3eff4corr)+1)/2-1750 : (length(Y3eff4corr)+1)/2+1750);
left5 = Xeff5corr((length(Xeff5corr)+1)/2-1750 : (length(Xeff5corr)+1)/2+1750) - Y3eff5corr((length(Y3eff5corr)+1)/2-1750 : (length(Y3eff5corr)+1)/2+1750);
left6 = Xeff6corr((length(Xeff6corr)+1)/2-1750 : (length(Xeff6corr)+1)/2+1750) - Y3eff6corr((length(Y3eff6corr)+1)/2-1750 : (length(Y3eff6corr)+1)/2+1750);
left7 = Xeff7corr((length(Xeff7corr)+1)/2-1750 : (length(Xeff7corr)+1)/2+1750) - Y3eff7corr((length(Y3eff7corr)+1)/2-1750 : (length(Y3eff7corr)+1)/2+1750);

right1 = Xeff1corr((length(Xeff1corr)+1)/2-1750 : (length(Xeff1corr)+1)/2+1750) - Y4eff1corr((length(Y4eff1corr)+1)/2-1750 : (length(Y4eff1corr)+1)/2+1750);
right2 = Xeff2corr((length(Xeff2corr)+1)/2-1750 : (length(Xeff2corr)+1)/2+1750) - Y4eff2corr((length(Y4eff2corr)+1)/2-1750 : (length(Y4eff2corr)+1)/2+1750);
right3 = Xeff3corr((length(Xeff3corr)+1)/2-1750 : (length(Xeff3corr)+1)/2+1750) - Y4eff3corr((length(Y4eff3corr)+1)/2-1750 : (length(Y4eff3corr)+1)/2+1750);
right4 = Xeff4corr((length(Xeff4corr)+1)/2-1750 : (length(Xeff4corr)+1)/2+1750) - Y4eff4corr((length(Y4eff4corr)+1)/2-1750 : (length(Y4eff4corr)+1)/2+1750);
right5 = Xeff5corr((length(Xeff5corr)+1)/2-1750 : (length(Xeff5corr)+1)/2+1750) - Y4eff5corr((length(Y4eff5corr)+1)/2-1750 : (length(Y4eff5corr)+1)/2+1750);
right6 = Xeff6corr((length(Xeff6corr)+1)/2-1750 : (length(Xeff6corr)+1)/2+1750) - Y4eff6corr((length(Y4eff6corr)+1)/2-1750 : (length(Y4eff6corr)+1)/2+1750);
right7 = Xeff7corr((length(Xeff7corr)+1)/2-1750 : (length(Xeff7corr)+1)/2+1750) - Y4eff7corr((length(Y4eff7corr)+1)/2-1750 : (length(Y4eff7corr)+1)/2+1750);

stop1 = Xeff1corr((length(Xeff1corr)+1)/2-1750 : (length(Xeff1corr)+1)/2+1750) - Y5eff1corr((length(Y5eff1corr)+1)/2-1750 : (length(Y5eff1corr)+1)/2+1750);
stop2 = Xeff2corr((length(Xeff2corr)+1)/2-1750 : (length(Xeff2corr)+1)/2+1750) - Y5eff2corr((length(Y5eff2corr)+1)/2-1750 : (length(Y5eff2corr)+1)/2+1750);
stop3 = Xeff3corr((length(Xeff3corr)+1)/2-1750 : (length(Xeff3corr)+1)/2+1750) - Y5eff3corr((length(Y5eff3corr)+1)/2-1750 : (length(Y5eff3corr)+1)/2+1750);
stop4 = Xeff4corr((length(Xeff4corr)+1)/2-1750 : (length(Xeff4corr)+1)/2+1750) - Y5eff4corr((length(Y5eff4corr)+1)/2-1750 : (length(Y5eff4corr)+1)/2+1750);
stop5 = Xeff5corr((length(Xeff5corr)+1)/2-1750 : (length(Xeff5corr)+1)/2+1750) - Y5eff5corr((length(Y5eff5corr)+1)/2-1750 : (length(Y5eff5corr)+1)/2+1750);
stop6 = Xeff6corr((length(Xeff6corr)+1)/2-1750 : (length(Xeff6corr)+1)/2+1750) - Y5eff6corr((length(Y5eff6corr)+1)/2-1750 : (length(Y5eff6corr)+1)/2+1750);
stop7 = Xeff7corr((length(Xeff7corr)+1)/2-1750 : (length(Xeff7corr)+1)/2+1750) - Y5eff7corr((length(Y5eff7corr)+1)/2-1750 : (length(Y5eff7corr)+1)/2+1750);

forwardsum1 = sum(abs(findpeaks(forward1)));
forwardsum2 = sum(abs(findpeaks(forward2)));
forwardsum3 = sum(abs(findpeaks(forward3)));
forwardsum4 = sum(abs(findpeaks(forward4)));
forwardsum5 = sum(abs(findpeaks(forward5)));
forwardsum6 = sum(abs(findpeaks(forward6)));
forwardsum7 = sum(abs(findpeaks(forward7)));
forwardsum = [forwardsum1, forwardsum2, forwardsum3, forwardsum4, forwardsum5, forwardsum6, forwardsum7];

backsum1 = sum(abs(findpeaks(back1)));
backsum2 = sum(abs(findpeaks(back2)));
backsum3 = sum(abs(findpeaks(back3)));
backsum4 = sum(abs(findpeaks(back4)));
backsum5 = sum(abs(findpeaks(back5)));
backsum6 = sum(abs(findpeaks(back6)));
backsum7 = sum(abs(findpeaks(back7)));
backsum = [backsum1, backsum2, backsum3, backsum4, backsum5, backsum6, backsum7];

leftsum1 = sum(abs(findpeaks(left1)));
leftsum2 = sum(abs(findpeaks(left2)));
leftsum3 = sum(abs(findpeaks(left3)));
leftsum4 = sum(abs(findpeaks(left4)));
leftsum5 = sum(abs(findpeaks(left5)));
leftsum6 = sum(abs(findpeaks(left6)));
leftsum7 = sum(abs(findpeaks(left7)));
leftsum = [leftsum1, leftsum2, leftsum3, leftsum4, leftsum5, leftsum6, leftsum7];

rightsum1 = sum(abs(findpeaks(right1)));
rightsum2 = sum(abs(findpeaks(right2)));
rightsum3 = sum(abs(findpeaks(right3)));
rightsum4 = sum(abs(findpeaks(right4)));
rightsum5 = sum(abs(findpeaks(right5)));
rightsum6 = sum(abs(findpeaks(right6)));
rightsum7 = sum(abs(findpeaks(right7)));
rightsum = [rightsum1, rightsum2, rightsum3, rightsum4, rightsum5, rightsum6, rightsum7];

stopsum1 = sum(abs(findpeaks(stop1)));
stopsum2 = sum(abs(findpeaks(stop2)));
stopsum3 = sum(abs(findpeaks(stop3)));
stopsum4 = sum(abs(findpeaks(stop4)));
stopsum5 = sum(abs(findpeaks(stop5)));
stopsum6 = sum(abs(findpeaks(stop6)));
stopsum7 = sum(abs(findpeaks(stop7)));
stopsum = [stopsum1, stopsum2, stopsum3, stopsum4, stopsum5, stopsum6, stopsum7];

[a1, a2, a3, a4, a5, a6, a7] = textread('parameter.txt', '%f%f%f%f%f%f%f', 1);
[b1, b2, b3, b4, b5, b6, b7] = textread('parameter.txt', '%f%f%f%f%f%f%f', 1, 'headerlines', 1);
[c1, c2, c3, c4, c5, c6, c7] = textread('parameter.txt', '%f%f%f%f%f%f%f', 1, 'headerlines', 2);
[d1, d2, d3, d4, d5, d6, d7] = textread('parameter.txt', '%f%f%f%f%f%f%f', 1, 'headerlines', 3);
[e1, e2, e3, e4, e5, e6, e7] = textread('parameter.txt', '%f%f%f%f%f%f%f', 1, 'headerlines', 4);
forward = a1*forwardsum1+a2*forwardsum2+a3*forwardsum3+a4*forwardsum4+a5*forwardsum5+a6*forwardsum6+a7*forwardsum7;
back    = b1*backsum1   +b2*backsum2   +b3*backsum3   +b4*backsum4   +b5*backsum5   +b6*backsum6   +b7*backsum7;
left    = c1*leftsum1   +c2*leftsum2   +c3*leftsum3   +c4*leftsum4   +c5*leftsum5   +c6*leftsum6   +c7*leftsum7;
right   = d1*rightsum1  +d2*rightsum2  +d3*rightsum3  +d4*rightsum4  +d5*rightsum5  +d6*rightsum6  +d7*rightsum7;
stop    = e1*stopsum1   +e2*stopsum2   +e3*stopsum3   +e4*stopsum4   +e5*stopsum5   +e6*stopsum6   +e7*stopsum7;
a = [a1, a2, a3, a4, a5, a6, a7];
b = [b1, b2, b3, b4, b5, b6, b7];
c = [c1, c2, c3, c4, c5, c6, c7];
d = [d1, d2, d3, d4, d5, d6, d7];
e = [e1, e2, e3, e4, e5, e6, e7];
goal = left
        if goal == forward
            allowb = 0;
            allowc = 0;
            allowd = 0;
            allowe = 0;
        while (forward>back || forward>right || forward>left || forward>stop)
        for i = 1:7
            if forwardsum(i)> backsum(i)
               a(i) = a(i) - 0.01
               b(i) = b(i) + 0.01
               allowb = allowb|0;
            else
               a(i) = a(i) + 0.01
               b(i) = b(i) - 0.01
               allowb = allowb|1;
            end
            if forwardsum(i)> leftsum(i)
               a(i) = a(i) - 0.01
               c(i) = c(i) + 0.01
               allowc = allowc|0;
            else
               a(i) = a(i) + 0.01
               c(i) = c(i) - 0.01
               allowc = allowc|1;
            end
            if forwardsum(i)> rightsum(i)
               a(i) = a(i) - 0.01 
               d(i) = d(i) + 0.01
               allowd = allowd|0;
            else
               a(i) = a(i) + 0.01 
               d(i) = d(i) - 0.01 
               allowd = allowd|1;
            end
            if forwardsum(i)> stopsum(i)
               a(i) = a(i) - 0.01 
               e(i) = e(i) + 0.01 
               allowe = allowe|0;
            else
               a(i) = a(i) + 0.01 
               e(i) = e(i) - 0.01   
               allowe = allowe|1;
            end
        end
        forward = a(1)*forwardsum1+a(2)*forwardsum2+a(3)*forwardsum3+a(4)*forwardsum4+a(5)*forwardsum5+a(6)*forwardsum6+a(7)*forwardsum7;
        back    = b(1)*backsum1   +b(2)*backsum2   +b(3)*backsum3   +b(4)*backsum4   +b(5)*backsum5   +b(6)*backsum6   +b(7)*backsum7;
        left    = c(1)*leftsum1   +c(2)*leftsum2   +c(3)*leftsum3   +c(4)*leftsum4   +c(5)*leftsum5   +c(6)*leftsum6   +c(7)*leftsum7;
        right   = d(1)*rightsum1  +d(2)*rightsum2  +d(3)*rightsum3  +d(4)*rightsum4  +d(5)*rightsum5  +d(6)*rightsum6  +d(7)*rightsum7;
        stop    = e(1)*stopsum1   +e(2)*stopsum2   +e(3)*stopsum3   +e(4)*stopsum4   +e(5)*stopsum5   +e(6)*stopsum6   +e(7)*stopsum7;
        if allowb&&allowc&&allowd&&allowe == 0
            break;
        end
        end
        
        elseif goal == back
            allowb = 0;
            allowc = 0;
            allowd = 0;
            allowe = 0;
        while (back>forward || back>right || back>left || back>stop) 
        for i = 1:7
            if backsum(i)> forwardsum(i)
               b(i) = b(i) - 0.01 
               a(i) = a(i) + 0.01 
               allowb = allowb|0;
            else
               b(i) = b(i) + 0.01 
               a(i) = a(i) - 0.01  
               allowb = allowb|1;
            end
            if backsum(i)> leftsum(i)
               b(i) = b(i) - 0.01 
               c(i) = c(i) + 0.01 
               allowc = allowc|0;
            else
               b(i) = b(i) + 0.01 
               c(i) = c(i) - 0.01
               allowc = allowc|1;
            end
            if backsum(i)> rightsum(i)
               b(i) = b(i) - 0.01 
               d(i) = d(i) + 0.01 
               allowd = allowd|0;
            else
               b(i) = b(i) + 0.01 
               d(i) = d(i) - 0.01
               allowd = allowd|0;
            end
            if backsum(i)> stopsum(i)
               b(i) = b(i) - 0.01 
               e(i) = e(i) + 0.01 
               allowe = allowe|0;
            else
               b(i) = b(i) + 0.01 
               e(i) = e(i) - 0.01 
               allowe = allowe|1;
            end
        end
        forward = a(1)*forwardsum1+a(2)*forwardsum2+a(3)*forwardsum3+a(4)*forwardsum4+a(5)*forwardsum5+a(6)*forwardsum6+a(7)*forwardsum7;
        back    = b(1)*backsum1   +b(2)*backsum2   +b(3)*backsum3   +b(4)*backsum4   +b(5)*backsum5   +b(6)*backsum6   +b(7)*backsum7;
        left    = c(1)*leftsum1   +c(2)*leftsum2   +c(3)*leftsum3   +c(4)*leftsum4   +c(5)*leftsum5   +c(6)*leftsum6   +c(7)*leftsum7;
        right   = d(1)*rightsum1  +d(2)*rightsum2  +d(3)*rightsum3  +d(4)*rightsum4  +d(5)*rightsum5  +d(6)*rightsum6  +d(7)*rightsum7;
        stop    = e(1)*stopsum1   +e(2)*stopsum2   +e(3)*stopsum3   +e(4)*stopsum4   +e(5)*stopsum5   +e(6)*stopsum6   +e(7)*stopsum7;
        if allowb&&allowc&&allowd&&allowe == 0
            break;
        end
        end
        elseif goal == left
            allowb = 0;
            allowc = 0;
            allowd = 0;
            allowe = 0;
        while (left>back || left>forward || left>right || left>stop)
        for i = 1:7
            if leftsum(i)> backsum(i)
               c(i) = c(i) - 0.01 
               b(i) = b(i) + 0.01 
               allowb = allowb|0;
            else
               c(i) = c(i) + 0.01 
               b(i) = b(i) - 0.01 
               allowb = allowb|1;
            end
            if leftsum(i)> forwardsum(i)
               c(i) = c(i) - 0.01 
               a(i) = a(i) + 0.01 
               allowc = allowc|0;
            else
               c(i) = c(i) + 0.01 
               a(i) = a(i) - 0.01  
               allowc = allowc|1;
            end
            if leftsum(i)> rightsum(i)
               c(i) = c(i) - 0.01 
               d(i) = d(i) + 0.01 
               allowd = allowd|0;
            else
               c(i) = c(i) + 0.01 
               d(i) = d(i) - 0.01 
               allowd = allowd|1;
            end
            if leftsum(i)> stopsum(i)
               c(i) = c(i) - 0.01 
               e(i) = e(i) + 0.01 
               allowe = allowe|0;
            else
               c(i) = c(i) + 0.01 
               e(i) = e(i) - 0.01   
               allowe = allowe|1;
            end
        end
        forward = a(1)*forwardsum1+a(2)*forwardsum2+a(3)*forwardsum3+a(4)*forwardsum4+a(5)*forwardsum5+a(6)*forwardsum6+a(7)*forwardsum7;
        back    = b(1)*backsum1   +b(2)*backsum2   +b(3)*backsum3   +b(4)*backsum4   +b(5)*backsum5   +b(6)*backsum6   +b(7)*backsum7;
        left    = c(1)*leftsum1   +c(2)*leftsum2   +c(3)*leftsum3   +c(4)*leftsum4   +c(5)*leftsum5   +c(6)*leftsum6   +c(7)*leftsum7;
        right   = d(1)*rightsum1  +d(2)*rightsum2  +d(3)*rightsum3  +d(4)*rightsum4  +d(5)*rightsum5  +d(6)*rightsum6  +d(7)*rightsum7;
        stop    = e(1)*stopsum1   +e(2)*stopsum2   +e(3)*stopsum3   +e(4)*stopsum4   +e(5)*stopsum5   +e(6)*stopsum6   +e(7)*stopsum7;
        if allowb&&allowc&&allowd&&allowe == 0
            break;
        end
        end 
            
        elseif goal == right
        while (right>back || right>forward || right>left || right>stop)
        for i = 1:7
            if rightsum(i)> backsum(i)
               d(i) = d(i) - 0.01 
               b(i) = b(i) + 0.01 
            else
               d(i) = d(i) + 0.01 
               b(i) = b(i) - 0.01  
            end
            if rightsum(i)> leftsum(i)
               d(i) = d(i) - 0.01 
               c(i) = c(i) + 0.01 
            else
               d(i) = d(i) + 0.01 
               c(i) = c(i) - 0.01  
            end
            if rightsum(i)> forwardsum(i)
               d(i) = d(i) - 0.01 
               a(i) = a(i) + 0.01 
            else
               d(i) = d(i) + 0.01 
               a(i) = a(i) - 0.01 
            end
            if rightsum(i)> stopsum(i)
               d(i) = d(i) - 0.01 
               e(i) = e(i) + 0.01 
            else
               d(i) = d(i) + 0.01 
               e(i) = e(i) - 0.01    
            end
        end
        forward = a(1)*forwardsum1+a(2)*forwardsum2+a(3)*forwardsum3+a(4)*forwardsum4+a(5)*forwardsum5+a(6)*forwardsum6+a(7)*forwardsum7 ;
        back    = b(1)*backsum1   +b(2)*backsum2   +b(3)*backsum3   +b(4)*backsum4   +b(5)*backsum5   +b(6)*backsum6   +b(7)*backsum7;
        left    = c(1)*leftsum1   +c(2)*leftsum2   +c(3)*leftsum3   +c(4)*leftsum4   +c(5)*leftsum5   +c(6)*leftsum6   +c(7)*leftsum7;
        right   = d(1)*rightsum1  +d(2)*rightsum2  +d(3)*rightsum3  +d(4)*rightsum4  +d(5)*rightsum5  +d(6)*rightsum6  +d(7)*rightsum7;
        stop    = e(1)*stopsum1   +e(2)*stopsum2   +e(3)*stopsum3   +e(4)*stopsum4   +e(5)*stopsum5   +e(6)*stopsum6   +e(7)*stopsum7;
        end
        elseif goal == stop
            while (stop>back || stop>right || stop>left || stop>forward)
        for i = 1:7
            if stopsum(i)> backsum(i)
               e(i) = e(i) - 0.01 
               b(i) = b(i) + 0.01 
            else
               e(i) = e(i) + 0.01 
               b(i) = b(i) - 0.01  
            end
            if stopsum(i)> leftsum(i)
               e(i) = e(i) - 0.01 
               c(i) = c(i) + 0.01 
            else
               e(i) = e(i) + 0.01 
               c(i) = c(i) - 0.01  
            end
            if stopsum(i)> rightsum(i)
               e(i) = e(i) - 0.01 
               d(i) = d(i) + 0.01 
            else
               e(i) = e(i) + 0.01 
               d(i) = d(i) - 0.01 
            end
            if stopsum(i)> forwardsum(i)
               e(i) = e(i) - 0.01 
               a(i) = a(i) + 0.01 
            else
               e(i) = e(i) + 0.01 
               a(i) = a(i) - 0.01    
            end
        end
        forward = a(1)*forwardsum1+a(2)*forwardsum2+a(3)*forwardsum3+a(4)*forwardsum4+a(5)*forwardsum5+a(6)*forwardsum6+a(7)*forwardsum7;
        back    = b(1)*backsum1   +b(2)*backsum2   +b(3)*backsum3   +b(4)*backsum4   +b(5)*backsum5   +b(6)*backsum6   +b(7)*backsum7;
        left    = c(1)*leftsum1   +c(2)*leftsum2   +c(3)*leftsum3   +c(4)*leftsum4   +c(5)*leftsum5   +c(6)*leftsum6   +c(7)*leftsum7;
        right   = d(1)*rightsum1  +d(2)*rightsum2  +d(3)*rightsum3  +d(4)*rightsum4  +d(5)*rightsum5  +d(6)*rightsum6  +d(7)*rightsum7;
        stop    = e(1)*stopsum1   +e(2)*stopsum2   +e(3)*stopsum3   +e(4)*stopsum4   +e(5)*stopsum5   +e(6)*stopsum6   +e(7)*stopsum7;
        end
        end
fid = fopen('parameter.txt', 'w+');
fprintf(fid, '%6.3f\t', a);
fprintf(fid, '\n');
fprintf(fid, '%6.3f\t', b);
fprintf(fid, '\n');
fprintf(fid, '%6.3f\t', c);
fprintf(fid, '\n');
fprintf(fid, '%6.3f\t', d);
fprintf(fid, '\n');
fprintf(fid, '%6.3f\t', e);
fclose(fid);
        forward = a(1)*forwardsum1+a(2)*forwardsum2+a(3)*forwardsum3+a(4)*forwardsum4+a(5)*forwardsum5+a(6)*forwardsum6+a(7)*forwardsum7
        back    = b(1)*backsum1   +b(2)*backsum2   +b(3)*backsum3   +b(4)*backsum4   +b(5)*backsum5   +b(6)*backsum6   +b(7)*backsum7
        left    = c(1)*leftsum1   +c(2)*leftsum2   +c(3)*leftsum3   +c(4)*leftsum4   +c(5)*leftsum5   +c(6)*leftsum6   +c(7)*leftsum7
        right   = d(1)*rightsum1  +d(2)*rightsum2  +d(3)*rightsum3  +d(4)*rightsum4  +d(5)*rightsum5  +d(6)*rightsum6  +d(7)*rightsum7
        stop    = e(1)*stopsum1   +e(2)*stopsum2   +e(3)*stopsum3   +e(4)*stopsum4   +e(5)*stopsum5   +e(6)*stopsum6   +e(7)*stopsum7


















































































