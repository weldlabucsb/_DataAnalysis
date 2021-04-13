function [plot1, plot2, plot3, fitdata, fit_rects] = dualGaussPlot(RunData,RunVars,options)
%% DUALGAUSSPLOT(RunData, RunVars, options) [one plot per run]
% Plots a two-gaussian fit to the localized and delocalized fractions of an expansion distribution.
% Returns an extra output, a struct of the fits and the widths of each

arguments
    RunData
    RunVars
end
arguments
    options.PlottedDensity = "summedODy"
    %
    options.yLabel string = "Density"
    options.yUnits string = "(a.u.)"
    %
    options.xLabel string = "Position"
    options.xUnits string = "(um)"
    %
    options.FontSize (1,1) double = 20
    options.LegendFontSize (1,1) double = 16
    options.TitleFontSize (1,1) double = 20
    %
    options.Interpreter (1,1) string = "latex"
    %
    options.LegendLabels = []
    options.LegendTitle string = ""
    options.Position (1,4) double = [2561, 224, 1920, 963];
    %
    options.PlotTitle = ""
    %
    options.xLim (1,2) double = [0,800]
    options.yLim (1,2) double
    %
    options.PlotPadding = 15;
    %
    options.SmoothWindow = 5;
    %
    options.ManualFitting (1,1) logical = 1
    %
    options.FitRects = {}
    %
    options.SubFigureLineWidth = 3;
end

RunDatas = cellWrap(RunData);
frects = options.FitRects;

%%

varied_variable_name = RunVars.varied_var;
legendvars = RunVars.varied_var;
varargin = {RunVars.heldvars_each};

%%

plottedDensity = options.PlottedDensity;

if plottedDensity == "summedODy"
    SD = 'cloudSD_y';
elseif plottedDensity == "summedODx"
    SD = 'cloudSD_x';
end

%% Camera Params

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
[~,~,pixelsize,mag] = paramsfnc('ANDOR');
xConvert = pixelsize/mag * 1e6; % converts the x-axis to um.

%% Avg Atomdata entries for same varied_variable_value

    [ad, varied_var_values] = avgRepeats(...
            RunData, varied_variable_name, options.PlottedDensity);
        
    N = length(ad);
    
    for ii = 1:N
       density(ii,:) = [ad(ii).(options.PlottedDensity)]; 
    end

%%

    fig_handle1 = figure();

    figure_title_dependent_var = options.PlottedDensity;

    cmap = colormap( jet( size(ad, 2) ) );
    
    dim = ceil( sqrt( N ) );
    
    if dim * (dim-1) >= N
        dimx = dim;
        dimy = dim - 1;
    else
        dimx = dim;
        dimy = dim;
    end

    options.SubplotTitle = 1;
    options.SkipLegend = 1;
    options.SkipLabels = 1;

%%
    x = ( 1:length(density(1,:)) ) * xConvert;
    
%%

    for ii = 1:N
        
        subplot( dimy, dimx, ii  );
        
        y = movmean( density(ii,:), options.SmoothWindow );
        
        plot(x, y,'LineWidth',options.SubFigureLineWidth);
        
%         try
            if options.ManualFitting
                
                if isempty(options.FitRects)
                    [fitdata(ii).netFit, fitdata(ii).fit1, fitdata(ii).fit2, fit_rects{ii}] = ...
                        dualGaussManualFit( x, y, 'OriginalFigureHandle', fig_handle1, ...
                        'LineWidth', options.SubFigureLineWidth);
                else
                    [fitdata(ii).netFit, fitdata(ii).fit1, fitdata(ii).fit2, fit_rects{ii}] = ...
                        dualGaussManualFit( x, y, 'OriginalFigureHandle', fig_handle1,...
                        'FitRect', frects{ii}, ...
                        'LineWidth', options.SubFigureLineWidth);
                end
                
                yfit = fitdata(ii).fit1;
                fitdata(ii).width1 = yfit.sigma1;
                fitdata(ii).atomnumber1 = trapz(x, yfit(x) - yfit.c1);
                fitdata(ii).center1 = yfit.x1;


                yfit = fitdata(ii).fit2;
                fitdata(ii).width2 = yfit.sigma2;
                fitdata(ii).atomnumber2 = trapz(x, yfit(x));
                fitdata(ii).center2 = yfit.x2;
                
%                 centers1 = arrayfun(@(x) x.fit1.center1, fitdata);
%                 centers2 = arrayfun(@(x) x.fit2.center2, fitdata);
                
%                 widths1 = arrayfun(@(x) x.fit1.sigma1, fitdata);
%                 widths2 = arrayfun(@(x) x.fit2.sigma2, fitdata);
                
            else
                
                [fitdata(ii).netFit, fitdata(ii).fit1, fitdata(ii).fit2] = ...
                    dualGaussAutoFit(x,y);
                
                yfit = fitdata(ii).netFit;
                
                fitdata(ii).width1 = yfit.sigma1; 
%                 widths1 = [fitdata.width1];
                fitdata(ii).width2 = yfit.sigma2; 
%                 widths2 = [fitdata.width2];
                
                fitdata(ii).center1 = yfit.x1; 
%                 centers1 = [fitdata.center1];
                fitdata(ii).center2 = yfit.x2; 
%                 centers2 = [fitdata.center2];
                
                fitdata(ii).atomnumber1 = trapz(x, fitdata(ii).fit1);
                fitdata(ii).atomnumber2 = trapz(x, fitdata(ii).fit2);
                
            end
            
            widths1 = [fitdata.width1];
            widths2 = [fitdata.width2];
            
            centers1 = [fitdata.center1];
            centers2 = [fitdata.center2];
            
            atomNumbers1 = [fitdata.atomnumber1];
            atomNumbers2 = [fitdata.atomnumber2];
            
            net_atomnums = atomNumbers1 + atomNumbers2;
            atomNumbers1 = atomNumbers1 ./ net_atomnums;
            atomNumbers2 = atomNumbers2 ./ net_atomnums;
            
%         catch
%             disp(strcat(...
%                 "Fit failed on entry ", num2str(ii), "/", num2str(N) ...
%             ));
%         end
        
        title(['915VVA = ' num2str(varied_var_values(ii))],'Interpreter','latex')
        
        xlim(options.xLim);
    end

%%

[plot_title1, fig_filename1] = setupPlotWrap( ...
    fig_handle1, ...
    options, ...
    RunDatas, ...
    figure_title_dependent_var, ...
    varied_variable_name, ...
    legendvars, ...
    varargin);

plot1.fig_handle = fig_handle1;
plot1.plot_title = plot_title1;
plot1.fig_filename = fig_filename1;
        
%% Width Evolution Plot

fig_handle2 = figure();

plot( varied_var_values, widths1, '.-', ...
    'LineWidth', 1.5)
hold on;
plot( varied_var_values, widths2, '.-', ...
    'LineWidth', 1.5);
hold off;
% title( plotTitle( RunData, 'Fitted Component Widths', varied_variable_name, varargin ) );

options2 = options;
options2.SkipLegend = 1;
options2.xLim = [varied_var_values(1) varied_var_values(end)];
options2.LegendFontSize = 16;
options2.PlotPadding = 0;
options2.yLabel = "Fitted Component Widths (um)";
options2.xLabel = varied_variable_name;
options2.SubplotTitle = 0;

[plot_title2, fig_filename2] = setupPlotWrap( ...
    fig_handle2, ...
    options2, ...
    RunDatas, ...
    "Fitted Component Widths",...
    varied_variable_name,...
    legendvars,...
    varargin);

legend(["Population 1","Population 2"]);

plot2.fig_handle = fig_handle2;
plot2.plot_title = plot_title2;
plot2.fig_filename = fig_filename2;

%% Atom Number Evolution Plot

fig_handle3 = figure();

plot( varied_var_values, atomNumbers1, '.-', ...
    'LineWidth', 1.5)
hold on;
plot( varied_var_values, atomNumbers2, '.-', ...
    'LineWidth', 1.5);
hold off;
% title( plotTitle( RunData, 'Fitted Component Widths', varied_variable_name, varargin ) );

options2.yLabel = "Fractional Atom Number (a.u.)";

[plot_title3, fig_filename3] = setupPlotWrap( ...
    fig_handle3, ...
    options2, ...
    RunDatas, ...
    "Fractional Atom Number",...
    varied_variable_name,...
    legendvars,...
    varargin);

legend(["Population 1","Population 2"]);

plot3.fig_handle = fig_handle3;
plot3.plot_title = plot_title3;
plot3.fig_filename = fig_filename3;

%%

% fig_handle4 = figure();
% 
% plot( varied_var_values, centers1, '.-', ...
%     'LineWidth', 1.5)
% hold on;
% plot( varied_var_values, centers2, '.-', ...
%     'LineWidth', 1.5);
% hold off;
% % title( plotTitle( RunData, 'Fitted Component Widths', varied_variable_name, varargin ) );
% 
% options2.yLabel = "Center Position (um)";
% 
% [plot_title4, fig_filename4] = setupPlotWrap( ...
%     fig_handle4, ...
%     options2, ...
%     RunDatas, ...
%     "Center Position",...
%     varied_variable_name,...
%     legendvars,...
%     varargin);
% 
% legend(["Population 1","Population 2"]);

end