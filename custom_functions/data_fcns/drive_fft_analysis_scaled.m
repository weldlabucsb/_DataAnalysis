function [f,P1,power]=  drive_fft_analysis_scaled(T,tau)
%now in terms of KickedAA Params
if (nargin < 2)
    T = 14E-6; %sec
    tau = 1E-6; %sec
end

%can either be run with a constant lattice hold or vary with T. changes the
%fourier power I think. For the decay rate plots we care about versus time
%not versus kick number so I think that constant lattHold makes sense. The
%first good fourier comparison plot that was sent out used the following:'
lattHold = 0.5E-1; %sec
% lattHold = T*100; %sec

sampPer = 50; %how many samples per period
sampPer = sampPer + mod(sampPer,2);
duty = tau/T;
cycles = round(lattHold/T);
Fs = sampPer/T; %Hz

x = linspace(0,1,sampPer);
x = x < duty;
x = repmat(x,1,cycles);
L = length(x);

Y = fft(x);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

power = abs(Y).^2/L;
power = power(1:L/2 + 1);
power(1) = 0;
f = Fs*(0:(L/2))/L;
P1(1) = 0; %remove constant component
% plot(f./1E3,P1);
% title('Single-Sided Amplitude Spectrum of S(t)')
% xlabel('f (kHz)')
% ylabel('|P1(f)|')
end


