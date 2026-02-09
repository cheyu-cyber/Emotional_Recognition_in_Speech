clear, clc, close all
[x, fs] = audioread('maleAngry_18.wav');  % �פJ���T��
X = x(:, 1);                        % ���Ĥ@�n�D
N = length(X);                      % �`����
t = (0:N-1)/fs;                     % ���ɶ�
logx = log(abs(X));
%�ɰ�i��
figure(1)
plot(t, X)
xlim([0 max(t)])
ylim([-1.1*max(abs(X)) 1.1*max(abs(X))])
grid on
xlabel('Time(s)')
ylabel('Amplitude')
title('timevariant')
%�W�v��ɶ���?
figure(2)
% �W�Ф��R
w = hann(N, 'periodic'); %symmetric for filter design, periodic for generic design
[Xx, f] = periodogram(X, w, N, fs, 'power');
Xx = 10*log10(Xx/sqrt(2));
%[s,frequency,time,p] = 
spectrogram(X, [], [], [], fs, 'yaxis');
%maxp = zeros(8,1);
%indexmaxp = zeros(8,1);
%for i = 1:8
 %   [maxp(i), indexmaxp(i)] = max(p(:,i));
%end
%maxp = log(maxp);
%fre = zeros(8,1);
%for i = 1:8
%    fre(i) = frequency(indexmaxp(i));
%end
box on
xlabel('Time(ms)')
ylabel('Frequency(kHz)')
title('spectogram')
h = colorbar;
ylabel(h, 'Magnitude(dB)')

% �j�׹��W�v��
figure(3)
plot(f,Xx)
xlim([0 max(f)])
grid on
title('�j�׹��W�v��')
xlabel('Frequency(Hz)')
ylabel('Magnitude(dB)')
% �T�� histogram
figure(4)
histogram(X)
xlim([-1.1*max(abs(X)) 1.1*max(abs(X))])
grid on
xlabel('�T���q��')
ylabel('Number of samples')
title('�T�����v������')
%�j�� HISTOGRAM
figure(5)
histogram(logx)
xlim([-1.1*max(abs(logx)) 1.1*max(abs(logx))])
grid on
xlabel('Magnitude(dB)')
ylabel('Number of samples')
title('�j�׾��v������')
% �۬������?
[R, lags] = xcorr(X, 'coeff');
tc = lags/fs;
figure(6)
plot(tc, R)
grid on
xlim([-max(tc) max(tc)])
xlabel('Delay, s')
ylabel('correlation')
title('Self-correlation')
% �̤j�ȻP�̤p��
maxvalue = max(X);
minvalue = min(X);
disp(['Max = ' num2str(maxvalue)])
disp(['Min = ' num2str(minvalue)])
 
%�����P�觡��
meanvalue = mean(X);
RMSvalue = std(X);
disp(['Mean = ' num2str(meanvalue)])
disp(['RMS = ' num2str(RMSvalue)])
% �ʺA�d��
D = 20*log10(maxvalue/min(abs(nonzeros(X))));
disp(['Dynamic range = ' num2str(D) ' dB'])
% compute and display the crest factor
Q = maxvalue/RMSvalue;
disp(['Crest factor Q = ' num2str(Q)])
% compute and display the autocorrelation time
[pks, ind] = findpeaks(R);
[~, idx] = sort(pks, 'descend');
pks(idx(2));
ind(idx(2));
RT = abs(ind(idx(2))-N)/fs;
disp(['Fundamental Frequency = ' num2str(1/RT) ' Hz'])
fIndex = find(Xx == max(Xx), 1, 'first');
maxFvalue = f(fIndex);
commandwindow