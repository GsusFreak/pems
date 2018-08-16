function horzcatall()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

files = dir(fullfile(pwd, '*.csv'));
data = csvread(files(1).name);

for iaa = 2:length(files)
    data = horzcat(data, csvread(files(iaa).name));
end

csvwrite('out.csv', data);
end

