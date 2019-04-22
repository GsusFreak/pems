
show_confusion_matrices = true;


files = dir(fullfile(strcat(pwd, '\classifier_data'), '*.csv'));
file_names = {};        % file_names is a cell list of all the classifier
                        % file file names.

% Transfer all of the files names from the files struct to the file_names
% cell array.
for iaa = 1:length(files)
    file_names{end + 1} = files(iaa).name;
end

device_nums = {};      % a list of all distinct device (run) numbers
for iaa = 1:length(file_names)
    num = strsplit(file_names{iaa}, '_');
    if ~strCellSearch(num{2}, device_nums)
        device_nums{end + 1} = num{2};
    end
end

% Initialize the file name storing data structure
group = {};
for iaa = 1:length(device_nums)
    group{iaa} = struct;
    group{iaa}.num = device_nums{iaa};
    group{iaa}.files = {};
end

% Sort the files into groups based on their device number
for iaa = 1:length(file_names)
    num = strsplit(file_names{iaa}, '_');
    
    for ibb = 1:length(group)
        if sum(strcmp(num{2}, group{ibb}.num))
            group{ibb}.files{end + 1} = file_names{iaa};
        end
    end
end

% Aggregate each group of files into one large file
for iaa = 1:length(group)
    group{iaa}.features = featureExt(group{iaa}.files);
end

nets = {};
runNums = {};
for iaa = 1:length(group)
    [inputs, targets] = generateANN_IOs(group, iaa);
%     csvwrite(sprintf('%d_inputs.csv', iaa), inputs);
%     csvwrite(sprintf('%d_targets.csv', iaa), targets);
%     group{iaa}.inputs = inputs;
%     group{iaa}.targets = targets;
    group{iaa}.net = Train_only_ANN(inputs, targets, iaa, show_confusion_matrices);
    nets{iaa} = group{iaa}.net;
    runNums{iaa} = group{iaa}.num;
end

% Save the resulting Neural Networks for future use
save('nets.mat', 'nets');
save('runNums.mat', 'runNums');

% If there isn't labels data saved, create a blank labels cell array
try
    load labels.mat
catch
    labels = {};
    for iaa = 1:length(group)
        labels{iaa} = '';
    end
    save('labels.mat', 'labels');
end



