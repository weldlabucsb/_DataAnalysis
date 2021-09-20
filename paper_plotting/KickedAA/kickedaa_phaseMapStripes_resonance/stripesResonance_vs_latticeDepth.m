clear;
load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\kickedaa_phaseMapStripes_resonance\data\data_compiled_on_14-Sep-2021.mat");

RunDatas = Data.RunDatas;
RunDatas(2) = [];

%%

s1 = cellfun(@(rd) rd.vars.VVA1064_Er, RunDatas);

T_ms = cellfun( @(rd) ...
    arrayfun(@(ad) ad.vars.KickPeriodms, rd.Atomdata), ...
    RunDatas, 'UniformOutput', 0);

peak_densities = cellfun(@(rd) cell2mat(arrayfun(@(ad) ad.cloudAmp_y, ...
    rd.Atomdata, 'UniformOutput', 0)), ...
    RunDatas, 'UniformOutput', 0);

%% Find the resonant T (minimum cloud maxima?)

% get the index for which the minimum cloud amplitudes occur
[~, peak_idx] = cellfun( @(pds) ...
    findpeaks( -pds,'MinPeakProminence',400), ...
    peak_densities, 'UniformOutput', 0);

for j = 1:length(peak_idx)
    for ii = 1:length(peak_idx{j})
        resonant_Tms(j,ii) = T_ms{j}( peak_idx{j}(ii) );
    end
end

%% plot the T values for which the resonances occur

N = size(resonant_Tms,2);

resonant_Tms( resonant_Tms == 0 ) = NaN; 
s1_fine = linspace(min(s1),max(s1),100);

cmap = colormap(lines(N));
markerSize = 15;

figure(1);

for ii = 1:N
    
   scatter( s1, resonant_Tms(:,ii), ...
       markerSize, cmap(ii,:) );
   hold on;
   
   thefit{ii} = T_vs_s1_fit( s1, resonant_Tms(:,ii));
   plot( s1_fine, thefit{ii}(s1_fine), ...
       'Color', cmap(ii,:), ...
       'HandleVisibility', 'off' );
   
end
hold off;

leg = legend( string(cellfun(@(fits) fits.b, thefit)) );
title(leg,"Fit to \propto x^b, b =")

xlabel("1064 Lattice Depth (E_r)");
ylabel("Resonant T (ms)");

copygraphics(gcf);

%%

figure(2);

resonant_freq = 1 ./ (resonant_Tms / 1000);

for ii = 1:N
    
   scatter( s1, resonant_freq(:,ii), ...
       markerSize, cmap(ii,:) );
   hold on;
   
   the_freq_fit{ii} = freq_vs_s1_fit( s1, resonant_freq(:,ii));
   plot( s1_fine, the_freq_fit{ii}(s1_fine), ...
       'Color', cmap(ii,:), ...
       'HandleVisibility', 'off' );
   
end
hold off;

leg = legend( string(cellfun(@(fits) fits.b, the_freq_fit)) );
title(leg,"Fit to \propto x^b, b =")

xlabel("1064 Lattice Depth (E_r)");
ylabel("Resonant Carrier Frequency 1/T (Hz)");

%% Fitting Function

function [fitresult, gof] = T_vs_s1_fit(s1_list, T_list)

[xData, yData] = prepareCurveData( s1_list, T_list );

ft = fittype( 'power1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -1];
opts.Robust = 'Bisquare';
opts.StartPoint = [13.076792423396 -0.5];
opts.Upper = [Inf 0];

[fitresult, gof] = fit( xData, yData, ft, opts );

end

function [fitresult, gof] = freq_vs_s1_fit(s1_list, T_list)

[xData, yData] = prepareCurveData( s1_list, T_list );

ft = fittype( 'power1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf 0];
opts.Robust = 'Bisquare';
opts.StartPoint = [13.076792423396 0.5];
opts.Upper = [Inf 1];

[fitresult, gof] = fit( xData, yData, ft, opts );

end
