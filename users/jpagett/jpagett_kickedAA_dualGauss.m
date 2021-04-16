titleFontSize1 = 40;
subfigLineWidth = 3;

titleFontSize = 34;
markerSize = 24;
legendFontSize = 32;
labelFontSize = 32;
axesLabelFontSize = 26;

%%

% load("E:\Data\kickedaa_E\kickedaa_3-23-2021_runs10-20_moreVary915.mat");
% selectRuns(Data);
% keyboard;

%%

saveDir = "G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\KickedAA_DualGauss\figures";

for j = 1:length(RunDatas)
    
    if ~exist('frects')
        [plot1, plot2, plot3, fits, frects] = dualGaussPlot(RunDatas,RunVars,...
        'TitleFontSize', 16, ...
        'ManualFitting', 1, ...
        'SubFigureLineWidth', subfigLineWidth);
    else
        [plot1, plot2, plot3, fits, frects] = dualGaussPlot(RunDatas,RunVars,...
        'TitleFontSize', 16, ...
        'ManualFitting', 1, ....
        'FitRects',frects, ...
        'SubFigureLineWidth', subfigLineWidth);
    end

    fitPlot{j} = plot1;
    widthPlot{j} = plot2;
    popPlot{j} = plot3;
    fitObjs{j} = fits;

    saveSubDir = fullfile(saveDir, runDateList(RunDatas) );

%%

    paramstring{j} = strcat("1064 Depth - 10 E$_\mathrm{r}$,",...
            " Lattice Hold - ",num2str(RunDatas{j}.vars.LatticeHold,'%3.0f')," ms,",...
            " $T$ - ",num2str(RunDatas{j}.ncVars.T / 1e3,'%1.1f')," ms,",...
            " $\tau$ - ",num2str(RunDatas{j}.ncVars.tau,'%3.0f')," us");

    %%

    figure(plot1.fig_handle);
    
    fig1SaveTitle = {"Density vs. Disorder Lattice Depth"; paramstring{j}};
%     fig1Title = "Density vs. Disorder Lattice Depth";
    sgtitle(fig1SaveTitle,...
            'Interpreter','Latex',...
            'FontSize',titleFontSize1);
        
%     saveFigure( plot1.fig_handle, filenameFromPlotTitle(fig1SaveTitle), saveSubDir, ...
%         'SaveFigFile', 1);

    %% 

    figure(plot2.fig_handle);
    fchild = get(plot2.fig_handle,'Children');
    leg = fchild(1);
    ax = fchild(2);
    
    xlim([2.2, 5.75]);
    ylim([0,160]);

    lins = get(ax,'Children');
    shapes = ['s', 'v', 'o'];
    for ii = 1:length(lins)
       set(lins(ii),'LineWidth',4); 
       set(lins(ii),'LineStyle','none');
       set(lins(ii),'Marker',shapes(ii));
       set(lins(ii),'MarkerSize',20);
    end

    set(leg,'FontSize',legendFontSize);
    set(leg,'Interpreter','latex');
    leg.Location = 'northeast';

    fig2Title = "Component Widths vs. Disorder Lattice Depth";
    title(fig2Title,...
            'Interpreter','Latex',...
            'FontSize',titleFontSize);
        
    set(gca,'FontSize',axesLabelFontSize);
    set(gca,'TickLabelInterpreter','latex');

    ylabel('Fit Width (um)',...
        'Interpreter','latex',...
        'FontSize',labelFontSize);

    xlabel('Disorder Lattice VVA ($\propto$ Depth)',...
        'Interpreter','latex',...
        'FontSize',labelFontSize);
    
    fig2SaveTitle = {"Component Widths vs. Disorder Lattice Depth"; paramstring{j}};
%     saveFigure( plot2.fig_handle, filenameFromPlotTitle(fig2SaveTitle), saveSubDir, ...
%         'SaveFigFile', 1);
    
    %%
    
    figure(plot3.fig_handle);
    fchild = get(plot3.fig_handle,'Children');
    leg = fchild(1);
    ax = fchild(2);
    
    xlim([0.95, 7.5]);
%     ylim([0, 1]);

    lins = get(ax,'Children');
    shapes = ['s', 'v', 'o'];
    for ii = 1:length(lins)
       set(lins(ii),'LineWidth',4); 
       set(lins(ii),'LineStyle','none');
       set(lins(ii),'Marker',shapes(ii));
       set(lins(ii),'MarkerSize',markerSize);
    end

    set(leg,'FontSize',legendFontSize);
    set(leg,'Interpreter','latex');
    leg.Location = 'east';

    fig3Title = "Fractional Population vs. Disorder Lattice Depth";
    title(fig3Title,...
            'Interpreter','Latex',...
            'FontSize',titleFontSize);
        
    set(gca,'FontSize',axesLabelFontSize);
    set(gca,'TickLabelInterpreter','latex');

    ylabel('Fractional Population',...
        'Interpreter','latex',...
        'FontSize',labelFontSize);

    xlabel('Disorder Lattice VVA ($\propto$ Depth)',...
        'Interpreter','latex',...
        'FontSize',labelFontSize);
    
    fig3SaveTitle = {"Fractional Population (norm to first pt) vs. Disorder Lattice Depth"; paramstring{j}};
    saveFigure( plot3.fig_handle, filenameFromPlotTitle(fig3SaveTitle), saveSubDir, ...
        'SaveFigFile', 1);
    
end
