function [groundToNthBand_Tus, groundToNthBand_kHz, firstExcitedtoHigherBands_Tus] = bandcalc(s1)

arguments
    s1
end
arguments
    options.PlotBand = 0
end

wavelength = 1064 * 10^(-9); % m
m_Sr84 = 1.3934152 * 10^(-25); % kg

hbar = 1.054 * 10^(-34); % J*s
h = 2 * pi * hbar; 

bands = 5;

max_l = 50;
dim = 2 * max_l + 1; % to get values from -max_l to max_l

V_latt = s1;

k_res = 1000;
k = linspace(-1,1,k_res);
% k is quasimomentum, and we'll compute over k = -1 to k = 1 (units of
% hbar k_latt)

H = zeros(dim,dim,k_res);

for ii = 1:dim
    for jj = 1:dim
        
        % diagonal elements
        if ii == jj
            H(ii,jj,:) = (2*(ii - (max_l + 1)) + k ).^2; % in units of lattice recoils of primary lattice
        end
        
        % off-diagonal elements
        if (ii == jj + 1) || (ii == jj - 1)
            H(ii,jj,:) = - V_latt ./ 4;
        end
    end
end

% compute eig for each quasimomentum q
Energies = zeros(dim,k_res);
for q = 1:k_res
    Energies(:,q) = eig( H(:,:,q) );
end

if options.BandPlot
    clf
    fig = figure(10);
    
    hold on
    for m = 1:bands
        plot(k,Energies(m,:));
    end
    hold off

    Title = strcat("Band Structure: Lattice Depth = ",num2str(V_latt)," Er");
    title(Title);
end

format long

% J_1064 = (max(Energies(1,:)) - min(Energies(1,:)))/4 % in 1064 Er's

% J_915 = J_1064 * ( 915 / 1064 )^2

recoil_frequency_1064 = h/(2*m_Sr84*wavelength^2);
% J_Frequency = recoil_frequency_1064 * J_1064

for ii = 2:bands
    groundToNthBand{ii} = [min(Energies(ii,:)) - max(Energies(1,:)), max(Energies(ii,:)) - min(Energies(1,:))];
    groundToNthBand_Hz{ii} = groundToNthBand{ii} * recoil_frequency_1064;
    groundToNthBand_Tus{ii} = (1 ./ groundToNthBand_Hz{ii}) * 1e6;
    groundToNthBand_kHz{ii} = groundToNthBand_Hz{ii} / 1e3;
end

for ii = 3:4
       firstExcitedtoHigherBands{ii} = [min(Energies(ii,:)) - max(Energies(2,:)), max(Energies(ii,:)) - min(Energies(2,:))];
       firstExcitedtoHigherBands_Hz{ii} = firstExcitedtoHigherBands{ii} * recoil_frequency_1064;
       firstExcitedtoHigherBands_Tus{ii} = (1 ./ firstExcitedtoHigherBands_Hz{ii}) * 1e6; 
end

end