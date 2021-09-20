hbar = 1.0545718e-34; % J * sec
kg_per_amu = 1.66054e-27; % amu/kg
mSr_amu = 84; % amu
lambda_1064 = 1064e-9; % m
k_1064 = 2*pi/lambda_1064;

mSr_kg = mSr_amu * kg_per_amu;

Er_1064 = (hbar^2 * k_1064^2)/(2*mSr_kg); % "J per Er"

hbar_Er1064 = hbar / Er_1064;