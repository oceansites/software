function [salinity,density,theta] = sal78(cond,temp,pres,ref_pres)  
  % Standard UNESCO equations.
  stdCond = 42.914;
  rt35a =  1.0031e-9;
  rt35b = -6.9698e-7;
  rt35c =  1.104259e-4;
  rt35d =  2.00564e-2;
  rt35e =  0.6766097;
  cpa   =  3.989e-15;
  cpb   = -6.370e-10;
  cpc   =  2.070e-5;
  bta   =  4.464e-4;
  btb   =  3.426e-2;
  temp = temp*1.00024;
  rt35 = (((rt35a .* temp + rt35b) .* temp + rt35c) .* temp + rt35d) .* temp + rt35e;
  cp = ((cpa .* pres + cpb) .* pres + cpc) .* pres;
  bt = (bta .* temp + btb) .* temp + 1.0;
  at = (-3.107e-3) .* temp + 0.4215;
  rt = (cond/stdCond)./(rt35 .* (1.0 + (cp./(bt + at .* (cond/stdCond)))));
  rt = sqrt(abs(rt));
  dt = temp - 15;
  term1 = ((((2.7081*rt - 7.0261).*rt + 14.0941).*rt + 25.3851).*rt -0.1692).*rt;
  term2 = 0.0080;
  term3a = dt./(1 + 0.0162*dt);
  term3b = ((((-0.0144*rt + 0.0636).*rt -0.0375).*rt - 0.0066).*rt - 0.0056).*rt + 0.0005;
  salinity = term1 + term2 + (term3a.*term3b);  % Return salinity here.
  
  % Calculate "DensityTwo" (sigma-theta, kg/m^3)
  s = salinity;
  % temp adjustment of ITS90*1.00024 = ITS68 is already applied, above.
  t = temp;
  p = pres;
  h = ref_pres - p; % 0 is reference pressure.
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
  
  % Now feed theta and salinity and pressure into "DensityOne"
  sal = s;
  temp = theta;
  presInput = ref_pres; % p = 0.0 from above.  Calculated at surface pressure. 
  % If we allow presInput to vary, density at S,T,P is sigma.
 
  % convert pressure (~depth in m) from decibars to bars
  pres = presInput * 1.0e-1;
  
  % rho(0,T,0)  -  density of freshwater at surface
  rw = 9.99842594e2 + 6.793952e-2 * temp - 9.095290e-3 * temp.^2 + 1.001685e-4 * temp.^3 - 1.120083e-6 * temp.^4 + 6.536332e-9 * temp.^5;
  
  % rho(S,T,0)  -  density of salty water at surface.  Density at S,T,0 is sigma-t.
  rsto = rw + (8.24493e-1 - 4.0899e-3*temp + 7.6438e-5*temp.^2 - 8.2467e-7*temp.^3 + 5.3875e-9*temp.^4).*sal + (-5.72466e-3 + 1.0227e-4*temp - 1.6546e-6*temp.^2).*sal.^1.5 + 4.8314e-4 * sal.^2;
  
  % K(0,T,0) = Kw  -  secant bulk modulus of water
  akw = 1.965221e4 + 1.484206e2  * temp - 2.327105e0  * temp.^2 + 1.360477e-2 * temp.^3 - 5.155288e-5 * temp.^4;
  
  % K(S,T,0)  -  secant bulk modulus of salty water
  aksto = akw + sal .* (5.46746e1 - 6.03459e-1*temp + 1.09987e-2*temp.^2 - 6.1670e-5*temp.^3) + (7.944e-2 + 1.6483e-2*temp - 5.3009e-4*temp.^2) .* sal.^1.5;
  
  %K(S,T,P)  -  secant bulk modulus of compressed salty water
  akstp = aksto + (3.239908e0 + 1.43713e-3*temp + 1.16092e-4*temp.^2 - 5.77905e-7*temp.^3) .* pres + (2.2838e-3 - 1.0981e-5*temp - 1.6078e-6*temp.^2) .* pres .* sal + 1.91075e-4 * pres .* sal.^1.5 + (8.50935e-5 - 6.12293e-6*temp + 5.2787e-8*temp.^2) .* pres.^2 + (-9.9348e-7 + 2.0816e-8*temp + 9.1697e-10*temp.^2) .* pres.^2 .* sal;
  
  %rho(S,T,P)  -  density of compressed salty water
  rho = rsto ./ (1.0e0 - pres./akstp);
  density = rho - 1000; % Sigma-theta (density at S,theta,0)
  
  
  
  
  
  