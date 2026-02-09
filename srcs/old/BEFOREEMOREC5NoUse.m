clear, clc, close all
[x, fs] =audioread('右轉2.wav');
X = x(:, 1);                      
[peaksX, indicesX] = findpeaks(X);
startpeakX = find(peaksX>=0.01, 1, 'first');
startpointX = indicesX(startpeakX);
endpeakX = find(peaksX>=0.01, 1, 'last');
endpointX = indicesX(endpeakX);
Xeff = X(startpointX:endpointX);
Xeffselfcorr = xcorr(Xeff, 'coeff');
plot(Xeffselfcorr) 
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

forward1 = Xeff1corr(round(length(Xeff1corr)/2)-1750 : round(length(Xeff1corr)/2)+1750) - Y1eff1corr(round(length(Y1eff1corr)/2)-1750 : round(length(Y1eff1corr)/2)+1750);
forward2 = Xeff2corr(round(length(Xeff2corr)/2)-1750 : round(length(Xeff2corr)/2)+1750) - Y1eff2corr(round(length(Y1eff2corr)/2)-1750 : round(length(Y1eff2corr)/2)+1750);
forward3 = Xeff3corr(round(length(Xeff3corr)/2)-1750 : round(length(Xeff3corr)/2)+1750) - Y1eff3corr(round(length(Y1eff3corr)/2)-1750 : round(length(Y1eff3corr)/2)+1750);
forward4 = Xeff4corr(round(length(Xeff4corr)/2)-1750 : round(length(Xeff4corr)/2)+1750) - Y1eff4corr(round(length(Y1eff4corr)/2)-1750 : round(length(Y1eff4corr)/2)+1750);
forward5 = Xeff5corr(round(length(Xeff5corr)/2)-1750 : round(length(Xeff5corr)/2)+1750) - Y1eff5corr(round(length(Y1eff5corr)/2)-1750 : round(length(Y1eff5corr)/2)+1750);
forward6 = Xeff6corr(round(length(Xeff6corr)/2)-1750 : round(length(Xeff6corr)/2)+1750) - Y1eff6corr(round(length(Y1eff6corr)/2)-1750 : round(length(Y1eff6corr)/2)+1750);
forward7 = Xeff7corr(round(length(Xeff7corr)/2)-1750 : round(length(Xeff7corr)/2)+1750) - Y1eff7corr(round(length(Y1eff7corr)/2)-1750 : round(length(Y1eff7corr)/2)+1750);

back1 = Xeff1corr(round(length(Xeff1corr)/2)-1750 : round(length(Xeff1corr)/2)+1750) - Y2eff1corr(round(length(Y2eff1corr)/2)-1750 : round(length(Y2eff1corr)/2)+1750);
back2 = Xeff2corr(round(length(Xeff2corr)/2)-1750 : round(length(Xeff2corr)/2)+1750) - Y2eff2corr(round(length(Y2eff2corr)/2)-1750 : round(length(Y2eff2corr)/2)+1750);
back3 = Xeff3corr(round(length(Xeff3corr)/2)-1750 : round(length(Xeff3corr)/2)+1750) - Y2eff3corr(round(length(Y2eff3corr)/2)-1750 : round(length(Y2eff3corr)/2)+1750);
back4 = Xeff4corr(round(length(Xeff4corr)/2)-1750 : round(length(Xeff4corr)/2)+1750) - Y2eff4corr(round(length(Y2eff4corr)/2)-1750 : round(length(Y2eff4corr)/2)+1750);
back5 = Xeff5corr(round(length(Xeff5corr)/2)-1750 : round(length(Xeff5corr)/2)+1750) - Y2eff5corr(round(length(Y2eff5corr)/2)-1750 : round(length(Y2eff5corr)/2)+1750);
back6 = Xeff6corr(round(length(Xeff6corr)/2)-1750 : round(length(Xeff6corr)/2)+1750) - Y2eff6corr(round(length(Y2eff6corr)/2)-1750 : round(length(Y2eff6corr)/2)+1750);
back7 = Xeff7corr(round(length(Xeff7corr)/2)-1750 : round(length(Xeff7corr)/2)+1750) - Y2eff7corr(round(length(Y2eff7corr)/2)-1750 : round(length(Y2eff7corr)/2)+1750);

left1 = Xeff1corr(round(length(Xeff1corr)/2)-1750 : round(length(Xeff1corr)/2)+1750) - Y3eff1corr(round(length(Y3eff1corr)/2)-1750 : round(length(Y3eff1corr)/2)+1750);
left2 = Xeff2corr(round(length(Xeff2corr)/2)-1750 : round(length(Xeff2corr)/2)+1750) - Y3eff2corr(round(length(Y3eff2corr)/2)-1750 : round(length(Y3eff2corr)/2)+1750);
left3 = Xeff3corr(round(length(Xeff3corr)/2)-1750 : round(length(Xeff3corr)/2)+1750) - Y3eff3corr(round(length(Y3eff3corr)/2)-1750 : round(length(Y3eff3corr)/2)+1750);
left4 = Xeff4corr(round(length(Xeff4corr)/2)-1750 : round(length(Xeff4corr)/2)+1750) - Y3eff4corr(round(length(Y3eff4corr)/2)-1750 : round(length(Y3eff4corr)/2)+1750);
left5 = Xeff5corr(round(length(Xeff5corr)/2)-1750 : round(length(Xeff5corr)/2)+1750) - Y3eff5corr(round(length(Y3eff5corr)/2)-1750 : round(length(Y3eff5corr)/2)+1750);
left6 = Xeff6corr(round(length(Xeff6corr)/2)-1750 : round(length(Xeff6corr)/2)+1750) - Y3eff6corr(round(length(Y3eff6corr)/2)-1750 : round(length(Y3eff6corr)/2)+1750);
left7 = Xeff7corr(round(length(Xeff7corr)/2)-1750 : round(length(Xeff7corr)/2)+1750) - Y3eff7corr(round(length(Y3eff7corr)/2)-1750 : round(length(Y3eff7corr)/2)+1750);

right1 = Xeff1corr(round(length(Xeff1corr)/2)-1750 : round(length(Xeff1corr)/2)+1750) - Y4eff1corr(round(length(Y4eff1corr)/2)-1750 : round(length(Y4eff1corr)/2)+1750);
right2 = Xeff2corr(round(length(Xeff2corr)/2)-1750 : round(length(Xeff2corr)/2)+1750) - Y4eff2corr(round(length(Y4eff2corr)/2)-1750 : round(length(Y4eff2corr)/2)+1750);
right3 = Xeff3corr(round(length(Xeff3corr)/2)-1750 : round(length(Xeff3corr)/2)+1750) - Y4eff3corr(round(length(Y4eff3corr)/2)-1750 : round(length(Y4eff3corr)/2)+1750);
right4 = Xeff4corr(round(length(Xeff4corr)/2)-1750 : round(length(Xeff4corr)/2)+1750) - Y4eff4corr(round(length(Y4eff4corr)/2)-1750 : round(length(Y4eff4corr)/2)+1750);
right5 = Xeff5corr(round(length(Xeff5corr)/2)-1750 : round(length(Xeff5corr)/2)+1750) - Y4eff5corr(round(length(Y4eff5corr)/2)-1750 : round(length(Y4eff5corr)/2)+1750);
right6 = Xeff6corr(round(length(Xeff6corr)/2)-1750 : round(length(Xeff6corr)/2)+1750) - Y4eff6corr(round(length(Y4eff6corr)/2)-1750 : round(length(Y4eff6corr)/2)+1750);
right7 = Xeff7corr(round(length(Xeff7corr)/2)-1750 : round(length(Xeff7corr)/2)+1750) - Y4eff7corr(round(length(Y4eff7corr)/2)-1750 : round(length(Y4eff7corr)/2)+1750);

stop1 = Xeff1corr(round(length(Xeff1corr)/2)-1750 : round(length(Xeff1corr)/2)+1750) - Y5eff1corr(round(length(Y5eff1corr)/2)-1750 : round(length(Y5eff1corr)/2)+1750);
stop2 = Xeff2corr(round(length(Xeff2corr)/2)-1750 : round(length(Xeff2corr)/2)+1750) - Y5eff2corr(round(length(Y5eff2corr)/2)-1750 : round(length(Y5eff2corr)/2)+1750);
stop3 = Xeff3corr(round(length(Xeff3corr)/2)-1750 : round(length(Xeff3corr)/2)+1750) - Y5eff3corr(round(length(Y5eff3corr)/2)-1750 : round(length(Y5eff3corr)/2)+1750);
stop4 = Xeff4corr(round(length(Xeff4corr)/2)-1750 : round(length(Xeff4corr)/2)+1750) - Y5eff4corr(round(length(Y5eff4corr)/2)-1750 : round(length(Y5eff4corr)/2)+1750);
stop5 = Xeff5corr(round(length(Xeff5corr)/2)-1750 : round(length(Xeff5corr)/2)+1750) - Y5eff5corr(round(length(Y5eff5corr)/2)-1750 : round(length(Y5eff5corr)/2)+1750);
stop6 = Xeff6corr(round(length(Xeff6corr)/2)-1750 : round(length(Xeff6corr)/2)+1750) - Y5eff6corr(round(length(Y5eff6corr)/2)-1750 : round(length(Y5eff6corr)/2)+1750);
stop7 = Xeff7corr(round(length(Xeff7corr)/2)-1750 : round(length(Xeff7corr)/2)+1750) - Y5eff7corr(round(length(Y5eff7corr)/2)-1750 : round(length(Y5eff7corr)/2)+1750);

forwardmax1 = max(forward1);
forwardmax2 = max(forward2);
forwardmax3 = max(forward3);
forwardmax4 = max(forward4);
forwardmax5 = max(forward5);
forwardmax6 = max(forward6);
forwardmax7 = max(forward7);

backmax1 = max(back1);
backmax2 = max(back2);
backmax3 = max(back3);
backmax4 = max(back4);
backmax5 = max(back5);
backmax6 = max(back6);
backmax7 = max(back7);

leftmax1 = max(left1);
leftmax2 = max(left2);
leftmax3 = max(left3);
leftmax4 = max(left4);
leftmax5 = max(left5);
leftmax6 = max(left6);
leftmax7 = max(left7);

rightmax1 = max(right1);
rightmax2 = max(right2);
rightmax3 = max(right3);
rightmax4 = max(right4);
rightmax5 = max(right5);
rightmax6 = max(right6);
rightmax7 = max(right7);

stopmax1 = max(stop1);
stopmax2 = max(stop2);
stopmax3 = max(stop3);
stopmax4 = max(stop4);
stopmax5 = max(stop5);
stopmax6 = max(stop6);
stopmax7 = max(stop7);

forward = forwardmax1+forwardmax2+forwardmax3+forwardmax4+forwardmax5+forwardmax6+forwardmax7
back = backmax1+backmax2+backmax3+backmax4+backmax5+backmax6+backmax7
left = leftmax1+leftmax2+leftmax3+leftmax4+leftmax5+leftmax6+leftmax7
right = rightmax1+rightmax2+rightmax3+rightmax4+rightmax5+rightmax6+rightmax7
stop = stopmax1+stopmax2+stopmax3+stopmax4+stopmax5+stopmax6+stopmax7