% Creating a chirp signal ESP Lab1 - 3.1 (ESPL/03)
clear; close all;

% Time axis
fs = 50e3;                      % sampling frequency [Hz]
ts = 1/fs;                      % sampling period [s]
totalSamples = 100e3;           % 2 s * 50 kHz = 100000 samples

% vector
t = 0:ts:(totalSamples-1)*ts;   % time axis: 0 ... just below 2 s

% chirp parameters
f0 = 21e3;                      % start frequency [Hz]
f_final = 24e3;                 % end frequency [Hz]
tEnd = 2.0;                     % time when f_final is reached [s]
x = chirp(t, f0, tEnd, f_final);

% ---------------- Plots ----------------
figure;

% (1) Spectrogram X[l,k]
subplot(2,1,1);
spectrogram(x, hann(1024), 512, 1024, fs, 'yaxis');
title('Spectrogram X[l,k] of chirp 21 \rightarrow 24 kHz');

% (2) Time-domain section x[n] as stem plot
subplot(2,1,2);
n1 = 100;                      % first sample to show
n2 = 200;                      % last sample to show
n  = n1:n2;                     % sample indices
stem(n, x(n+1), 'filled');      % x(n+1): Matlab starts counting at 1
xlabel('n');
ylabel('x[n]');
title(sprintf('Chirp x[n], samples n = %d ... %d', n1, n2));
grid on;

%% Task 3.2
figure;
M = 5;
m = 0:99;                  % first 100 samples of the new signal

% for lambda = 0
x0 = x(1:M:end);           % pile lambda = 0: x[0], x[5], x[10], ...
subplot(M,1,1);
stem(m, x0(1:100), 'filled');
xlabel('m');
ylabel('x_0[m]');
title('Polyphase \lambda = 0 (first 100 samples)');
grid on;

% for lambda = 1
x1 = x(2:M:end);           % pile lambda = 1: x[1], x[6], x[11], ...
subplot(M,1,2);
stem(m, x1(1:100), 'filled');
xlabel('m');
ylabel('x_1[m]');
title('Polyphase \lambda = 1 (first 100 samples)');
grid on;

% for lambda = 2
x2 = x(3:M:end);           % pile lambda = 2: x[2], x[7], x[12], ...
subplot(M,1,3);
stem(m, x2(1:100), 'filled');
xlabel('m');
ylabel('x_2[m]');
title('Polyphase \lambda = 2 (first 100 samples)');
grid on;

% for lambda = 3
x3 = x(4:M:end);           % pile lambda = 3: x[3], x[8], x[13], ...
subplot(M,1,4);
stem(m, x3(1:100), 'filled');
xlabel('m');
ylabel('x_3[m]');
title('Polyphase \lambda = 3 (first 100 samples)');
grid on;

% for lambda = 4
x4 = x(5:M:end);           % pile lambda = 4: x[4], x[9], x[14], ...
subplot(M,1,5);
stem(m, x4(1:100), 'filled');
xlabel('m');
ylabel('x_4[m]');
title('Polyphase \lambda = 4 (first 100 samples)');
grid on;

%% Task 3.3
L = 5;
y = zeros(1, L*length(x0));   % empty vector
y(1:L:end) = x0;              % fill every L-th box with x0

figure;                       % new window FIRST, then both subplots

% (1) Spectrogram Y'[l,k]
subplot(2,1,1);
spectrogram(y, hann(1024), 512, 1024, fs, 'yaxis');   % fs = 50 kHz (fast side)
title('Spectrogram Y''[l,k] after upsampling by L = 5 (no filter)');

% (2) Time-domain section y'[n]
subplot(2,1,2);                  
stem(n, y(n+1), 'filled');
xlabel('n'); ylabel('y''[n]'); grid on;
title(sprintf('y''[n], samples n = %d ... %d', n1, n2));


%% Task 3.4

%% Task 3.4 Interpolation filter

d_pass = 0.001;          % pass-band ripple
d_stop = 0.001;          % stop-band (-60 dB)
fpass  = 4e3;            % <-- your calculation [Hz]
fstop  = 5e3;            % <-- your calculation [Hz], fstop - fpass = 1 kHz

% --- design (same idea as the tutorial) ---
[N_FIR, fo, mo, w] = firpmord([fpass fstop], [1 0], [d_pass d_stop], fs);
b = firpm(N_FIR, fo, mo, w);
fprintf('Filter order N_FIR = %d, number of coefficients = %d\n', N_FIR, length(b));


% --- check the filter response ---
figure;
[H, f] = freqz(b, 1, 4096, fs);
plot(f/1e3, db(H)); grid on;
xlabel('Frequency (kHz)'); ylabel('|H| (dB)');
title('Interpolation filter response');

% --- apply it to the upsampler output ---
yF = L * filter(b, 1, y);      

% --- plots: spectrogram + stem section ---
figure;

% (1) Spectrogram Y[l,k] of the filtered signal
subplot(2,1,1);
spectrogram(yF, hann(1024), 512, 1024, fs, 'yaxis');   % fs = 50 kHz (fast side)
title('Spectrogram Y[l,k] after upsampling by L = 5 and interpolation filter');

% (2) Time-domain section y[n] of the filtered signal
subplot(2,1,2);
stem(n, yF(n+1), 'filled');
xlabel('n'); ylabel('y[n]'); grid on;
title(sprintf('Filtered y[n], samples n = %d ... %d', n1, n2));


%Task 3.5

filename = 'AIF_coeffs.h';
file_ID  = fopen(filename, 'w');
fprintf(file_ID, '#define N_AIF %d\n', length(b));
fprintf(file_ID, 'short AIF_delays[N_AIF];\n');
write_coeff(file_ID, 'h_AIF', b, length(b));
fclose(file_ID);













