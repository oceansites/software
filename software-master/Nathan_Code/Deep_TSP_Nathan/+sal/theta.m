function [theta] = theta(s,t,p,pr)
  h = pr - p; % pr is reference pressure.
  xk = h .* sal.atg(s,t,p); % adiabatic temperature gradient deg C per dbar.
  t = t + 0.5 * xk;
  q = xk;
  p = p + 0.5 * h;
  xk = h .* sal.atg(s,t,p);
  t = t + 0.29289322 * (xk - q);
  q = 0.58578644 * xk + 0.121320344 * q;
  xk = h .* sal.atg(s,t,p);
  t = t + 1.707106781 * (xk - q);
  q = 3.414213562 * xk - 4.121320344 * q;
  p = p + 0.5 * h;
  xk = h .* sal.atg(s,t,p);
  theta = t + (xk - 2 * q) / 6;
end

