%% Wireless Transmission of EEG Data Through ZigBee Communication
% Morgan Hodges, Joshua Levi, Tristan McCarty, Claire Seiler

%% 1. Import data into Matlab
% Data obtained from http://epileptologie-bonn.de/cms/front_content.php?idcat=193&lang=3

data = importData('data');
disp('Finished importing data');
%%
% plot mean original data for sets A-E
figure
plot(mean(data(1).eeg(:, :)));
title('Mean of Set A EEG Time Series');
figure
plot(mean(data(2).eeg(:, :)));
title('Mean of Set B EEG Time Series');
figure
plot(mean(data(3).eeg(:, :)));
title('Mean of Set C EEG Time Series');
figure
plot(mean(data(4).eeg(:, :)));
title('Mean of Set D EEG Time Series');
figure
plot(mean(data(5).eeg(:, :)));
title('Mean of Set E EEG Time Series');
%% Perform preliminary filtering steps
% Apply lowpass filter with bandwidth of 40 Hz
fpass = 40;
fs = 173.61;
for i = 1:5
    for j = 1:100
        data(i).eegBF(j, :) = lowpass(data(i).eeg(j,:), fpass, fs);
    end
end
%%
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

for i = 1:5
    for j = 1:100
        data(i).ica(j, :) = fastica(data(i).eegBF(j, :));
    end
end
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
        [C, L] = wavedec((data(i).eegBF(j,:)), 5, 'db4');
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
%%
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
for i = 1:5
    for j = 1:100
        data(i).corruptEEG(j, :) = Corrupt(data(i).eegBF(j,:));
    end
end
% Regenerate coefficients for transmitted data
for i = 1:5
    for j = 1:100
        [C, L] = wavedec((data(1).corruptEEG(j,:)), 5, 'db4');
        data(i).tcoeff(j).c1 = detcoef(C, L, 1);
        data(i).tcoeff(j).c2= detcoef(C, L, 2);
        data(i).tcoeff(j).c3 = detcoef(C, L, 3);
        data(i).tcoeff(j).c4 = detcoef(C, L, 4);
        data(i).tcoeff(j).c5 = detcoef(C, L, 5);

        data(i).tappc(j).a1 = appcoef(C, L, 'db4', 1);
        data(i).tappc(j).a2 = appcoef(C, L, 'db4', 2);
        data(i).tappc(j).a3 = appcoef(C, L, 'db4', 3);
        data(i).tappc(j).a4 = appcoef(C, L, 'db4', 4);
        data(i).tappc(j).a5 = appcoef(C, L, 'db4', 5);
    end
end
%% Calculate Root-Mean-Square Error Analysis 
for i = 1:5
    for j = 1:100
        data(i).rmse(j).c1 = rmse(data(i).coeff(j).c1, data(i).tcoeff(j).c1);
        data(i).rmse(j).c2 = rmse(data(i).coeff(j).c2, data(i).tcoeff(j).c2);
        data(i).rmse(j).c3 = rmse(data(i).coeff(j).c3, data(i).tcoeff(j).c3);
        data(i).rmse(j).c4 = rmse(data(i).coeff(j).c4, data(i).tcoeff(j).c4);
        data(i).rmse(j).c5 = rmse(data(i).coeff(j).c5, data(i).tcoeff(j).c5);
        
        data(i).rmse(j).a1 = rmse(data(i).appc(j).a1, data(i).tappc(j).a1);
        data(i).rmse(j).a2 = rmse(data(i).appc(j).a2, data(i).tappc(j).a2);
        data(i).rmse(j).a3 = rmse(data(i).appc(j).a3, data(i).tappc(j).a3);
        data(i).rmse(j).a4 = rmse(data(i).appc(j).a4, data(i).tappc(j).a4);
        data(i).rmse(j).a5 = rmse(data(i).appc(j).a5, data(i).tappc(j).a5);
    end
end
%%
set = ['A', 'B', 'C', 'D', 'E'];
for k = 1:length(set)
figure
meanToPlot(1) = mean([data(k).rmse(:).c1])/max([data(k).coeff(:).c1]);
meanToPlot(2) = mean([data(k).rmse(:).c2])/max([data(k).coeff(:).c2]);
meanToPlot(3) = mean([data(k).rmse(:).c3])/max([data(k).coeff(:).c3]);
meanToPlot(4) = mean([data(k).rmse(:).c4])/max([data(k).coeff(:).c4]);
meanToPlot(5) = mean([data(k).rmse(:).c5])/max([data(k).coeff(:).c5]);

meanToPlot(6) = mean([data(k).rmse(:).a1])/max([data(k).appc(:).a1]);
meanToPlot(7) = mean([data(k).rmse(:).a2])/max([data(k).appc(:).a2]);
meanToPlot(8) = mean([data(k).rmse(:).a3])/max([data(k).appc(:).a3]);
meanToPlot(9) = mean([data(k).rmse(:).a4])/max([data(k).appc(:).a4]);
meanToPlot(10) = mean([data(k).rmse(:).a5])/max([data(k).appc(:).a5]);

bar(meanToPlot); 
title(['Normalized Mean RMSE of Set ', set(k), ' features']);
xlabel('Coefficient (Detail Coeff 1-5, Approximation Coeff 1-5)');
ylabel('RMSE score');

% figure
% maxToPlot(1) = max([data(k).coeff(:).c1]);
% maxToPlot(2) = max([data(k).coeff(:).c2]);
% maxToPlot(3) = max([data(k).coeff(:).c3]);
% maxToPlot(4) = max([data(k).coeff(:).c4]);
% maxToPlot(5) = max([data(k).coeff(:).c5]);
% 
% maxToPlot(6) = max([data(k).appc(:).a1]);
% maxToPlot(7) = max([data(k).appc(:).a2]);
% maxToPlot(8) = max([data(k).appc(:).a3]);
% maxToPlot(9) = max([data(k).appc(:).a4]);
% maxToPlot(10) = max([data(k).appc(:).a5]);
% 
% bar(maxToPlot); 
% title(['Max coefficient values of Set ', set(k), ' features']);
% xlabel('Coefficient (Detail Coeff 1-5, Approximation Coeff 1-5)');
% ylabel('Coefficient score');
end