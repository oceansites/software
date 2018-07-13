function [time_hr,flt,flags] = hanning_qc(time,dft,filter_width,flags)
% Uses a Hanning filter to compute hourly values from 10min data.

% Matlab hanning filter is two shorter than python's.
% Divide filter weights by sum of their total, so weights add to 1 (100%).
wts = hann(filter_width+2)/sum(hann(filter_width+2)); wts = wts(2:end-1);


% Pad out the variables by (filter_width-1) / 2, to capture all data.
pad_t = [nan((filter_width-1)/2,1);dft.temp;nan((filter_width-1)/2,1)];
pad_c = [nan((filter_width-1)/2,1);dft.cond;nan((filter_width-1)/2,1)];
pad_p = [nan((filter_width-1)/2,1);dft.pres;nan((filter_width-1)/2,1)];
%pad_s = [nan((filter_width-1)/2,1);dft.sal;nan((filter_width-1)/2,1)];
%pad_d = [nan((filter_width-1)/2,1);dft.dens;nan((filter_width-1)/2,1)];
pad_tflg = [zeros((filter_width-1)/2,1);flags.T;zeros((filter_width-1)/2,1)];
pad_cflg = [zeros((filter_width-1)/2,1);flags.C;zeros((filter_width-1)/2,1)];
pad_pflg = [zeros((filter_width-1)/2,1);flags.P;zeros((filter_width-1)/2,1)];
%pad_sflg = [zeros((filter_width-1)/2,1);flags.S;zeros((filter_width-1)/2,1)];
%pad_dflg = [zeros((filter_width-1)/2,1);flags.D;zeros((filter_width-1)/2,1)];


% Select the first timestamp on the top of the hour.
x = datevec(time(1:6));
idx = find(x(:,5)==0 & x(:,6)==0,1);
time_hr = time(idx:6:length(time));

% Add in a section to use T and P flagged, as if they are C, to prevent
% bias in the output (if T/P are continuous and C is flagged, the filter 
% will "see" further in the T/P time-series than the C, which can cause a spike.)
tempflgascond = pad_t;
presflgascond = pad_p;
tempflgascond(pad_cflg==5 | pad_cflg==0)=NaN;
presflgascond(pad_cflg==5 | pad_cflg==0)=NaN;


% Option 1: Build a new array from the padded array; componentwise multiply by wts.
[tempc,presc,temp,cond,pres,sal,dens] = deal( nan(filter_width,length(idx:6:length(time))) );
[tq,cq,pq,sq,dq] = deal( zeros(filter_width,length(idx:6:length(time))) );
for i=idx:6:length(time)
    temp(:,(i+6-idx)/6) = pad_t(i:i+filter_width-1); 
    cond(:,(i+6-idx)/6) = pad_c(i:i+filter_width-1);
    pres(:,(i+6-idx)/6) = pad_p(i:i+filter_width-1);
    %sal(:,(i+6-idx)/6) = pad_s(i:i+filter_width-1);
    %dens(:,(i+6-idx)/6) = pad_d(i:i+filter_width-1);
    tq(:,(i+6-idx)/6) = pad_tflg(i:i+filter_width-1);
    cq(:,(i+6-idx)/6) = pad_cflg(i:i+filter_width-1);
    pq(:,(i+6-idx)/6) = pad_pflg(i:i+filter_width-1);
    %sq(:,(i+6-idx)/6) = pad_sflg(i:i+filter_width-1);
    %dq(:,(i+6-idx)/6) = pad_dflg(i:i+filter_width-1);
    tempc(:,(i+6-idx)/6) = tempflgascond(i:i+filter_width-1);
    presc(:,(i+6-idx)/6) = presflgascond(i:i+filter_width-1);
end


% Now add up the weighted values, and divide by the percentage of good values. 
T_flt = nansum((temp.*repmat(wts,1,length(temp)))) ./ (1-sum(repmat(wts,1,length(temp)).*isnan(temp)));
C_flt = nansum((cond.*repmat(wts,1,length(cond)))) ./ (1-sum(repmat(wts,1,length(cond)).*isnan(cond)));
P_flt = nansum((pres.*repmat(wts,1,length(pres)))) ./ (1-sum(repmat(wts,1,length(pres)).*isnan(pres)));
Tc_flt = nansum((tempc.*repmat(wts,1,length(tempc)))) ./ (1-sum(repmat(wts,1,length(tempc)).*isnan(tempc)));
Pc_flt = nansum((presc.*repmat(wts,1,length(presc)))) ./ (1-sum(repmat(wts,1,length(presc)).*isnan(presc)));
%S_flt = nansum((sal.*repmat(wts,1,length(sal)))) ./ (1-sum(repmat(wts,1,length(sal)).*isnan(sal)));
%D_flt = nansum((dens.*repmat(wts,1,length(dens)))) ./ (1-sum(repmat(wts,1,length(dens)).*isnan(dens)));


% QC codes; Calls getqc subroutine at the bottom of this script/function.
flags.T_hr = getqc(tq)';
flags.C_hr = getqc(cq)';
flags.P_hr = getqc(pq)';
flags.S_hr = flags.C_hr;
flags.D_hr = flags.C_hr;
%flags.S_hr = getqc(sq)'; % Cut out for speed; same as flags.C_hr
%flags.D_hr = getqc(dq)';


% Go back through and delete where there are too few points (e.g. <50%).
T_flt(flags.T_hr == 5 | flags.T_hr == 0) = NaN;
C_flt(flags.C_hr == 5 | flags.C_hr == 0) = NaN;
P_flt(flags.P_hr == 5 | flags.P_hr == 0) = NaN;
Tc_flt(flags.C_hr == 5 |flags.C_hr == 0) = NaN;
Pc_flt(flags.C_hr == 5 |flags.C_hr == 0) = NaN;
%S_flt(flags.S_hr == 5 | flags.S_hr == 0) = NaN;
%D_flt(flags.D_hr == 5 | flags.D_hr == 0) = NaN;

% Rotate the outcome for export.
flt={};
flt.temp = T_flt';
flt.cond = C_flt';
flt.pres = P_flt';
flt.tempc = Tc_flt';
flt.presc = Pc_flt';
%flt.sal = S_flt';
%flt.dens = D_flt';

end

% Same function as in davg. Counts qc values into an array and 
% assesses what the resulting QC should be at hourly resolution.
function [q_hr] = getqc(q_10)
    qc = zeros(6,length(q_10));
    for n=0:5 % loop over QC codes
        qc(n+1,:) = sum(q_10==n);
    end
    q_hr = nan(1,length(q_10)); % pre-allocate
    for n = 1:size(qc,2)
        if qc(1,n)+qc(6,n) >= 7 % if bads are majority
            if qc(1,n) == qc(6,n) % if bads are equal, set to 5.
                q_hr(n) = 5;
            else 
                [~,j] = max(qc([1,6],n));
                j(j==2)=5; j(j==1)=0; % convert to QC since max doesn't index correctly.
                q_hr(n) = j; % if bads are unequal, choose the majority.
            end
        else % if goods are majority, choose the largest mode of the goods.
            [~,~,c] = mode(q_10(:,n));
            q_hr(n) = max(c{1});
        end
    end
end








% % Option 2: Loop through, filter all data points, but is 100 times slower.
% for i=1:length(time)
%     newt(i) = nansum(pad_t(i:i+filter_width-1).*wts) / (1-sum(wts(isnan(pad_t(i:i+filter_width-1)))));
%     newc(i) = nansum(pad_c(i:i+filter_width-1).*wts) / (1-sum(wts(isnan(pad_c(i:i+filter_width-1)))));
%     newp(i) = nansum(pad_p(i:i+filter_width-1).*wts) / (1-sum(wts(isnan(pad_p(i:i+filter_width-1)))));
%     news(i) = nansum(pad_s(i:i+filter_width-1).*wts) / (1-sum(wts(isnan(pad_s(i:i+filter_width-1)))));
%     newd(i) = nansum(pad_d(i:i+filter_width-1).*wts) / (1-sum(wts(isnan(pad_d(i:i+filter_width-1))))); 
% end
% % Check if the results of the two methods are the same.
% sum(newt(1:6:end) == T_flt)
% sum(newc(1:6:end) == C_flt)
% sum(newp(1:6:end) == P_flt)
% sum(news(1:6:end) == S_flt)
% sum(newd(1:6:end) == D_flt)
% % Option 2 END 

% Attempt 1 to replicate filter.py
% qc = zeros(6,length(sq));
% for n=0:5
%     qc(n+1,:) = sum(sq==n);
% end
% codes = nan(1,length(sq));
% for n = 1:size(qc,2)
%     if qc(1,n)+qc(6,n) >= 7 % if bads are majority
%         if qc(1,n) == qc(6,n) % if bads are equal, set to 5.
%             codes(n) = 5;
%         else 
%             [~,j] = max(qc([1,6],n));
%             j(j==2)=5; j(j==1)=0; % convert to QC since max doesn't index correctly.
%             codes(n) = j; % if bads are unequal, choose the majority.
%         end
%     else % if goods are majority, choose the largest mode of the goods.
%         [~,~,c] = mode(sq(:,n));
%         codes(n) = max(c{1});
%     end
% end

% Attempt 2 to replicate filter.py
%gd_ge_bd = sum(qc(2:5,:)) >= qc(1,:) + qc(6,:);
%max_gd = max(qc(2:5,:));
%max_bd = max([qc(1,:);qc(6,:)]);
%codes = {};
%for n=1:size(qc,2)
%    if gd_ge_bd(n)
%        codes{n} = find(qc(2:5,n) == max_gd(n));
%    else
%       codes{n} = find(qc(1:6,n) == max_bd(n))-1;
%        codes{n}
%    end
%end

% Attempt 0 to replicate filter.py
% Deal with the flags.  Convert all 0's to 5's so that bad values can be
% assessed in one mode command.
%tq(tq==5) = 0;cq(cq==5) = 0;pq(pq==5) = 0;sq(sq==5) = 0;dq(dq==5) = 0;
%flags.T_hr = mode(tq)';
%flags.C_hr = mode(cq)';
%flags.P_hr = mode(pq)';
%flags.S_hr = mode(sq)';
%flags.D_hr = mode(dq)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Let's start w/ a simple example.
%precond = randn(5,1)+45;
%postcond = randn(5,1)+50;
%temp = randn(5,1)+20;
%pres = randn(5,1)+100;
%nominaldepth = 1; % Later, this will need to be read in, and could be a list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

