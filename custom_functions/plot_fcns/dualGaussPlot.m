function [fig_handle, fig_filename] = dualGaussPlot(RunData,RunVars,options)
%% DUALGAUSSPLOT(RunData, RunVars, options) plots a two-gaussian fit to the localized and delocalized fractions of an expansion distribution.
% Returns 

arguments
    RunDatas
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

varied_variable_name = RunVars.varied_var;
legendvars = RunVars.heldvars_each;
varargin = {RunVars.heldvars_all};

%%

RunDatas = cellWrap(RunDatas);

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

for j = 1:length(RunDatas)
    [avg_ads{j}, varied_var_values{j}] = avgRepeats(...
        RunDatas{j}, varied_variable_name, {plottedDensity, SD});
end

%%

cmap = colormap( jet( size(avg_atomdata{j}, 2) ) );

%%

setupPlotWrap( ...
    first_fig, ...
    options, ...
    RunDatas, ...
    figure_title_dependent_var, ...
    varied_variable_name, ...
    legendvars, ...
    varargin);
        
%%


end