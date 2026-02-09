deviceReader = audioDeviceReader;
setup(deviceReader)
fileWriter = dsp.AudioFileWriter('mySpeech.wav','FileFormat','WAV');
disp('Speak into microphone now.')
tic
while toc < 2
    acquiredAudio = deviceReader();
    fileWriter(acquiredAudio);
end
disp('Recording complete.')
release(deviceReader)
release(fileWriter)
[y, fs] = audioread(mySpeech.wav);