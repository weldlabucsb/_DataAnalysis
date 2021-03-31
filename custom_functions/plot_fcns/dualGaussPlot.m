function [fig_handle, fig_filename, widths] = dualGaussPlot(RunData,RunVars,options)
%% DUALGAUSSPLOT(RunData, RunVars, options) plots a two-gaussian fit to the localized and delocalized fractions of an expansion distribution.
% Returns 

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
    options.Position (1,4) double = [53, 183, 1331, 829];
    %
    options.PlotTitle = ""
    %
    options.xLim (1,2) double = [0,0]
    options.yLim (1,2) double
    %
    options.PlotPadding = 15;
    %
end

RunDatas = cellWrap(RunData);

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

    fig_handle = figure();

    figure_title_dependent_var = options.PlottedDensity;

    cmap = colormap( jet( size(ad, 2) ) );
    
    dim = ceil( sqrt( N ) );

    options.SubplotTitle = 1;
    options.SkipLegend = 1;
    options.SkipLabels = 1;

%%
    x = ( 1:length(density(1,:)) ) * xConvert;
    
%%

    for ii = 1:N
        
        subplot( dim, dim, ii  );
        
        plot(x, density(ii,:),'LineWidth',1.5);
        Fit{ii} = dual_gauss( x, density(ii,:) );
        
        widths(ii).fit = Fit{ii};
        widths(ii).thinWidth = min( Fit{ii}.sigma1, Fit{ii}.sigma2 );
        widths(ii).wideWidth = max( Fit{ii}.sigma1, Fit{ii}.sigma2 );
        
    end

%%

[~, fig_filename] = setupPlotWrap( ...
    fig_handle, ...
    options, ...
    RunDatas, ...
    figure_title_dependent_var, ...
    varied_variable_name, ...
    legendvars, ...
    varargin);
        
%%


end