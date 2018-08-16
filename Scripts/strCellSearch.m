function out = strCellSearch(str, cell)
tf = strcmp(str, cell);
out = sum(tf);
end
