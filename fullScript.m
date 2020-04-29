%% Wireless Transmission of EEG Data Through ZigBee Communication
% Morgan Hodges, Joshua Levi, Tristan McCarty, Claire Seiler

%% 1. Import data into Matlab
% Data obtained from http://epileptologie-bonn.de/cms/front_content.php?idcat=193&lang=3

data = importData('data');

% plot mean original data for sets A-E
figure
plot(mean(data(1).eeg(:, :)));
figure
plot(mean(data(2).eeg(:, :)));
figure
plot(mean(data(3).eeg(:, :)));
figure
plot(mean(data(4).eeg(:, :)));
figure
plot(mean(data(5).eeg(:, :)));
%% Perform preliminary filtering steps
% Apply lowpass filter with bandwidth of 40 Hz
fpass = 40;
fs = 173.61;
for i = 1:5
    for j = 1:100
        data(i).eegBF(j, :) = lowpass(data(i).eeg(j,:), fpass, fs);
    end
end

%plot example signal before and after applying lowpass
figure
plot(data(1).eeg(1, :));
hold on
plot(data(1).eegBF(1, :));
%% Perform Independent Component Analysis 
%Remove linearly mixed noise from EEG signal

% ALL CREDIT TO: http://research.ics.aalto.fi/ica/fastica/
% FastICA library by Hugo Gävert, Jarmo Hurri, Jaakko Särelä, and Aapo
% Hyvärinen under GPL license
%% Perform Wavelet Transform on Filtered Data
% Decompose into 5 EEG sub-bands using Discrete Wavelet Transform
% 
% Detail coefficients and approximation coefficient act as representative
% features for the EEG data
%
% Delta wave = 0.5 -4 Hz frequency
% Theta wave = 4 - 8 Hz frequency
% Alpha wave = 8-12 Hz frequency
% Beta wave = 12-35 Hz frequency
% Gamma wave = >35 Hz frequency
for i = 1:5
    for j = 1:100
        [C, L] = wavedec(mean(data(1).eegBF(:,:)), 5, 'db4');
        data(i).coeff(j).c1 = detcoef(C, L, 1);
        data(i).coeff(j).c2= detcoef(C, L, 2);
        data(i).coeff(j).c3 = detcoef(C, L, 3);
        data(i).coeff(j).c4 = detcoef(C, L, 4);
        data(i).coeff(j).c5 = detcoef(C, L, 5);

        data(i).appc(j).a1 = appcoef(C, L, 'db4', 1);
        data(i).appc(j).a2 = appcoef(C, L, 'db4', 2);
        data(i).appc(j).a3 = appcoef(C, L, 'db4', 3);
        data(i).appc(j).a4 = appcoef(C, L, 'db4', 4);
        data(i).appc(j).a5 = appcoef(C, L, 'db4', 5);
    end
end

%Plot all coefficients for one sample EEG time series
subplot(5,2,1);
plot(data(1).coeff(1).c1);
title('Detail Coefficients: Gamma');
subplot(5,2,2);
plot(data(1).appc(1).a1);
title('Approximation Coefficients: Gamma');

subplot(5,2,3);
plot(data(1).coeff(1).c2);
title('Detail Coefficients: Beta')
subplot(5,2,4);
plot(data(1).appc(1).a2);
title('Approximation Coefficients: Beta')

subplot(5,2,5);
plot(data(1).coeff(1).c3);
title('Detail Coefficient: Alpha')
subplot(5,2,6);
plot(data(1).appc(1).a3);
title('Approximation Coefficient: Alpha')

subplot(5,2,7);
plot(data(1).coeff(1).c4);
title('Detail Coefficient: Theta')
subplot(5,2,8);
plot(data(1).appc(1).a4);
title('Approximation Coefficient: Theta')

subplot(5,2,9);
plot(data(1).coeff(1).c5);
title('Detail Coefficient: Delta')
subplot(5,2,10);
plot(data(1).appc(1).a5);
title('Approximation Coefficient: Delta')
%% Simulate Transmission of Data 
% Use calculated bit error rate to corrupt the data 
%% Calculate Root-Mean-Square Error Analysis 
for i = 1:5
    for j = 1:100
        data(i).rmse(j).c1 = rms(data(i).coeff(j).c1, data(i).tcoeff(j).c1);
        data(i).rmse(j).c2 = rms(data(i).coeff(j).c2, data(i).tcoeff(j).c2);
        data(i).rmse(j).c3 = rms(data(i).coeff(j).c3, data(i).tcoeff(j).c3);
        data(i).rmse(j).c4 = rms(data(i).coeff(j).c4, data(i).tcoeff(j).c4);
        data(i).rmse(j).c5 = rms(data(i).coeff(j).c5, data(i).tcoeff(j).c5);
        
        data(i).rmse(j).a1 = rms(data(i).appc(j).a1, data(i).tappc(j).a1);
        data(i).rmse(j).a2 = rms(data(i).appc(j).a2, data(i).tappc(j).a2);
        data(i).rmse(j).a3 = rms(data(i).appc(j).a3, data(i).tappc(j).a3);
        data(i).rmse(j).a4 = rms(data(i).appc(j).a4, data(i).tappc(j).a4);
        data(i).rmse(j).a5 = rms(data(i).appc(j).a5, data(i).tappc(j).a5);
    end
end