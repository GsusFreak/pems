function featureExt_CSV()
% featureExt() This function extracts the features from a set of 
% current and voltage samples
resolution = 10;
Fs = 16000;

files = dir(fullfile(pwd, '*.csv'));
csvData = csvread(files(1).name);
current = 2.0.*csvData(:, 2)./(2.^resolution - 1) - 1;
[mm, aspc] = melfcc(current, Fs);
features = vertcat(mm, aspc);
for iaa = 2:length(files)
    csvData = csvread(files(iaa).name);
    current = 2.0.*csvData(:, 2)./(2.^resolution - 1) - 1;
    [mm, aspc] = melfcc(current, Fs);
    features = horzcat(features, vertcat(mm, aspc));
end
csvwrite('out.csv', features);
end
