%% Wireless Transmission of EEG Data Through ZigBee Communication
% Morgan Hodges, Joshua Levi, Tristan McCarty, Claire Seiler

%% 1. Import data into Matlab
data = importData('data');

% plot mean original data for sets A-E
plot(mean(data(1).eeg(:, :)));
plot(mean(data(2).eeg(:, :)));
plot(mean(data(3).eeg(:, :)));
plot(mean(data(4).eeg(:, :)));
plot(mean(data(5).eeg(:, :)));
%% Perform preliminary filtering steps
% Apply lowpass filter with bandwidth of 40 Hz
%fpass = [.5 40];
fpass = 40;
fs = 173.61;
for i = 1:5
    for j = 1:100
        data(i).eegBF(j, :) = lowpass(data(i).eeg(j,:), fpass, fs);
    end
end

%plot example signal before and after applying lowpass
plot(data(1).eeg(1, :));
hold on
plot(data(1).eegBF(1, :));
%% Perform Independent Component Analysis 

%% Perform Wavelet Transform on Filtered Data

%% Simulate Transmission of Data 
% Use calculated bit error rate to corrupt the data 
%% Calculate Root-Mean-Square Error Analysis 