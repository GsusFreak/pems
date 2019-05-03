function [inputs_out, targets_out] = generateANN_IOs(group, use_num)
% names = {'Drill_features.csv', ...
%     'Fan_features.csv', ...
%     'Hako_features.csv', ...
%     'Noise_features.csv' ...
%     };
%use = [0, 0, 0, 1];
use = zeros(1, length(group));
use(use_num) = 1;


features = group{1}.features;
sz = size(features);
out = zeros(2, sz(2));
if use(1) == 1
    for ibb = 1:sz(2)
        out(1, ibb) = 1;
    end
elseif use(1) == 0
    for ibb = 1:sz(2)
        out(2, ibb) = 1;
    end
end
outFinal = out;

if length(use) > 1
    for iaa = 2:length(use)
        newData = group{iaa}.features;
        sz = size(newData);
        features = horzcat(features, newData);
        out = zeros(2, sz(2));
        if use(iaa) == 1
            for ibb = 1:sz(2)
                out(1, ibb) = 1;
            end
        elseif use(iaa) == 0
            for ibb = 1:sz(2)
                out(2, ibb) = 1;
            end
        end
        outFinal = horzcat(outFinal, out);
    end
end


[~,score,latent] = pca(features');

keptVars = [];
for iaa = 1:length(latent)
    if latent(iaa) > latent(1)*0.00001
        keptVars(end+1) = iaa;
    end
end

score = score(:,keptVars);
inputs_out = score';


targets_out = outFinal;
% csvwrite('inputs.csv', features);
% csvwrite('targets.csv', outFinal);
end

