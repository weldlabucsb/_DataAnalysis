lineWidth = 1;
dotSize = [7,5];

%%

cmap = colormap(lines(2));

colororder([; cmap(2,:)]);

%%

load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\kickedaa_decay_rates\decay_rate_fit_results.mat");

decayRate_figH = figure(500); 
% ax = axes(decayRate_figH,'visible','off');

yyaxis left;

shapes = ['s','o'];
colors = colormap(lines(2));

decayRateConvert = 1e3;

fmat = ["%1.0f";"%1.0f"];

s1 = 10;
    
[bands,~,higherbands] = bandcalc(s1);

% p = errorbar(Tvalues{1}, decay_rate{1} * decayRateConvert,...
%         yneg{1} * decayRateConvert, ypos{1} * decayRateConvert, ...
%         shapes(1), 'Color', 'k',...
%         'CapSize',0,...
%         'MarkerFaceColor',colors(1,:));
p = errorbar(Tvalues{1}, decay_rate{1} * decayRateConvert,...
        yneg{1} * decayRateConvert, ypos{1} * decayRateConvert, ...
        shapes(1), 'Color', 'k',...
        'CapSize',0);
p.LineWidth = lineWidth;
p.MarkerSize = dotSize(1);

set(p,'HandleVisibility','off');

ylim([-0.2,4.2]);
xlim([10,245]);
    
    %%
    
    xtickformat('%1.0f')
%     ytickformat(fmat(1))
    
    %%
    
    set(gca, 'FontSize', 9);
    
    ax = gca;
    ax.FontSize = 20;
    
    set(ax,'TickDir','out');
    set(gca,'FontSize', 9)
    set(gca,'FontName','Times New Roman')
    ylim([0,4.1]);
    
    %%
    
    load("G:\My Drive\_WeldLab\Figures\KickedAA\fig - decay rate theory\esat_decay_results_numerical.mat");
    
    yyaxis right;
%     plot(T_external_2(2:2:end)*1E6,decay(2:2:end),'-')
    plot(T_external_2(1:end)*1E6,movmean(decay(1:end),3),'-',...
        'LineWidth',1);
%     plot(T_external_2*1E6,movmean(decay,3),'-')
%     plot(T_external_2(2:2:end)*1E6,movmean(decay(2:2:end),3),'-')

    ylabel('Decay rate (s^{-1})')
    xlabel('Kick period (us)')

    xlim([10 224]);
    ylim([0,0.068]);
    
    %%
    
    hold off;
    
    set(decayRate_figH,'Position',[-900, 909, 398, 263]);
  
    %%
    
%     netpower = kickedAA_weightedFourierPower('Scaling',1e6);
%     netpower = movmean(netpower,3);
%     getTile(1);
%     plot(Tplot,netpower,'-','Color',colors(ii,:),'LineWidth',1.5)