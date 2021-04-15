function [plot_title, figure_filename, legend_labels] = setupPlot(figure_handle, RunDatas, plotted_dependent_var, varied_variable_name, legendvars, varargin, options)
% SETUPPLOT sets axes labels, title, legend, etc. Also outputs the plot
% title and a figure filename (containing the same information as the plot
% title), for use in saving figures.
%
% SETUPPLOT will use default values from RunData if optional arguments are
% not given.
%
% legendvars must be specified as a cell array of strings. The names of
% the variables are used as the title of the legend, and their values for
% each plotted RunData are added to the legend.
%
% varargin can be used for any number of variables held constant that you
% want included in a pre-generated title. Does nothing if PlotTitle option
% is specified.
%
% SETUPPLOT optional arguments:
% yLabel, yUnits, xLabel, xUnits ( strings )
% FontSize, LegendFontSize, TitleFontSize ( doubles )
% Interpreter (ex: 'latex', 'none')
% LegendLabels (list of values)
% LegendTitle (string to title the legend)
% Position ( (1,4) double )
% PlotTitle (default: plotTitle(...))
% PlotPadding ( adds [-1,1]*PlotPadding to x,ylims IFF xlims, ylims
% specified )

arguments
    figure_handle matlab.ui.Figure
    RunDatas
    plotted_dependent_var string
    varied_variable_name string
    legendvars cell
end
arguments (Repeating)
    varargin
end
arguments
    options.yLabel string = plotted_dependent_var
    options.yUnits string = ""
    %
    options.xLabel string = ""
    options.xUnits string = ""
    %
    options.FontSize (1,1) double = 20
    options.LegendFontSize (1,1) double = 16
    options.TitleFontSize (1,1) double = 20
    %
    options.Interpreter (1,1) string = "latex"
    %
    options.LegendLabels = []
    options.PlotEvery (1,1) double = 1
    options.LegendTitle string = ""
    options.Position (1,4) double = [0, 0, 1280, 720];
    %
    options.PlotTitle = ""
    %
    options.xLim (1,2) double = [0,0]
    options.yLim (1,2) double = [0,0]
    %
    options.PlotPadding = 0;
    %
    options.SubplotTitle = 0;
    options.SkipLegend = 0;
    options.SkipLabels = 0;
end

%% VargHandling

try
    if ~isempty(varargin)
        pass_vargs = varargin{1}{1};
    else
        pass_vargs = {};
    end
catch
    pass_vargs = {};
end

RunDatas = cellWrap(RunDatas);

%% Make the specified figure_handle active

figure(figure_handle);

%% Title

if options.PlotTitle == ""
    plot_title = plotTitle(RunDatas,plotted_dependent_var,varied_variable_name,pass_vargs);
else
    plot_title = options.PlotTitle;
end

figure_filename = filenameFromPlotTitle(plot_title);

%% Parsing

% set y label (add units if specified)
if options.yUnits == ""
    yLabel = options.yLabel;
else
    yLabel = strcat( options.yLabel, " ", options.yUnits );
end

% set x label (add units if specified)
if options.xUnits == ""
    xLabel = options.xLabel;
else
    xLabel = strcat( options.xLabel, " ", options.xUnits );
end

%% Plot Legend

if ~options.SkipLegend

    % If LegendTitle not specified manually, generate from list of legend
    % variables
    if options.LegendTitle == ""
        titleLegendVars = varAlias(legendvars);
        options.LegendTitle = strrep(strjoin(titleLegendVars,", "),'_','');
    end

    % If LegendLabels were not specified manually, generate them from the list
    % of legend variables.
    if isempty(options.LegendLabels) && ~isempty(legendvars)
        labels = makeLegendLabels(RunDatas, varied_variable_name, legendvars, options.PlotEvery);
    else
%         labels = string(cellfun( @(x) x.RunNumber, RunDatas, 'UniformOutput', false));
        labels = options.LegendLabels;
    end

    options.LegendLabels = labels;
    legend_labels = labels; % nicely labeled as an output of the function

    if class(options.LegendLabels) == "string" || class(options.LegendLabels) == "char"
        % Legend Labeling
        lgd = legend( options.LegendLabels , ...
            'FontSize',options.LegendFontSize,...
            'Interpreter',options.Interpreter);
        LegendTitle = strrep(options.LegendTitle,'_','');
        title(lgd,LegendTitle,'FontSize',options.LegendFontSize);
    end

else
    
    legend_labels = [];
    
end

%% Plot Labeling

% Title, Axes Labeling
if ~options.SubplotTitle
   title(plot_title,'FontSize',options.TitleFontSize,'Interpreter',options.Interpreter);
elseif options.SubplotTitle
   sgtitle(plot_title,'FontSize',options.TitleFontSize,'Interpreter',options.Interpreter);
end

if ~options.SkipLabels
    ylabel(fix(options.yLabel),'FontSize',options.FontSize,'Interpreter',options.Interpreter);
    xlabel(fix(options.xLabel),'FontSize',options.FontSize,'Interpreter',options.Interpreter);
end

% Axes Handling
if any(options.xLim ~= [0 0])
    options.xLim = options.xLim + [-1,1]*options.PlotPadding;
    xlim([options.xLim]);
end

if any(options.yLim ~= [0 0])
    options.yLim = options.yLim + [-1,1]*options.PlotPadding;
    ylim([options.yLim]);
end

% Resizing
set(figure_handle,'Position',options.Position);

    function out = fix(in)
        out = strrep(in,'_','');
    end

end