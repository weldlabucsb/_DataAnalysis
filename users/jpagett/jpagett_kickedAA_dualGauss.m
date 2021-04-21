titleFontSize1 = 30;
subfigLineWidth = 3;

titleFontSize = 34;
markerSize = 24;
legendFontSize = 32;
labelFontSize = 32;
axesTickFontSize = 24;

lambdaDomain = [1, 3.3];

yFmtPopulation = '%0.2f';
xFmtLambda = '%1.1f';

%% Load Data

% load("E:\Data\kickedaa_E\kickedaa_3-23-2021_runs10-20_moreVary915.mat");
% selectRuns(Data);
% keyboard;

%%

saveDir = "G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\KickedAA_DualGauss\figures";

for j = 1:length(RunDatas)
    
    % plot1-3 are fig handles, fits are fit objects, and frects are the
    % rectangles you draw (saves them if you don't clear, so that you don't
    % have to redraw every time
    if ~exist('frects')
        [plot1, plot2, plot3, fits, frects, lattice_params] = dualGaussPlot(RunDatas,RunVars,...
        'TitleFontSize', 16, ...
        'ManualFitting', 1, ...
        'SubFigureLineWidth', subfigLineWidth);
    else
        [plot1, plot2, plot3, fits, frects, lattice_params] = dualGaussPlot(RunDatas,RunVars,...
        'TitleFontSize', 16, ...
        'ManualFitting', 1, ....
        'FitRects',frects, ...
        'SubFigureLineWidth', subfigLineWidth);
    end

    fitPlot{j} = plot1;
    widthPlot{j} = plot2;
    popPlot{j} = plot3;
    fitObjs{j} = fits;
    latticeParams{j} = lattice_params;

    saveDateList = strrep(runDateList(RunDatas),".","-");
    saveSubDir = fullfile(saveDir, saveDateList );

%% run parameters string

    paramstring{j} = strcat("1064 Depth - 10 Er,",...
            " Lattice Hold - ",num2str(RunDatas{j}.vars.LatticeHold,'%3.0f')," ms,",...
            " T - ",num2str(RunDatas{j}.ncVars.T / 1e3,'%1.1f')," ms,",...
            " \tau - ",num2str(RunDatas{j}.ncVars.tau,'%3.0f')," us");

    %%

    figure(plot1.fig_handle);
    
    fig1SaveTitle = {"Density vs. Disorder Lattice Depth"; paramstring{j}};
    sgtitle(fig1SaveTitle,...
            'Interpreter','tex',...
            'FontSize',titleFontSize1);
        
    saveFigure( plot1.fig_handle, filenameFromPlotTitle(fig1SaveTitle), saveSubDir, ...
        'SaveFigFile', 0);

    %% 

    figure(plot2.fig_handle);
    fchild = get(plot2.fig_handle,'Children');
    leg = fchild(1);
    ax = fchild(2);
    
    if exist('lambdaDomain')
        xlim(lambdaDomain);
    end
    ylim([0,240]);

    lins = get(ax,'Children');
    shapes = ['s', 'v', 'o'];
    for ii = 1:length(lins)
       set(lins(ii),'LineWidth',4); 
       set(lins(ii),'LineStyle','none');
       set(lins(ii),'Marker',shapes(ii));
       set(lins(ii),'MarkerSize',20);
    end

    set(leg,'FontSize',legendFontSize);
    set(leg,'Interpreter','tex');
    leg.Location = 'northeast';

    fig2Title = "Component Widths vs. Disorder Lattice Depth";
    title(fig2Title,...
            'Interpreter','tex',...
            'FontSize',titleFontSize);
        
    set(gca,'FontSize',axesTickFontSize);
    xtickformat(xFmtLambda);
    set(gca,'TickLabelInterpreter','tex');

    ylabel('Fit Width (um)',...
        'Interpreter','tex',...
        'FontSize',labelFontSize);

    xlabel('\lambda',...
        'Interpreter','tex',...
        'FontSize',labelFontSize);
    
    fig2SaveTitle = {"Component Widths vs. Disorder Lattice Depth"; paramstring{j}};
%     saveFigure( plot2.fig_handle, filenameFromPlotTitle(fig2SaveTitle), saveSubDir, ...
%         'SaveFigFile', 0);
    
    %%
    
    figure(plot3.fig_handle);
    fchild = get(plot3.fig_handle,'Children');
    leg = fchild(1);
    ax = fchild(2);
    
%     xlim([0.95, 7.5]);
%     xlim([2.2, 7.5]);
    if exist('lambdaDomain')
        xlim(lambdaDomain);
    end
%     ylim([0,0.35]);
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
    set(leg,'Interpreter','tex');
    leg.Location = 'east';

    fig3Title = "Localized Population vs. Disorder Lattice Depth";
    title(fig3Title,...
            'Interpreter','tex',...
            'FontSize',titleFontSize);
        
    set(gca,'FontSize',axesTickFontSize);
    ytickformat(yFmtPopulation);
    xtickformat(xFmtLambda);
    set(gca,'TickLabelInterpreter','tex');

    ylabel('Fractional Population',...
        'Interpreter','tex',...
        'FontSize',labelFontSize);

%     xlabel('Disorder Lattice VVA (\propto Depth)',...
%         'Interpreter','tex',...
%         'FontSize',labelFontSize);
    
    xlabel('\lambda',...
        'Interpreter','tex',...
        'FontSize',labelFontSize);
    
    fig3SaveTitle = {"Localized Population (norm to first pt) vs. Disorder Lattice Depth"; paramstring{j}};
%     fig3SaveTitle = {"Localized Population vs. Disorder Lattice Depth"; paramstring{j}};
    saveFigure( plot3.fig_handle, filenameFromPlotTitle(fig3SaveTitle), saveSubDir, ...
        'SaveFigFile', 0);
    
end




