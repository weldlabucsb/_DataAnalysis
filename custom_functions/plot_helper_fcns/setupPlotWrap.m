function [plot_title, figure_filename, legend_labels] = setupPlotWrap(figure_handle, options_struct, RunDatas, dependent_var, varied_variable_name, legendvars, varargin)
% SETUPPLOTWRAP provides a compact way to feed options from a plot function
% into setupPlot. The options_struct argument should just be the entire
% options struct of the plot function.

arguments
    figure_handle
    options_struct struct
    RunDatas
    dependent_var string
    varied_variable_name string
    legendvars cell
end
arguments (Repeating)
    varargin
end

    varargin = varargin{1};
    options = options_struct;
    
    options = replaceMissingOptions(options);
    
    [plot_title, figure_filename, legend_labels] = setupPlot( figure_handle, RunDatas, ...
        dependent_var, ...
        varied_variable_name, ...
        legendvars, ...
        varargin, ...
        'yLabel', options.yLabel, ...
        'yUnits', options.yUnits, ...
        'xLabel', options.xLabel,...
        'xUnits', options.xUnits,...
        'FontSize', options.FontSize, ...
        'LegendLabels', options.LegendLabels, ...
        'PlotEvery',options.PlotEvery, ...
        'LegendFontSize', options.LegendFontSize,...
        'LegendTitle',options.LegendTitle,...
        'TitleFontSize',options.TitleFontSize,...
        'PlotPadding', options.PlotPadding,...
        'Position', options.Position,...
        'PlotTitle', options.PlotTitle,...
        'yLim',options.yLim,...
        'xLim',options.xLim,...
        'SubplotTitle',options.SubplotTitle,...
        'SkipLegend',options.SkipLegend,...
        'SkipLabels',options.SkipLabels,...
        'Interpreter',options.Interpreter);
    
end

%% Default Values (if not specified)
function options = replaceMissingOptions(options)
    if ~isfield(options,'LineWidth')
        options.LineWidth = 1;
    end
    if ~isfield(options,'PlotEvery')
        options.PlotEvery = 1;
    end
    if ~isfield(options,'FontSize')
        options.FontSize = 20;
    end
    if ~isfield(options,'LegendFontSize')
        options.LegendFontSize = 16;
    end
    if ~isfield(options,'TitleFontSize')
        options.TitleFontSize = 20;
    end
    if ~isfield(options,'Interpreter')
        options.Interpreter = "latex";
    end
    if ~isfield(options,'LegendLabels')
        options.LegendLabels = [];
    end
    if ~isfield(options,'Position')
        options.Position = [0 0 100 100];
    end
    if ~isfield(options,'PlotTitle')
        options.PlotTitle = "";
    end
    if ~isfield(options,'xLim')
        options.xLim = [0 0];
    end
    if ~isfield(options,'yLim')
        options.yLim = [0 0];
    end
    if ~isfield(options,'PlotPadding')
        options.PlotPadding = 0;
    end
    if ~isfield(options,'SubplotTitle')
       options.SubplotTitle = 0; 
    end
    if ~isfield(options,'SkipLegend')
       options.SkipLegend = 0;
    end
    if ~isfield(options,'SkipLabels')
        options.SkipLabels = 0;
    end
    if ~isfield(options,'yLabel')
        options.yLabel = "";
    end
    if ~isfield(options,'xLabel')
        options.xLabel = "";
    end
    if ~isfield(options,'yUnits')
        options.yUnits = "";
    end
    if ~isfield(options,'xUnits')
        options.xUnits = "";
    end
    if ~isfield(options,'LegendTitle')
        options.LegendTitle = "";
    end
    if ~isfield(options,'LegendTitle')
        options.PlotTitle = "";
    end
end