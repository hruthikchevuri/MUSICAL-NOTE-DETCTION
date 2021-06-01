[sample_1,fs] = audioread('sample_1.wav');
sample_1 = sample_1(:,1);
%soundsc(sample_1,fs);


%subtask0 :- filter   

sample_1 = bandpass(sample_1,[20 8000],fs);

t_int = 1/fs;
n = length(sample_1);
t = (0:t_int:(n-1)*t_int);
plot(t,sample_1);
xlabel('time(sec)');
ylabel('Amplitude');
grid on;

% subtask1 :- segmentation

audiowrite('re1.wav',sample_1,fs);


fileReader = dsp.AudioFileReader('re1.wav');
VAD = voiceActivityDetector;

f0 = [];
while ~isDone(fileReader)
    x = fileReader();
    
    if VAD(x) > 0.8
        decision = pitch(x,fileReader.SampleRate, ...
            "WindowLength",size(x,1), ...
            "OverlapLength",0, ...
            "Range",[200,380]);
    else
        decision = NaN;
    end
    f0 = [f0;decision];
end

ti = linspace(0,(length(f0)*fileReader.SamplesPerFrame)/fileReader.SampleRate,length(f0));
%scatter(ti,f0);
%ylabel('Fundamental Frequency (Hz)')
%xlabel('Time (s)')
%grid on

hr = abs(diff(f0));
values = find(hr>=10);
time_div = ti(values);
idx = time_div < 1;
t_0 = time_div(idx);
t_11 = time_div(~idx);
idc = t_11 < 2;
t_1 = t_11(idc);
t_22 = t_11(~idc);
ida = t_22 < 3;
t_2 = t_22(ida);
t_3 = t_22(~ida);

figure;
subplot(1,4,1);
indexrange = t>=t_0(1) & t<=t_1(1);
segment_1 = sample_1(indexrange);
plot(segment_1);grid on;
%soundsc(segment_1,fs);
subplot(1,4,2);
indexrange = t>=t_1(1) & t<=t_2(1);
segment_2 = sample_1(indexrange);
plot(segment_2);grid on;
%soundsc(segment_2,fs);
subplot(1,4,3);
indexrange = t>=t_2(1) & t<=t_3(1);
segment_3 = sample_1(indexrange);
plot(segment_3);grid on;
%soundsc(segment_3,fs);
subplot(1,4,4);
indexrange = t>=t_3(1) & t<=t_3(1)+1;
segment_4 = sample_1(indexrange);
plot(segment_4);grid on;
%soundsc(segment_4,fs);

%subtask2 :- transcription
figure;
subplot(2,2,1);
n_seg = length(segment_1);
f = fs/n_seg.*(0:n_seg-1);
seg1_fft = fft(segment_1);
seg1_fft = abs(seg1_fft(1:n_seg))./(n_seg/2);
plot(f,seg1_fft);xlim([0 5000]);grid on;
subplot(2,2,2);
n_seg = length(segment_2);
f = fs/n_seg.*(0:n_seg-1);
seg2_fft = fft(segment_2);
seg2_fft = abs(seg2_fft(1:n_seg))./(n_seg/2);
plot(f,seg2_fft);xlim([0 5000]);grid on;
subplot(2,2,3);
n_seg = length(segment_3);
f = fs/n_seg.*(0:n_seg-1);
seg3_fft = fft(segment_3);
seg3_fft = abs(seg3_fft(1:n_seg))./(n_seg/2);
plot(f,seg3_fft);xlim([0 5000]);grid on;
subplot(2,2,4);
n_seg = length(segment_4);
f = fs/n_seg.*(0:n_seg-1);
seg4_fft = fft(segment_4);
seg4_fft = abs(seg4_fft(1:n_seg))./(n_seg/2);
plot(f,seg4_fft);xlim([0 5000]);grid on;

f0 = pitch(segment_1,fs);

f1 = pitch(segment_2,fs);

f2 = pitch(segment_3,fs);

f3 = pitch(segment_4,fs);

f0_seg1 = mode(f0);
f0_seg2 = mode(f1);
f0_seg3 = mode(f2);
f0_seg4 = mode(f3);

freq = [f0_seg1 f0_seg2 f0_seg3 f0_seg4];

notes = ['C','C','D','D','E','F','F','G','G','A','A','B','C','C','D','D','E','F','F','G','G','A','A','B','C','C','D','D','E','F','F','G','G','A','A','B','C','C','D','D','E','F',...
         'F','G','G','A','A','B','C','C','D','D','E','F','F','G','G','A','A','B','C','C','D','D','E','F','F','G','G','A','A','B','C','C','D','D','E','F','F','G','G','A','A','B','C','C','D','D',...
         'E','F','F','G','G','A','A','B','C','C','D','D','E','F','F','G','G','A','A','B'];


%f_absval = [262, 293.66, 329.63];

f_absval = [16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87, 32.70, 34.65, 36.71, 38.89, 41.20, 43.65, 46.25, 49.00, 51.91, 55.00, 58.27,...
            61.74, 65.41, 69.30, 73.42, 77.78, 82.41, 87.31, 92.50, 98.00, 103.83,110, 116.54, 123.47, 130.81, 138.59, 146.83, 155.56, 164.81, 174.61, 185.00, 196, 207.65, 220, 233.08,...
            246.94, 261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.00, 415.30, 440, 466.16, 493.88, 523.25, 554.37, 587.33, 622.25, 659.25, 698.46, 739.99, 783.99, ...
            830.61, 880, 932.33, 987.77, 1046.5, 1108.73, 1174.66, 1244.51, 1318.51, 1396.91, 1479.98, 1567.98, 1661.22, 1760, 1864.66, 1975.33, 2093, 2217.46, 2349.32, 2489.02, 2637.02, ...
            2793.83, 2959.96, 3135.96, 3322.44, 3520, 3729.31, 3951.07, 4186.01, 4434.92, 4698.63, 4978.03, 5274.04, 5587.65, 5919.91,6271.93, 6644.88, 7040, 7458, 7902.13];

fprintf('The notes in the audio signal are:-');           
for i = 1:4
    for j = 1:length(f_absval)
        if abs(freq(i)-f_absval(j))<=2
            fprintf('%s ',notes(j))
        end
    end
end
fprintf('\n');

            




