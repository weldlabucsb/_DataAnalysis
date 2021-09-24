function netpower = kickedAA_weightedFourierPower(T,tau,s1,scaling,Fs)

arguments
    T = 15:1:300 % in us
    tau = 1 % in us
    s1 = 10
    scaling = 1e6 % scale fudge factor
    Fs = 1e7
end

T = T*1e-6;

Tplot = T*1e6;
Tplot(1) = [];

tau = tau*1e-6;

NSamples = 31;
% s1 = [10, 15];


Ts = 1/Fs;

%%

avgFCF = kickedAA_avgFCFsquare(s1,'Plot',0);

%%

[~,transitions_kHz,~] = bandcalc(s1);
transitions_kHz = transitions_kHz( cellfun(@(x) ~isempty(x), transitions_kHz) );
transitions = cellfun(@(x) x*1e3, transitions_kHz, 'UniformOutput', 0);
if length(transitions) > 3
    transitions = transitions(1:3);
end


for ii = 1:length(T)
    
    T_us = T(ii);
    
    Nt = (-NSamples*T_us/2):Ts:(NSamples*T_us/2); Nt(end) = [];
    Nt = round(Nt,10);
%     idx1p = round( (NSamples - 1)/2 * T_us/Ts + 1 );
%     idx2p = round( idx1p + T_us/Ts - 1 );
%     pulseIdx = idx1p:idx2p;
%     t = Nt(pulseIdx);

    Y = square_pulse(T_us,tau,Nt);
    
    for jj = 1:length(transitions)
        powers{ii}(jj) = bandpower(Y,Fs,transitions{jj}) * avgFCF(jj+1);
    end
    
    netpower(ii) = sum(powers{ii});
    
    if mod(ii,10) == 0
       disp(['Done with ', num2str(ii), '/', num2str(length(T))]);
    end
    
end

% for ii = 1:length(netpower)
%     netpower(ii) = netpower(ii) *
% end

%%

netpower(1) = [];

netpower = netpower * scaling;

end

function Y = square_pulse(T,tau,NSample_time_vector)
    ysquare = @(t) (square( 2*pi*(t+tau/2)/T, tau/T * 100 ) + 1)/2;
    Y = ysquare(NSample_time_vector);
end