function [time,pre,post] = correcttime(inputs,pre,post)
% First, check that pre and postcal times match.
if isequal(pre.time,post.time)
    time = pre.time;  % Optionally maintain time with pre/post next 2 lines.
    pre = rmfield(pre,'time');
    post = rmfield(post,'time');
else
    disp('Attempting to reconcile times');
    [time,idx] = intersect(pre.time,post.time);
    warning('Pre and Post Calibration Times do not match! Attempting to correct all variables to match!');
    pre.temp = pre.temp(idx);
    pre.pres = pre.pres(idx);
    pre.cond = pre.cond(idx);
    pre.sal = pre.sal(idx);
    post.temp = post.temp(idx);
    post.pres = post.pres(idx);
    post.cond = post.cond(idx);
    post.sal = post.sal(idx);
end

% Now, decide how to handle time:
% --- If timestamps are 10 min apart (on a grid):
%       1) If e.g. 0:00, 0:10, it's good!
%       2) If e.g. 0:01, 0:11, adjust the residuals
% --- If timestamps are irregular (not gridded), shift into nearest timestamps.

a = datevec(time); b = datevec(diff(time));
if sum(sum(diff(b)))==0
    disp('Timestamp spacing is even.')
    % Ensure evenly-spaced timestamps are on the 10 min marks.  If not, adjust by up to 5 minutes.
    remainders = mod(a(:,5)*60 + a(:,6),600);
    if remainders >= 300  
        a(:,6) = a(:,6) + (600 - remainders);
        disp(sprintf('Adjustment by %d second(s) to next 10min timestamp.',600-remainders(1)));
        time = datenum(a);
        pre.time = datenum(a);
        post.time = datenum(a); % Set all times to corrected times.
    elseif remainders < 300
        a(:,6) = a(:,6) - remainders;
        disp(sprintf('Adjustment by %d second(s) to previous 10min timestamp.',remainders(1)));
        time = datenum(a);
        pre.time = datenum(a);
        post.time = datenum(a); % Set all times to corrected times.
    end
else
    % Round each timestamp to the nearest 10min.  Could work for evenly-spaced timestamps, as well.
    disp('Rounding times to nearest 10min marks.')
    time = round(time*24*6)/ (24*6);
    % If times don't round to unique and consecutive 10min marks, there's a larger problem in the data.
    if length(unique(time)) ~= length(time)
        error('Two times rounded to the same value! Check the data.');
    end
end

% Place data into nearest timestamps if total clock error exceeds 5 minutes.
x = etime(datevec('00:00:00'),datevec(inputs.clockerror));
if abs(x)>=5*60 % Detect if drift exceeds 5 minutes.
    disp('CAUTION! Using pilot-project logic to fix clock error in correcttime.m') 
    % Correct timestamps. Suppose 15s slow (-15), we need to add 0sec to start and 15sec to end.
    if inputs.clockerror(1)=='-'
        difference = etime(datevec('00:00:00'),datevec(inputs.clockerror)); % in seconds
    else
        difference = etime(datevec(inputs.clockerror),datevec('00:00:00')); % in seconds
    end
    adjustment = linspace(0,-difference,length(time)); % in seconds
    newtime = time + (adjustment'/3600/24); % apply adjustment in days
    view_newtime = datevec(newtime); % "Exact" measurement times if drift is linear.
    x = round(newtime*24*6)/(24*6);
    view_x=datevec(x); % Nearest 10min mark to interpolated times.
    yy = diff(view_x); % 20min differences will become apparent.

    if difference<0
        idx_stuffnan = find(yy(:,5)==20); % Locate where to put nans.
        for i=1:length(idx_stuffnan)
            pre.temp = [pre.temp(1:idx_stuffnan(i)+i-1);NaN;pre.temp(idx_stuffnan(i)+i:end)];
            pre.cond = [pre.cond(1:idx_stuffnan(i)+i-1);NaN;pre.cond(idx_stuffnan(i)+i:end)];
            pre.pres = [pre.pres(1:idx_stuffnan(i)+i-1);NaN;pre.pres(idx_stuffnan(i)+i:end)];
            pre.sal = [pre.temp(1:idx_stuffnan(i)+i-1);NaN;pre.sal(idx_stuffnan(i)+i:end)];
            post.temp = [post.temp(1:idx_stuffnan(i)+i-1);NaN;post.temp(idx_stuffnan(i)+i:end)];
            post.cond = [post.cond(1:idx_stuffnan(i)+i-1);NaN;post.cond(idx_stuffnan(i)+i:end)];
            post.pres = [post.pres(1:idx_stuffnan(i)+i-1);NaN;post.pres(idx_stuffnan(i)+i:end)];
            post.sal = [post.sal(1:idx_stuffnan(i)+i-1);NaN;post.sal(idx_stuffnan(i)+i:end)];
        end
        time = [time;(time(end)+linspace(1/144,length(idx_stuffnan)/144,length(idx_stuffnan)))'];
    else % When the instrument clock is fast....which is unlikely.
        idx_rarify = find(yy(:,5)==0); % Locate where to average 2 timesteps.
        for i=1:length(idx_rarify)
            pre.temp = [pre.temp(1:idx_rarify(i)-(i-1)-1);nanmean(pre.temp(idx_rarify(i)-(i-1):idx_rarify(i)-(i-1)+1));pre.temp(idx_rarify(i)-(i-1)+2:end)];
            pre.cond = [pre.cond(1:idx_rarify(i)-(i-1)-1);nanmean(pre.cond(idx_rarify(i)-(i-1):idx_rarify(i)-(i-1)+1));pre.cond(idx_rarify(i)-(i-1)+2:end)];
            pre.pres = [pre.pres(1:idx_rarify(i)-(i-1)-1);nanmean(pre.pres(idx_rarify(i)-(i-1):idx_rarify(i)-(i-1)+1));pre.pres(idx_rarify(i)-(i-1)+2:end)];
            pre.sal = [pre.sal(1:idx_rarify(i)-(i-1)-1);nanmean(pre.sal(idx_rarify(i)-(i-1):idx_rarify(i)-(i-1)+1));pre.sal(idx_rarify(i)-(i-1)+2:end)];
            post.temp = [post.temp(1:idx_rarify(i)-(i-1)-1);nanmean(post.temp(idx_rarify(i)-(i-1):idx_rarify(i)-(i-1)+1));post.temp(idx_rarify(i)-(i-1)+2:end)];
            post.cond = [post.cond(1:idx_rarify(i)-(i-1)-1);nanmean(post.cond(idx_rarify(i)-(i-1):idx_rarify(i)-(i-1)+1));post.cond(idx_rarify(i)-(i-1)+2:end)];
            post.pres = [post.pres(1:idx_rarify(i)-(i-1)-1);nanmean(post.pres(idx_rarify(i)-(i-1):idx_rarify(i)-(i-1)+1));post.pres(idx_rarify(i)-(i-1)+2:end)];
            post.sal = [post.sal(1:idx_rarify(i)-(i-1)-1);nanmean(post.sal(idx_rarify(i)-(i-1):idx_rarify(i)-(i-1)+1));post.sal(idx_rarify(i)-(i-1)+2:end)];
        end
        time = unique(view_x,'rows');
end
    

% Ensure data lengths match.
if size(pre.cond)~=size(post.cond)
    error(sprintf('Postcal length %d and precal length %d must match!',length(cond_post),length(cond_pre)));
end
end

%%%%%%%%% OLD CODE %%%%%%%%%%%%%  
%     warning('Uneven timestamp spacing! Differences up to %s seconds. Attempting to correct!',10);
%   Create a new grid, starting 2hrs after anchor drop.
%     st = datevec(inputs.startdt); nd = datevec(inputs.enddt);
%   Starts 2 hrs later, cuts 11 10min timesteps off end to fit deployment.
%     newgrid = datenum(st(1),st(2),st(3),st(4)+2,ceil(st(5)/10)*10:10:(10*((etime(nd,st)/600)-11)),0);
%     pre.cond = interp1(time,pre.cond,newgrid);
%     pre.sal = interp1(time,pre.sal,newgrid);
%     pre.temp = interp1(time,pre.temp,newgrid);
%     pre.pres = interp1(time,pre.pres,newgrid);
%     post.cond = interp1(time,post.cond,newgrid);
%     post.sal = interp1(time,post.sal,newgrid);
%     post.temp = interp1(time,post.temp,newgrid);
%     post.pres = interp1(time,post.pres,newgrid);
%     time = newgrid;
%     pre.time = newgrid;
%     post.time = newgrid;
%     Use newgrid as time from now on, as well as interpolated variables.
%%%%%%%%% OLD CODE %%%%%%%%%%%%% 