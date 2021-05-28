T = 3000e-6;
tau = 30e-6;
% tau_list = 1e-6:2e-6:50e-6;
Fs = 1e9;
tF = 1e-2;

%%

outfolder = "G:\My Drive\_WeldLab\Code\spectral_engineering\results\compare\singles";

%%

[~,transitions,~] = bandcalc(10);

%%

filter = "BrickWall";
% filter = "";
    
%%

syms y(t)
syms t

%%%%%%%%%%%%%

% y = @(t) (square( 2*pi*(t+tau/2)/T, tau/T * 100 ) + 1)/2;
% pulsetype = "square";

%%%%%%%%%%%%%
% y = @(t) exp( - 1 ./ (1 - 4*( t/tau  ).^2) ) .* ( (-tau/2 < t) & (t < tau /2) );
% % % 
% discY = y(tt); discY(~isfinite(discY)) = 0;
% norm = trapz(tt,discY);
% y2 = @(t) y(t) * (tau/norm);
% y = @(t) y2(t);
% pulsetype = "bump-sameArea";

% y2 = @(t) y(t) * (1/norm);
% y = @(t) y2(t);
% pulsetype = "bump-unitArea";

% norm = max(y(tt));
% y2 = @(t) y(t) * (1/norm);
% y = @(t) y2(t);
% pulsetype = "bump-sameHeight";
% 

%%%%%%%%%%%

y = @(t) exp(- t.^2/( 2 * (tau/2)^2 ));
tt = -T:(1/Fs):T; 
discY = y(tt); discY(~isfinite(discY)) = 0;
norm = trapz(tt,discY);
y2 = @(t) y(t) * (tau/norm);
y = @(t) y2(t);
pulsetype = "gauss-sameArea";

%%

[pulse_voltage,pulse_Er,bands_power,figure_handle] = ...
    designPulse(y,T,tau,Fs,transitions,'Filter',filter);

%%

if filter ~= ""
    pulsetype = strcat(pulsetype,"-",filter);
end

fname = strcat(pulsetype,"-T",num2str(T*1e6),...
    ",tau",num2str(tau*1e6),".png");

saveas(figure_handle,fullfile(outfolder,fname));

%%

winopen(outfolder);