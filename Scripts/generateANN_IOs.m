function [inputs_out, targets_out] = generateANN_IOs(group)
% names = {'Drill_features.csv', ...
%     'Fan_features.csv', ...
%     'Hako_features.csv', ...
%     'Noise_features.csv' ...
%     };
%use = [0, 0, 0, 1];

deviceIDs = cell(1,length(group));
for iaa = 1:length(group)
    deviceIDs{iaa} = group{iaa}.num;
end

features = group{1}.features;
sz = size(features);
out = zeros(length(deviceIDs), sz(2));
for ibb = 1:sz(2)
    out(:, ibb) = double(strcmp(group{1}.num, deviceIDs));
end
outFinal = out;

for iaa = 2:length(group)
    newData = group{iaa}.features;
    sz = size(newData);
    features = horzcat(features, newData);
    out = zeros(length(deviceIDs), sz(2));
    for ibb = 1:sz(2)
        out(:, ibb) = double(strcmp(group{iaa}.num, deviceIDs));
    end
    outFinal = horzcat(outFinal, out);
end

pointsPerSample = 160;

[~,inputsSize] = size(features);
inputs_out = cell(ceil(inputsSize/pointsPerSample),1);
targets_tmp = cell(ceil(inputsSize/pointsPerSample),1);
for icc = 1:pointsPerSample:inputsSize
    if icc+pointsPerSample-1 <= inputsSize
        inputs_out{ceil(icc/pointsPerSample)} = features(:,icc:icc+pointsPerSample-1);
    else
        inputs_out{ceil(icc/pointsPerSample)} = features(:,icc:inputsSize);
    end
    [~,yep] = max(outFinal(:,icc));
    targets_tmp{ceil(icc/pointsPerSample)} = num2str(yep);
end
% targets_out = targets_tmp;
targets_out = categorical(targets_tmp);

% inputs_out = features;
% targets_out = outFinal;
% csvwrite('inputs.csv', features);
% csvwrite('targets.csv', outFinal);
end

