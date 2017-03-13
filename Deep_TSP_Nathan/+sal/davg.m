function [time_dy,davg,flags] = davg(time,time_hr,temp_dft,cond_flt,pres_dft,sal_flt,dens_flt,flags)
% This function takes 10 minute T & P data and calculates daily data.
% This function takes 1 hourly C, S, & D data and calculates daily data.

% Pad to start/end of day.
startdt = datevec(time(1)); start_hr = datevec(time_hr(1));
enddt = datevec(time(end)); end_hr = datevec(time_hr(end));

% Math for 10min to daily padding.
t_elapsed = 6*startdt(4) + startdt(5)/10;   % Start at 0 UTC
t_until = 143 - (6*enddt(4) + enddt(5)/10); % End at 23:50 UTC

% Math for start time at daily resolution.
x = datevec(time(1));
x(:,4) = 12; x(:,5) = 0; x(:,6) = 0; % Padding goes to the beginning of day 1 so just use day 1 at 12z as the daily start.
time_dy = (datenum(x):1:time(end)+t_until/144)'; % Extend by t_until (fraction of day) to capture the end pad.

% Pad out the data for the respective calculations.
pad_t = [nan(t_elapsed,1);temp_dft;nan(t_until,1)];
pad_p = [nan(t_elapsed,1);pres_dft;nan(t_until,1)];

pad_c = [nan(start_hr(4),1);cond_flt;nan(23-end_hr(4),1)];
pad_d = [nan(start_hr(4),1);dens_flt;nan(23-end_hr(4),1)];
pad_s = [nan(start_hr(4),1);sal_flt;nan(23-end_hr(4),1)];

% Pad out the flags for the respective calculations.
pad_tflg = [zeros(t_elapsed,1);flags.T;zeros(t_until,1)];
pad_pflg = [zeros(t_elapsed,1);flags.P;zeros(t_until,1)];

pad_cflg = [zeros(start_hr(4),1);flags.C_hr;zeros(23-end_hr(4),1)];
pad_dflg = [zeros(start_hr(4),1);flags.D_hr;zeros(23-end_hr(4),1)];
pad_sflg = [zeros(start_hr(4),1);flags.S_hr;zeros(23-end_hr(4),1)];

% Since there's no overlap like in hanning_qc, reshape the data.
temp = reshape(pad_t,144,[]);
pres = reshape(pad_p,144,[]);

cond = reshape(pad_c,24,[]);
dens = reshape(pad_d,24,[]);
sal = reshape(pad_s,24,[]);

% Also reshape the QC.
tq = reshape(pad_tflg,144,[]);
pq = reshape(pad_pflg,144,[]);

cq = reshape(pad_cflg,24,[]);
dq = reshape(pad_dflg,24,[]);
sq = reshape(pad_sflg,24,[]);

% Calculation.
temp_davg = nanmean(temp);
pres_davg = nanmean(pres);
cond_davg = nanmean(cond);
dens_davg = nanmean(dens);
sal_davg = nanmean(sal);

% Assign flags. Use hourly flags for CSD and 10min flags for TP.
flags.T_dy = getqc(tq)';
flags.P_dy = getqc(pq)';
flags.C_dy = getqc(cq)';
flags.D_dy = getqc(dq)';
flags.S_dy = getqc(sq)';

% Any data points calculated off <50% data is removed.
temp_davg(flags.T_dy == 5 | flags.T_dy ==0) = NaN;
pres_davg(flags.P_dy == 5 | flags.P_dy ==0) = NaN;
cond_davg(flags.C_dy == 5 | flags.C_dy ==0) = NaN;
dens_davg(flags.D_dy == 5 | flags.D_dy ==0) = NaN;
sal_davg(flags.S_dy == 5 | flags.S_dy ==0) = NaN;

% Assign final daily averages.
davg={};
davg.temp = temp_davg;
davg.cond = cond_davg;
davg.pres = pres_davg;
davg.sal = sal_davg;
davg.dens = dens_davg;


end



% Same function as in hanning_qc.  Counts qc values into an array and 
% assesses what the resulting QC should be at daily resolution.
function [q_dy] = getqc(q_10_or_hr)
    qc = zeros(6,length(q_10_or_hr));
    for n=0:5 % loop over QC codes
        qc(n+1,:) = sum(q_10_or_hr==n);
    end
    q_dy = nan(1,length(q_10_or_hr)); % pre-allocate
    for n = 1:size(qc,2)
        if qc(1,n)+qc(6,n) > size(q_10_or_hr,1)/2 % if bads are supermajority
            if qc(1,n) == qc(6,n) % if bads are equal, set to 5.
                q_dy(n) = 5;
            else 
                [~,j] = max(qc([1,6],n));
                j(j==2)=5; j(j==1)=0; % convert to QC since max doesn't index correctly on a dual slice.
                q_dy(n) = j; % if bads are unequal, choose the majority.
            end
        else % if goods are majority or equal to bads, choose the largest mode of the goods.
            [~,~,c] = mode(q_10_or_hr(:,n));
            q_dy(n) = max(c{1});
        end
    end
end




