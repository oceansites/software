function [dft,flt,davg,time,time_hr,time_dy,flags] = chop(dft,flt,davg,time,time_hr,time_dy,flags,endtime)
% This function truncates all resolutions to OS or DisDel times, to make the
% datasets flow together.

% 10 min
idx_10 = time<datenum(endtime);
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

% Hourly
idx_hr = time_hr<datenum(endtime);
flt.temp = flt.temp(idx_hr);
flt.cond = flt.cond(idx_hr);
flt.pres = flt.pres(idx_hr);
flt.sal = flt.sal(idx_hr);
flt.dens = flt.dens(idx_hr);
flags.T_hr = flags.T_hr(idx_hr);
flags.C_hr = flags.C_hr(idx_hr);
flags.P_hr = flags.P_hr(idx_hr);
flags.S_hr = flags.S_hr(idx_hr);
flags.D_hr = flags.D_hr(idx_hr);
time_hr = time_hr(idx_hr);
flt.theta = flt.theta(idx_hr);

% Daily
idx_dy = time_dy<datenum(endtime);
davg.temp = davg.temp(idx_dy);
davg.cond = davg.cond(idx_dy);
davg.pres = davg.pres(idx_dy);
davg.sal = davg.sal(idx_dy);
davg.dens = davg.dens(idx_dy);
flags.T_dy = flags.T_dy(idx_dy);
flags.C_dy = flags.C_dy(idx_dy);
flags.P_dy = flags.P_dy(idx_dy);
flags.S_dy = flags.S_dy(idx_dy);
flags.D_dy = flags.D_dy(idx_dy);
time_dy = time_dy(idx_dy);

end

