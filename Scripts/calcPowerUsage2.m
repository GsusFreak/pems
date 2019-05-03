function [p_real, p_app, pf] = calcPowerUsage2(volt, curr)
N = length(volt);
p_real = 0;
rms_volt = 0;
rms_curr = 0;
for iaa = 1:N
    p_real = p_real + volt(iaa).*curr(iaa);
    rms_volt = rms_volt + volt(iaa).*volt(iaa);
    rms_curr = rms_curr + curr(iaa).*curr(iaa);
end
p_real = p_real/N;
rms_volt = sqrt(rms_volt./N);
rms_curr = sqrt(rms_curr./N);
p_app = rms_volt.*rms_curr;
pf = p_real./p_app;
end
