function [ flags ] = initialQC(time,drift)
threshold = 0.04;
for i=1:length(drift)
    if drift(i) == 0
        qc = 2;
    elseif drift(i) == -99.99
        qc = 5;
    elseif abs(drift(i)) > threshold
        qc = 3;
    else
        qc = 1;
    end
    sprintf('Suggested QC code is %d',qc);
end
flags = {};
flags.T = repmat(2,length(time),1);
flags.C = repmat(qc,length(time),1);
flags.P = repmat(2,length(time),1);
flags.S = repmat(qc,length(time),1);
flags.D = repmat(qc,length(time),1);
end

