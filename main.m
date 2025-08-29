%% Main Script 
clear; clc;
[denoised_signal, Fs] = audioread("denoisedspeech.wav");

% Normalize the Denoised Signal
denoised_signal = denoised_signal / max(abs(denoised_signal));

% Generate Noise Signals
N = length(denoised_signal);

% Generate white noise
white_noise = randn(N,1);
white_noise = white_noise / max(abs(white_noise));

% Generate pink noise
pink_noise_gen = dsp.ColoredNoise('Color','pink','SamplesPerFrame',N,'NumChannels',1);
pink_noise = pink_noise_gen();
pink_noise = pink_noise / max(abs(pink_noise));

% Generate brown noise
brown_noise_gen = dsp.ColoredNoise('Color','brown','SamplesPerFrame',N,'NumChannels',1);
brown_noise = brown_noise_gen();
brown_noise = brown_noise / max(abs(brown_noise));

% Store Noise signals and types in cell arrays
noise_signals = {white_noise, pink_noise, brown_noise};
noise_types = {'White Noise', 'Pink Noise', 'Brown Noise'};

% Choose Noise type
disp('Choose the type of noise to add:');
disp('1. White Noise');
disp('2. Pink Noise');
disp('3. Brown Noise');
choice = input('Enter your choice (1/2/3): ');

% Validate input
if choice < 1 || choice > 3
    error('Invalid choice. Please enter 1, 2, or 3.');
end

% Select the chosen Noise Signal
noise_to_add = noise_signals{choice};
noise_type = noise_types{choice};

% Create the Noisy Signal
% Adjust the noise amplitude relative to the signal amplitude
noise_amplitude = 0.5;
noise_to_add = noise_amplitude * noise_to_add;
noisy_signal = denoised_signal + noise_to_add;

% Use the Noise Added as the Noise Reference
noise_reference = noise_to_add;

% Filter Parameters
filterOrder = 7; % For dsp.RLSFilter and dsp.LMSFilter
M = 7; % Filter order for Custom filters
lambda = 1; % Forgetting factor for RLS filters
delta =0.01; % Small positive constant for RLS filters
deltaInv = 1 / delta; % Initial inverse correlation matrix

% Initialize Filters and Signals
N = length(noisy_signal); % Number of samples
w_rls = zeros(M,1); % Custom RLS filter coefficients
P = deltaInv * eye(M); % Initial inverse correlation matrix
e_rls_custom = zeros(N,1); % Error signal for Custom RLS
w_lms = zeros(M, 1); % Custom LMS filter coefficients
e_lms_custom = zeros(N, 1); % Error signal for Custom LMS
mu = 0.01; % Step size
% Initialize dsp.RLSFilter
rlsFilter = dsp.RLSFilter('Length', filterOrder,'ForgettingFactor', lambda);

% Initialize dsp.LMSFilter
lmsFilter = dsp.LMSFilter('Length', filterOrder, 'StepSize', mu);

% Apply dsp.RLSFilter
tic; % Start timer
[~, e_rls] = rlsFilter(noise_reference, noisy_signal);
time_rls_builtin = toc; % End timer and store elapsed time

% Apply dsp.LMSFilter
tic; % Start timer
[~, e_lms] = lmsFilter(noise_reference, noisy_signal);
time_lms_builtin = toc; % End timer and store elapsed time

tic; % Start timer
% Custom RLS Filter Implementation
for n = M:N
    xvec = noise_reference(n:-1:n-M+1);
    y = w_rls' * xvec; % Current output of the filter
    pi = P * xvec; % Vector used to compute the Kalman gain
    k = pi / (lambda + xvec' * pi); % Kalman gain
    w_rls = w_rls + k * (noisy_signal(n) - y); % Updated based on the prediction error
    P = (P - k * xvec' * P) / lambda; % Matrix update - reduces the influence of older error vectors
    e_rls_custom(n) = noisy_signal(n) - y;
end
time_rls_custom = toc; % End timer and store elapsed time

tic; % Start timer
% Custom LMS Filter Implementation
mu = 0.01; % Step size
for n = M:N
    xvec = noise_reference(n:-1:n-M+1); % Input vector taken from the noisy signal
    y = w_lms' * xvec; % Current output of the filter
    e = noisy_signal(n) - y; % Error between the desired and actual filter output
    w_lms = w_lms + mu * xvec * e; % Updated based on the product of the input vector, the error, and the step size
    e_lms_custom(n) = e;
end
time_lms_custom = toc; % End timer and store elapsed time

%% Playback of Signals
duration = N / Fs; % Duration in seconds

disp('Playing National Instrument denoised signal...');
sound(denoised_signal, Fs);
pause(duration + 1);

disp('Playing noisy signal...');
sound(noisy_signal, Fs);
pause(duration + 1);

disp(['Playing Built-in RLS filtered signal using ', noise_type, '...']);
sound(e_rls, Fs);
pause(duration + 1);

disp(['Playing Built-in LMS filtered signal using ', noise_type, '...']);
sound(e_lms, Fs);
pause(duration + 1);

disp(['Playing Custom RLS filtered signal using ', noise_type, '...']);
sound(e_rls_custom, Fs);
pause(duration + 1);

disp(['Playing Custom LMS filtered signal using ', noise_type, '...']);
sound(e_lms_custom, Fs);
pause(duration + 1);

% Plotting the Results
figure;
subplot(3, 1, 1);
plot(denoised_signal);
title('NI Denoised Signal');
xlabel('Samples');
ylabel('Amplitude');

subplot(3, 1, 2);
plot(noise_reference);
title(['Noise Reference: ', noise_type]);
xlabel('Samples');
ylabel('Amplitude');

subplot(3, 1, 3);
plot(noisy_signal);
title('Noisy Signal');
xlabel('Samples');
ylabel('Amplitude');

figure;
subplot(2, 1, 1);
plot(e_rls_custom);
title(['Custom RLS Filtered Signal with ', noise_type]);
xlabel('Samples');
ylabel('Amplitude');

subplot(2, 1, 2);
plot(e_lms_custom);
title(['Custom LMS Filtered Signal with ', noise_type]);
xlabel('Samples');
ylabel('Amplitude');

%subplot(6, 1, 2);
%plot(e_rls);
%title(['Built-in RLS Filtered Signal with ', noise_type]);
%xlabel('Samples');
%ylabel('Amplitude');

%subplot(6, 1, 3);
%plot(e_lms);
%title(['Built-in LMS Filtered Signal with ', noise_type]);
%xlabel('Samples');
%ylabel('Amplitude');

%% SNR Calculation
function snr_value = compute_SNR(clean, noisy)
    % Ensuring the vectors are column vectors
    clean = clean(:);
    noisy = noisy(:);

    % Power of the clean signal
    signal_power = rms(clean)^2;

    % Power of the noise
    noise_power = rms(noisy - clean)^2;

    % SNR value in decibels
    snr_value = 10 * log10(signal_power / noise_power);
end

% Define the range to exclude initial transient samples if necessary
valid_start = M; % Starting index to exclude initial samples affected by filter delay

% Extract valid portions of signals
s = denoised_signal(valid_start:end); % Clean signal
n = noise_to_add(valid_start:end); % Added noise
noisy = noisy_signal(valid_start:end); % Noisy signal

% Filtered signals
filtered_rls = e_rls(valid_start:end); % Built-in RLS filtered signal
filtered_lms = e_lms(valid_start:end); % Built-in LMS filtered signal
filtered_rls_custom = e_rls_custom(valid_start:end); % Custom RLS filtered signal
filtered_lms_custom = e_lms_custom(valid_start:end); % Custom LMS filtered signal

% Calculate SNR Before Filtering
SNR_before = compute_SNR(s, noisy);

% Calculate SNR After Built-in RLS Filtering
SNR_after_rls = compute_SNR(s, filtered_rls);

% Calculate SNR After Built-in LMS Filtering
SNR_after_lms = compute_SNR(s, filtered_lms);

% Calculate SNR After Custom RLS Filtering
SNR_after_rls_custom = compute_SNR(s, filtered_rls_custom);

% Calculate SNR After Custom LMS Filtering
SNR_after_lms_custom = compute_SNR(s, filtered_lms_custom);

% Calculate SNR Improvements
SNR_improvement_rls = SNR_after_rls - SNR_before;
SNR_improvement_lms = SNR_after_lms - SNR_before;
SNR_improvement_rls_custom = SNR_after_rls_custom - SNR_before;
SNR_improvement_lms_custom = SNR_after_lms_custom - SNR_before;

% Display the Results
fprintf('====Performance Evaluation: "Signal-to-Noise Ratio (SNR) improvements"===\n');
fprintf('SNR Before Filtering: %.2f dB\n', SNR_before);
fprintf('SNR After Built-in RLS Filtering: %.2f dB (Improvement: %.2f dB)\n', SNR_after_rls, SNR_improvement_rls);
fprintf('SNR After Built-in LMS Filtering: %.2f dB (Improvement: %.2f dB)\n', SNR_after_lms, SNR_improvement_lms);
fprintf('SNR After Custom RLS Filtering: %.2f dB (Improvement: %.2f dB)\n', SNR_after_rls_custom, SNR_improvement_rls_custom);
fprintf('SNR After Custom LMS Filtering: %.2f dB (Improvement: %.2f dB)\n', SNR_after_lms_custom, SNR_improvement_lms_custom);
fprintf('================================================\n');

%% Adaptation Speed Calculation

% Choose First Noise Type for the First Half of the Signal
fprintf('====Performance Evaluation: "Adaptation Speed"===\n');
disp('Choose the type of noise to add to the FIRST half of the signal:');
disp('1. White Noise');
disp('2. Pink Noise');
disp('3. Brown Noise');
choice1 = input('Enter your choice for FIRST half (1/2/3): ');
% Validate Input for First Choice
if choice1 < 1 || choice1 > 3
    error('Invalid choice. Please enter 1, 2, or 3.');
end

% Choose Second Noise Type for the Second Half of the Signal
disp('Choose the type of noise to add to the SECOND half of the signal:');
disp('1. White Noise');
disp('2. Pink Noise');
disp('3. Brown Noise');
choice2 = input('Enter your choice for SECOND half (1/2/3): ');
% Validate Input for Second Choice
if choice2 < 1 || choice2 > 3
    error('Invalid choice. Please enter 1, 2, or 3.');
end

% Apply Selected Noises to Their Respective Halves
half_point = floor(N / 2);
noise_amplitude = 0.5;

% Initialize noise_to_add with zeros
noise_to_add = zeros(N,1);

% Apply first noise to the first half
noise_to_add(1:half_point) = noise_amplitude * noise_signals{choice1}(1:half_point);
% Apply second noise to the second half
noise_to_add(half_point+1:end) = noise_amplitude * noise_signals{choice2}(half_point+1:end);

noisy_signal = denoised_signal + noise_to_add; % Create the new noisy signal

% Determine the noise types for display
noise_type_first = noise_types{choice1};
noise_type_second = noise_types{choice2};
noise_reference = noise_to_add; % Update the noise_reference

% Reinitialize Custom Filters for Adaptation

% Reset Custom RLS Filter Coefficients and Inverse Correlation Matrix
w_rls = zeros(M,1);
P = deltaInv * eye(M);
w_lms = zeros(M, 1);

% Initialize error signals for adaptation speed analysis
e_rls_custom = zeros(N,1);
e_lms_custom = zeros(N,1);

% Initialize squared error tracking vectors
squared_error_rls_custom = zeros(N,1);
squared_error_lms_custom = zeros(N,1);

% Custom RLS and LMS Filter Implementation with Error Tracking
for n = M:N
    % Custom RLS Filtering (Changed Variables for Adaptation speed)
    xvec_rls = noise_reference(n:-1:n-M+1);
    y_rls = w_rls' * xvec_rls;
    pi = P * xvec_rls;
    k = pi / (lambda + xvec_rls' * pi);
    w_rls = w_rls + k * (noisy_signal(n) - y_rls);
    P = (P - k * xvec_rls' * P) / lambda;
    e_rls_custom(n) = noisy_signal(n) - y_rls;
    % Store squared error for adaptation speed
    squared_error_rls_custom(n) = e_rls_custom(n)^2;
    
    % Custom LMS Filtering (Changed Variables for Adaptation speed)
    xvec_lms = noise_reference(n:-1:n-M+1);
    y_lms = w_lms' * xvec_lms;
    e_lms_custom(n) = noisy_signal(n) - y_lms;
    w_lms = w_lms + mu * xvec_lms * e_lms_custom(n);
    % Store squared error for adaptation speed
    squared_error_lms_custom(n) = e_lms_custom(n)^2;
end

% Plotting Adaptation Speed: Squared Error Over Time
figure;
plot(squared_error_rls_custom, 'r', 'LineWidth', 1.5);
hold on;
plot(squared_error_lms_custom, 'b', 'LineWidth', 1.5);
% Mark the halfway point where noise changes
xline(half_point, '--k', 'LineWidth', 2, 'Label', 'Noise Change Point');
hold off;
title('Adaptation Speed: Squared Error of Custom Filters');
xlabel('Sample Number');
ylabel('Squared Error');
legend('Custom RLS', 'Custom LMS', 'Noise Change Point');
grid on;

% Maximum error right after the noise change within a small window
window_size = 100;  % Can be adjusted based on needs
max_error_rls = max(squared_error_rls_custom(half_point:half_point + window_size));
max_error_lms = max(squared_error_lms_custom(half_point:half_point + window_size));

% Stabilization threshold defined as 5% of the maximum error
stabilization_threshold_rls = 0.05 * max_error_rls;
stabilization_threshold_lms = 0.05 * max_error_lms;

% Find the Index of Stabilization, finding the point where error goes below the threshold and stays below
idx_stabilize_rls = find(squared_error_rls_custom(half_point:end) < stabilization_threshold_rls, 1, 'first') + half_point - 1;
idx_stabilize_lms = find(squared_error_lms_custom(half_point:end) < stabilization_threshold_lms, 1, 'first') + half_point - 1;

if isempty(idx_stabilize_rls)
    disp('RLS filter did not stabilize within the measured range.');
else
    % Calculate time to stabilize in seconds
    time_to_stabilize_rls = (idx_stabilize_rls - half_point) / Fs;
    fprintf('Time to stabilize for Custom RLS: %.4f seconds\n', time_to_stabilize_rls);
end

if isempty(idx_stabilize_lms)
    disp('LMS filter did not stabilize within the measured range.');
else
    % Calculate time to stabilize in seconds
    time_to_stabilize_lms = (idx_stabilize_lms - half_point) / Fs;
    fprintf('Time to stabilize for Custom LMS: %.4f seconds\n', time_to_stabilize_lms);
end

%% Analysis of Error Occurrences
% Calculate the number of times RLS error is greater than LMS error
rls_greater_than_lms_count = sum(squared_error_rls_custom > squared_error_lms_custom);

% Calculate the number of times LMS error is greater than RLS error
lms_greater_than_rls_count = sum(squared_error_lms_custom > squared_error_rls_custom);

% Display the results
fprintf('\nNumber of times RLS squared error is greater than LMS squared error: %d\n', rls_greater_than_lms_count);
fprintf('Number of times LMS squared error is greater than RLS squared error: %d\n', lms_greater_than_rls_count);

% Plotting the results for visualization
figure;
bar([rls_greater_than_lms_count, lms_greater_than_rls_count]);
set(gca, 'XTickLabel', {'RLS > LMS', 'LMS > RLS'});
ylabel('Count');
title('Comparison of Error Occurrences');
% Calculate the average squared error post noise change
avg_error_rls_post_change = mean(squared_error_rls_custom(half_point:end));
avg_error_lms_post_change = mean(squared_error_lms_custom(half_point:end));

% Display the results
fprintf('Average Squared Error Post-Change for Custom RLS: %.5f\n', avg_error_rls_post_change);
fprintf('Average Squared Error Post-Change for Custom LMS: %.5f\n', avg_error_lms_post_change);

fprintf('================================================\n');

%% Display Execution Times
fprintf('====Performance Evaluation: "Computational Efficiency"===\n');
fprintf('Built-in RLS: %.5f seconds\n', time_rls_builtin);
fprintf('Built-in LMS: %.5f seconds\n', time_lms_builtin);
fprintf('Custom RLS: %.5f seconds\n', time_rls_custom);
fprintf('Custom LMS: %.5f seconds\n', time_lms_custom);
fprintf('====================================================\n');