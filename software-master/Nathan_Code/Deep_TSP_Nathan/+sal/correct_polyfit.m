function [cond,flags] = correct_polyfit(time,dft,flags,correction_length)
% This function is intended to correct the logarithmic/polynomial-looking
% curve at the front of many salinity timeseries.  Oftentimes, an artifact,
% thought to be a "film" on the conductivity sensor, erodes away with
% deployment length.

x = time(1:correction_length);
y = dft.sal(1:correction_length);
[p,a,mu] = polyfit(x,y,2);
f = polyval(p,x,[],mu);
adj = max(f)-f;
dft.sal(1:correction_length) = y + adj;
cond = gsw_C_from_SP(dft.sal,dft.temp,dft.pres);
flags.C(1:correction_length) = 3;
flags.S(1:correction_length) = 3;
flags.D(1:correction_length) = 3;
%plot(x,f,'r')
%plot(x,y+adj,'g');
end

