clear all; close all; dbstop if error;format long g;

% Get configuration inputs.  Rsyncs files if connected to PMEL server.
inputs = config();

% Load .dat files, converts S/m to mS/cm for processing.
pre = sal.loaddat('pre.dat');
post = sal.loaddat('post.dat');
%prenext = []; postnext = [];
%if isfield(inputs,'nextdir')
%    prenext = sal.loaddat('prenext.dat');
%    postnext = sal.loaddat('postnext.dat');
%end

% Calculate nominal depth(s) for metadata purposes.
inputs.nominal_depths = sal.pressure2depth(nanmedian(pre.pres),str2double(inputs.nominal_gps(1:2)));

% Check that times are equal and gridded, and that variable sizes match.
[time,pre,post] = sal.correcttime(inputs,pre,post); 

% Do pre to post conductivity interpolation, or in the case of Deep TSP, average (+temp, if applicable).
% Use sal.interpolate_pre_post(pre.var,post.var) if interpolating.
dft={};
dft.cond = (pre.cond+post.cond)/2;
dft.temp = (pre.temp+post.temp)/2;

% Add post-pre salinities divided by data length to get salinity drift.
drift = sum(post.sal - pre.sal)/length(time);

% QC procedure (apply initial "best guess" QC)
flags = sal.initialQC(time,drift);

% Write the drift information to a text file to document work.
fid = fopen('report.txt','w');
fprintf(fid,'Salinity drift (post cal data - pre cal data): %s \n',inputs.mooring);
fprintf(fid,'For the listed drift, negative values indicate scouring;\n');
fprintf(fid,'positive values indicate fouling;\n');
fprintf(fid,'%0dm Drift = %f\n',round(inputs.nominal_depths),drift); % MAKE 2D!
fclose(fid);
clear fid

% Housekeeping to fill out the dft structure.
dft.pres = pre.pres;
if ~isfield(dft,'temp')
    dft.temp = pre.temp;
end

% Adjust dft by offsets less than the instrument error. 
dft.cond = dft.cond+inputs.adjcond;
dft.temp = dft.temp+inputs.adjtemp;

% Call the MATLAB function for salinity/density. Calls subfunction atg as well.
if inputs.actual_pressure==1
    [dft.sal,dft.dens, dft.theta] = sal.sal78(dft.cond,dft.temp,dft.pres,round(inputs.nominal_depths,-3));
elseif inputs.actual_pressure==0
    [dft.sal,dft.dens, dft.theta] = sal.sal78(dft.cond,dft.temp,inputs.nominal_depths,round(inputs.nominal_depths,-3));
end

% Consider using sal.plot_highres(time,[],[],pre,post,dft,[],[]); to plot
% pre/post data.

% Any adjustments or flags from the config get applied here!  Q0/Q5 are NaN'd.
[flags,dft] = sal.apply_flags(time,inputs,flags,dft);
 
% Chop times to 2 hrs after anchor drop and acoustic pop for DisDel + OS (further truncation when making DisDel file).
idx_10 = (datenum(inputs.startdt)+2/24)<time & time<datenum(inputs.enddtOS); % enddtOS is time of acoustic pop.
dft.temp = dft.temp(idx_10);
dft.cond = dft.cond(idx_10);
dft.pres = dft.pres(idx_10);
dft.sal = dft.sal(idx_10);
dft.dens = dft.dens(idx_10);
flags.T = flags.T(idx_10);
flags.C = flags.C(idx_10);
flags.P = flags.P(idx_10);
flags.S = flags.S(idx_10);
flags.D = flags.D(idx_10);
time = time(idx_10);
dft.theta = dft.theta(idx_10);

% Correction for conductivity "tails", if needed. Specify length of quadratic fit in config.
if isfield(inputs,'correct_polyfit')
    [dft.cond,flags] = sal.correct_polyfit(time,dft,flags,inputs.correct_polyfit);
    if inputs.actual_pressure==1
        [dft.sal,dft.dens, dft.theta] = sal.sal78(dft.cond,dft.temp,dft.pres,round(inputs.nominal_depths,-3));
    elseif inputs.actual_pressure==0
        [dft.sal,dft.dens, dft.theta] = sal.sal78(dft.cond,dft.temp,inputs.nominal_depths,round(inputs.nominal_depths,-3));
    end
end

% Apply hanning filter to get hourly data (flt). Note that only C/T/P are filtered, then recalculate S/D.  Always 13 point for subsurface 10min data!
[time_hr,flt,flags] = sal.hanning_qc(time,dft,13,flags);

% Now recalcualte S/D from hourly T/C/P (using T/P flagged as C to prevent end spike).
if inputs.actual_pressure==1
    [flt.sal,flt.dens, flt.theta] = sal.sal78(flt.cond,flt.tempc,flt.presc,round(inputs.nominal_depths,-3));
elseif inputs.actual_pressure==0
    [flt.sal,flt.dens, flt.theta] = sal.sal78(flt.cond,flt.tempc,inputs.nominal_depths,round(inputs.nominal_depths,-3));
end

% Apply boxcar filter to get daily data (davg) from the high res (dft or flt).
[time_dy,davg,flags] = sal.davg(time,time_hr,dft.temp,flt.cond,dft.pres,flt.sal,flt.dens,flags);

% Round off to reasonable # digits.
[dft,flt,davg] = sal.do_round(dft,flt,davg);

% Plotting options.
% sal.plot_highres(time,time_hr,time_dy,pre,post,dft,[],[]);
% sal.plot_deployments(inputs);

% Convert mS/cm to S/m.
dft.cond = dft.cond/10;
flt.cond = flt.cond/10;
davg.cond = davg.cond/10;

% Save finished product.
save('FINAL_OS.mat');
[dft,flt,davg,time,time_hr,time_dy,flags] = sal.chop(dft,flt,davg,time,time_hr,time_dy,flags,inputs.enddt); % enddt truncates end to AD+2.
save('FINAL_DISDEL.mat');

% Generate OS and DisDel NetCDF files.
disp('Generating OceanSITES and DisDel NetCDFs, and daily SQL file.')
sal.make_OS();
sal.make_disdel();
sal.make_SQL();













