function out = Run_Classifiers(data, nets)

maxSamplesTested = 5;

features = featureExt_data(data);
sz = size(features);
len = length(nets);
out = zeros(1, len);
if sz(2) <= maxSamplesTested
    top_index = sz(2);
else
    top_index = maxSamplesTested;
end
for iaa = 1:top_index
    for ibb = 1:len
        net = nets{ibb};
        result = net(features(:, iaa));
        if result(1) > result(2)
            out(ibb) = out(ibb) + 1;
        end
    end
end

max = 0;
max_index = 0;
for iaa = 1:length(out)
    if out(iaa) > max
        max = out(iaa);
        max_index = iaa;
    end
end
out = max_index;
end