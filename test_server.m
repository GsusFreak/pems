clear all; close all; clc;
pause on;

SAMPLING_RATE = 16000;
charsPerSecond = SAMPLING_RATE*10; % There are 10 characters for each set
                                   % of two samples (voltage, current). 

t = tcpip('0.0.0.0', 30000, 'NetworkRole', 'server', ...
    'InputBufferSize', 1048576);
fopen(t);

load('numRun.mat');
numRun = numRun + 1;
save('numRun.mat', 'numRun');
numSamp = 1;

numUnderflows = 0;
numFullFiles = 0;

while (1)
    if t.BytesAvailable >= charsPerSecond
        out = char(fread(t, charsPerSecond)');
        t.BytesAvailable
        nameFile = sprintf("readings\\power_%03d_%05d.csv", numRun, numSamp);
        numSamp = numSamp + 1;
        fileSamples = fopen(nameFile, 'w');
        fwrite(fileSamples, out);
        fclose(fileSamples);
        pause(0.75);
        
        numUnderflows = 0;
        numFullFiles = numFullFiles + 1;
    else
        numUnderflows = numUnderflows + 1;
    end
    if numUnderflows >= 5 && numFullFiles > 0 && t.BytesAvailable > 0
        out = char(fread(t, t.BytesAvailable)');
        numUnderflows = 0;
        t.BytesAvailable
        nameFile = sprintf("readings\\power_%03d_%05d.csv", numRun, numSamp);
        numSamp = numSamp + 1;
        fileSamples = fopen(nameFile, 'w');
        fwrite(fileSamples, out);
        fclose(fileSamples);
        pause(0.75);
    end
end