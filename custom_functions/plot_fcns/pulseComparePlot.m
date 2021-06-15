function pulseComparePlot(RunDatas,RunVars,options)
% PULSECOMPAREPLOT(RunDatas,RunVars) (all-plot): Produces a plot comparing
% various dependent variables for different pulse types.

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

%% Camera Params

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
    [~,~,pixelsize,mag] = paramsfnc('ANDOR');
    xConvert = pixelsize/mag * 1e6;
    
%%

    list = {'summedODy','gauss
    
%%

    for ii = 1:length(RunDatas)
        [ad, varied_var_values] = avgRepeats( ...
            RunDatas{ii}, varied_variable_name,  );

%%


    [figure_title, figure_filename] = ...
        setupPlotWrap( ...
            expansion_plot, ...
            options, ...
            RunDatas, ...
            dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);

end