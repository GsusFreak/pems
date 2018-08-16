function dupRows(filename)
% This function copies each row a certain number of times

multiplier = 5;     % multiplier is how many times each row is multiplied

data = csvread(filename);
data_size = size(data);
new_data = zeros(data_size(1)*multiplier, data_size(2));
for iaa = 1:data_size(1)
    for ibb = 1:multiplier
        new_data((multiplier*(iaa - 1) + ibb), :) = data(iaa, :);
    end
end
filename_parts = strsplit(filename, '.');
C = {strcat(filename_parts{1}, '_new'), filename_parts{2}};
new_filename = strjoin(C, '.');
csvwrite(new_filename, new_data);
end