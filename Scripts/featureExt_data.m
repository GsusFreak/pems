function out = featureExt_data(csvData)
% featureExt() This function extracts the features from a set of 
% current and voltage samples
% It uses all of the .csv files in the working directory.

resolution = 10;    % This is the resolution of each sample
Fs = 16000;         % This is the sampling rate of each data set
                    % (which is half of the overall sampling rate)

% files = dir(fullfile(pwd, '*.csv'));
% csvData = csvread(files{1});
current = 2.0.*csvData(:, 2)./(2.^resolution - 1) - 1;
[mm, aspc] = melfcc(current, Fs);
features = vertcat(mm, aspc);
% for iaa = 2:length(files)
%     csvData = csvread(files{iaa});
%     current = 2.0.*csvData(:, 2)./(2.^resolution - 1) - 1;
%     [mm, aspc] = melfcc(current, Fs);
%     features = horzcat(features, vertcat(mm, aspc));
% end
out = features;
end
