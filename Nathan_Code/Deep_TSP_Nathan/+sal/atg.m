function [atg] = atg(s,t,p)
  % Adiabatic temperature gradient (deg C per dbar)
  ds = s - 35;
  atg = (((-2.1687e-16 * t + 1.8676e-14) .* t - 4.6206e-13) .* p +((2.7759e-12 * t - 1.1351e-10) .* ds + ((-5.4481e-14 * t + 8.733e-12) .* t - 6.7795e-10) .* t + 1.8741e-8)) .* p +(-4.2393e-8 * t + 1.8932e-6) .* ds +((6.6228e-10 * t - 6.836e-8) .* t + 8.5258e-6) .* t + 3.5803e-5;
end