function [flags,dft] = apply_flags(time,inputs,flags,dft)
% Applies flags from config.m.
if isfield(inputs,'sflags')
    flags.S = flag_routine(time,inputs.sflags,flags.S);
    dft.sal(flags.S==5 | flags.S==0) = NaN;
end

if isfield(inputs,'cflags')
    flags.C = flag_routine(time,inputs.cflags,flags.C);
    dft.cond(flags.C==5 | flags.C==0) = NaN;
end

if isfield(inputs,'pflags')
    flags.P = flag_routine(time,inputs.pflags,flags.P);
    dft.pres(flags.P==5 | flags.P==0) = NaN;
end

if isfield(inputs,'tflags')
    flags.T = flag_routine(time,inputs.tflags,flags.T);
    dft.temp(flags.T==5 | flags.T==0) = NaN;
end
    
if isfield(inputs,'dflags')
    flags.D = flag_routine(time,inputs.dflags,flags.D);
    dft.dens(flags.D==5 | flags.D==0) = NaN;
end

end

function [flags] = flag_routine(time,siv,flags) % siv = specific input variable
for i = 1:size(siv,1)
    idx = time>=siv(i,1) & time<=siv(i,2);
    flags(idx) = siv(i,3); % sf = specific flags
end 
end
