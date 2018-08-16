function out = vertcatall_wOut(files)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

data = csvread(files{1});

for iaa = 2:length(files)
    data = vertcat(data, csvread(files{iaa}));
end

out = data;
end

