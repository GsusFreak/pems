
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
[inputs, targets] = generateANN_IOs(group);

% [inputs, targets] = segmentSignals(inputs, targets);
% 
trainRatio = .65;
% inputs_train = inputs(1:floor(length(inputs)*trainRatio));
% inputs_val = inputs(floor(length(inputs)*trainRatio)+1:length(inputs));
% 
% tar_train = targets(1:floor(length(targets)*trainRatio));
% tar_val = targets(floor(length(targets)*trainRatio)+1:length(targets));


[trainInd,~,testInd] = dividerand(length(inputs),trainRatio,0.0,1.0-trainRatio);

inputs_train = inputs(trainInd);
inputs_val = inputs(testInd);
tar_train = targets(trainInd);
tar_val = targets(testInd);

numFeatures = 3;
numHiddenUnits = 100;
numClasses = 6;

layers = [ ...
    sequenceInputLayer(numFeatures)
    bilstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

miniBatchSize = 27;

options = trainingOptions('adam', ...
    'ExecutionEnvironment','cpu', ...
    'MaxEpochs',10, ...
    'MiniBatchSize',miniBatchSize, ...
    'ValidationData',{inputs_val,tar_val}, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'Verbose',false, ...
    'Plots','training-progress');

net = trainNetwork(inputs_train,tar_train,layers,options);







% % Save the resulting Neural Networks for future use
% save('nets.mat', 'nets');
% save('runNums.mat', 'runNums');
% 
% % If there isn't labels data saved, create a blank labels cell array
% try
%     load labels.mat
% catch
%     labels = {};
%     for iaa = 1:length(group)
%         labels{iaa} = '';
%     end
%     save('labels.mat', 'labels');
% end



