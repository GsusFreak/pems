function Train_One_Classifier(runNum, label)

show_confusion_matrices = true;


runNum = sprintf('%d', runNum);
files_2 = dir(fullfile(strcat(pwd, '\classifier_data'), '*.csv'));
file_names = {};        % file_names is a cell list of all the classifier
                        % file filenames.

% Transfer all of the files names from the files struct to the file_names
% cell array.
for iaa = 1:length(files_2)
    file_names{end + 1} = files_2(iaa).name;
end

% Initialize the file name storing data structure
num = runNum;
files = {};

% Sort the files into groups based on their device number
for iaa = 1:length(file_names)
    numTmp = strsplit(file_names{iaa}, '_');
    if sum(strcmp(numTmp{2}, num))
        files{end + 1} = file_names{iaa};
    end
end
% Aggregate each group of files into one large file
features = featureExt(files);

load('nets.mat');
load('runNums.mat');
load('labels.mat');
group = {};
group{1} = struct();
group{1}.features = features;
[inputs, targets] = generateANN_IOs(group, 1);
net = Train_only_ANN(inputs, targets, num, show_confusion_matrices);

nets{end + 1} = net;
runNums{end + 1} = num;
labels{end + 1} = label;

% Save the resulting Neural Networks for future use
save('nets.mat', 'nets');
save('runNums.mat', 'runNums');
save('labels.mat', 'labels');


