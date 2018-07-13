function [dft,flt,davg] = do_round(dft,flt,davg)
% Round all distributed values to their initial precision.
dft.temp = round(dft.temp,4);
dft.sal = round(dft.sal,4);
dft.dens = round(dft.dens,4);
dft.cond = round(dft.cond,4);
dft.pres = round(dft.pres,3);

flt.temp = round(flt.temp,4);
flt.sal = round(flt.sal,4);
flt.dens = round(flt.dens,4);
flt.cond = round(flt.cond,4);
flt.pres = round(flt.pres,3);

davg.temp = round(davg.temp,4);
davg.sal = round(davg.sal,4);
davg.dens = round(davg.dens,4);
davg.cond = round(davg.cond,4);
davg.pres = round(davg.pres,3);


end

