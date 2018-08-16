function out = runANNs( sample )
out = [];
temp = ANN_Drill(sample);
out(end + 1) = temp(1);
ANN_Fan(sample);
temp = ANN_Fan(sample);
out(end + 1) = temp(1);
ANN_Hako(sample);
temp = ANN_Hako(sample);
out(end + 1) = temp(1);
ANN_Noise(sample);
temp = ANN_Noise(sample);
out(end + 1) = temp(1);
end

