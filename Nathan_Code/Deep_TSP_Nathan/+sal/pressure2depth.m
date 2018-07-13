function [ depth ] = pressure2depth(median_pres,latitude)
% Input pressure in dbar and latitude to get associated depth in meters.
x = (sin(latitude/57.29578))^2;
gravity = 9.780318 * (1 + (5.2788*10^-3 + 2.36*10^-5 * x) * x) + (1.092*10^-6) * median_pres;
depth = ((((-1.82*10^-15 * median_pres + 2.279*10^-10) * median_pres - 2.2512*10^-5) * median_pres + 9.72659) * median_pres) / gravity;
end

