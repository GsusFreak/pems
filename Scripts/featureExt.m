function out = featureExt(files)
% featureExt() This function extracts the features from a set of 
% current and voltage samples
% It uses all of the .csv files in the working directory.

resolution = 10;    % This is the resolution of each sample
Fs = 16000;         % This is the sampling rate of each data set
                    % (which is half of the overall sampling rate)

% files = dir(fullfile(pwd, '*.csv'));
csvData = csvread(files{1});
current = (csvData(:, 2)/1023*3.31 - 1.6524)/(25.2*0.002);
voltage = (csvData(:, 1)/1023*3.31 - 1.6556)*10790/(2.5*25.3)/sqrt(2);

% step = 100;
featuresTmp = zeros(3,ceil(length(csvData(:,1))/100));
for iff = 1:ceil(length(csvData(:,1))/100)
    if iff*100 < length(csvData(:,1))
        [p_real, p_app, pf] = calcPowerUsage2(current((iff-1)*100+99:iff*100), voltage((iff-1)*100+99:iff*100));
    else
        [p_real, p_app, pf] = calcPowerUsage2(current((iff-1)*100+99:length(csvData(:,1))), voltage((iff-1)*100+99):length(csvData(:,1)));
    end
    featuresTmp(:,iff) = [p_real;p_app;pf];
end


% [mm, aspc] = melfcc(current, Fs);
% features = vertcat(mm, aspc);
features = featuresTmp;

for iaa = 2:length(files)
    csvData = csvread(files{iaa});
    current = (csvData(:, 2)/1023*3.31 - 1.6524)/(25.2*0.002);
    voltage = (csvData(:, 1)/1023*3.31 - 1.6556)*10790/(2.5*25.3)/sqrt(2);
    
    featuresTmp = zeros(3,ceil(length(csvData(:,1))/100));
    for iff = 1:ceil(length(csvData(:,1))/100)
        if iff*100 < length(csvData(:,1))
            [p_real, p_app, pf] = calcPowerUsage2(current((iff-1)*100+99:iff*100), voltage((iff-1)*100+99:iff*100));
        else
            [p_real, p_app, pf] = calcPowerUsage2(current((iff-1)*100+99:length(csvData(:,1))), voltage((iff-1)*100+99):length(csvData(:,1)));
        end
        featuresTmp(:,iff) = [p_real;p_app;pf];
    end
    features = horzcat(features, featuresTmp);
end
out = features;
end




