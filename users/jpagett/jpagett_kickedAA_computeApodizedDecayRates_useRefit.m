%%

% load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\KickedAA_pulseCompare\kickedaa_decay_rates_compare_samples\data\2021-06-21 data\2021-06-21_refitted_pulseCompare_data.mat");
%%

avgRDs = refitData.avgRDs;
good_fit_flags = refitData.good_fit_tags;

%%
N = length(avgRDs);

% for ii = 1:N
for ii = 1:N
    
    disp(num2str(ii))
    
    thesevals = [avgRDs{ii}.gaussAtomNumber_y];
    zeroIdx = find(thesevals == 0);
    good_fit_flags{ii}( (zeroIdx+1):end ) = 0;
    
    excl_idx = 1:length(avgRDs{ii});
    excl_idx = excl_idx(~good_fit_flags{ii});
    
%     excl_idx(end + 1) = 1;
%     excl_idx(end + 1) = 2;
%     excl_idx = unique(excl_idx);
   
%     try
        fitResult{ii} = kickedAA_decayFit_avgRDs(avgRDs{ii},...
            'ExcludedIndices',excl_idx,...
            'PlotVariable','gaussAtomNumber_y');
        thisConfInt = confint(fitResult{ii}.fit);
        yneg(ii) = abs(fitResult{ii}.fit.b - thisConfInt(1));
        ypos(ii) = abs(thisConfInt(2) - fitResult{ii}.fit.b);
%         pause(0.25);
    keyboard;
%     catch
%         fitResult{ii}.decayRate = 100;
%         yneg(ii) = 0;
%         ypos(ii) = 0;
% %         fitResult{ii}.T_us = RunDatas{ii}.ncVars.T;
% %         fitResult{ii}.tau_us = RunDatas{ii}.ncVars.tau;
% %         fitResult{ii}.PulseType = RunDatas{ii}.ncVars.PulseType;
%     end
    
    if mod(ii,5) == 0
        disp(['Done with ' num2str(ii) '/' num2str(N)]);
    end
    
    switch fitResult{ii}.T_us
        case 75
            idx = 1;
        case 100
            idx = 2;
        case 150
            idx = 3;
        case 250
            idx = 4;
        case 1000
            switch fitResult{ii}.tau_us
                case 10
                    idx = 5;
                case 100
                    idx = 6;
            end
    end
    
    fitResult{ii}.idx = idx;
    
end

%%

Tlist = [75, 100, 150, 250, 1000, 1000];
taulist = [1, 1, 1, 15, 10, 100];
tickpos = 1:6;

for ii = 1:6
   labels{ii} = strcat("T = ",num2str(Tlist(ii)),", \tau = ",num2str(taulist(ii)));
end

flags = zeros(size(fitResult));

%%

h = figure(1);
colors = colormap(lines(4));

for ii = 1:N
    
    switch fitResult{ii}.PulseType
        case {'G','g'}
            marker = 'o';
            markerSize = 38;
            color = colors(1,:);
        case {'S','s'}
            marker = 's';
            markerSize = 60;
            color = colors(2,:);
        case {'F','f'}
            marker = '^';
            markerSize = 32;
            color = colors(3,:);
    end
    
    if fitResult{ii}.decayRate == 100 || flags(ii)
        flags(ii) = 1;
        color = [1 0 0];
        fitResult{ii}.decayRate = - 0.1;
%         disp("hi");
    end
    
    scatter( fitResult{ii}.idx, -fitResult{ii}.decayRate * 1e3,...
        markerSize, color, marker);
    hold on;
    
%     p = errorbar(fitResult{ii}.idx, -fitResult{ii}.decayRate * 1e3,...
%             yneg(ii) * 1e3, ypos(ii) * 1e3, ...
%             marker, 'Color', color,...
%             'CapSize',0,...
%             'MarkerFaceColor','none',...
%             'MarkerEdgeColor','none',...
%             'HandleVisibility', 'off');
%         p.LineWidth = 1;
%         p.MarkerSize = markerSize;
    
end
hold off;

xlim([0,7])
set(gca,'yscale','log')

ylim([1e-15, 1e2])
% ylim([0,1.1])

ax = gca;
ax.XTick = tickpos;
ax.XTickLabel = labels;

ylabel('Decay Rate (s^{-1})');

legend('Square','Gaussian','Filtered','Location','east');

set(h,'Position',[-929, 1048, 329, 300]);
