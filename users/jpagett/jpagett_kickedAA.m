%% Get the Data

data_dir = 'G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_data_loading\Data';
% data_file = '09-Dec-2020_05-Jan-2021.mat';
% data_path = fullfile(data_dir,data_file);
% 
% if ~exist('DATA','var')
%     load( data_path );
%     DATA = Data; % rename this because I'm going to overwrite Data later.
% end

% answer = questdlg('Reload data?');
% 
% if ~isempty(answer)
%     if answer == "Yes"
%         [data_fname, data_fpath] = uigetfile( fullfile(data_dir,'*.mat'), 'Choose data.');
%         data_path = fullfile(data_fpath,data_fname);
%         load( data_path );
%         DATA = Data;
%     end
% else
%     disp('Aborted.');
%     return;
% end


%% Sort the Data

% answer = questdlg('Re-choose runs?');
% if answer == "Yes"
%     selectRuns(DATA);
%     pause; 
% end

%%

[varied_var, ...
 heldvars_each, ...
 heldvars_all, ...
 legendvars_each, ...
 legendvars_all] = unpackRunVars(RunVars);

%% Specify Output Directories

% analysis_output_dir = "G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_out\slowPhason_plots";
% analysis_output_dir = "G:\My Drive\_WeldLab\Code\_Analysis_Out\kickedaa\Vary915ModAmp";

output_start_dir = "G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_out";
analysis_output_dir = uigetdir(output_start_dir,...
    "Choose where to save the plots.");

if analysis_output_dir == 0
    disp('Aborting.');
    return;
end

% I want to put the expansion plots in their own subdirectory.
expansion_plot_dir = strcat( analysis_output_dir, filesep, "expansion_plots");
oort_plot_dir = strcat( analysis_output_dir, filesep, "oort_zoom_plots");

%% Now you can call your plotfunctions!

%% Stacked Expansion Plots 

plotted_density = 'summedODy';

clear('expansion_plot','expansion_plot_filename');
for j = 1:length(RunDatas)
    [expansion_plot{j}, expansion_plot_filename{j}] = stackedExpansionPlot(RunDatas{j},1,...
        varied_var,legendvars_each,heldvars_each,...
        'PlottedDensity',plotted_density,...
        'Position',[53, 18, 1655, 1153]);
end
saveFigure(expansion_plot, expansion_plot_filename, expansion_plot_dir, 'OpenDir', 1);

%% Width Evolution Plot

[width_evo_plot, width_evo_filename] = widthEvolutionPlot(RunDatas,...
    varied_var,legendvars_all,heldvars_all,...
    'WidthFraction',0.7,...
    'PlottedDensity','summedODy',...
    'yLim',[0,0],...
    'SmoothWindow',20,...
    'RemoveOutliersSD',1,...
    'SDplot',0);
saveFigure(width_evo_plot, width_evo_filename, analysis_output_dir, 'SaveFigFile', 1, 'OpenDir', 1);

%% Center Positions Plot Y

% % specify which density you want
% plotted_density = 'summedODy';
% 
% [centers_plot_y, centers_plot_filename_y] = ...
%     centersPlot(RunDatas,...
%     varied_var,legendvars_all,heldvars_all,...
%     'PlottedDensity',plotted_density,...
%     'yLim',[0 0],...
%     'SmoothWindow',10,...
%     'WidthFraction',0.55,...
%     'GaussFitCenter',1);
% saveFigure(centers_plot_y, centers_plot_filename_y, analysis_output_dir);
% 
% [centers_plot_y, centers_plot_filename_y] = ...
%     centersPlot(RunDatas,...
%     varied_var,legendvars_all,heldvars_all,...
%     'PlottedDensity',plotted_density,...
%     'yLim',[0 0],...
%     'SmoothWindow',10,...
%     'WidthFraction',0.55,...
%     'GaussFitCenter',0);
% saveFigure(centers_plot_y, centers_plot_filename_y, analysis_output_dir);

%% Center Positions Plot X

% specify which density you want
plotted_density = 'summedODx';

[centers_plot_x, centers_plot_filename_x] = ...
    centersPlot(RunDatas,...
    varied_var,legendvars_all,heldvars_all,...
    'PlottedDensity',plotted_density,...
    'yLim',[0 0],...
    'SmoothWindow',10,...
    'WidthFraction',0.55,...
    'GaussFitCenter',1);
saveFigure(centers_plot_x, centers_plot_filename_x, analysis_output_dir);

[centers_plot_x, centers_plot_filename_x] = ...
    centersPlot(RunDatas,...
    varied_var,legendvars_all,heldvars_all,...
    'PlottedDensity',plotted_density,...
    'yLim',[0 0],...
    'SmoothWindow',10,...
    'WidthFraction',0.55,...
    'GaussFitCenter',0);
saveFigure(centers_plot_x, centers_plot_filename_x, analysis_output_dir);

%% Oort Zoom Plot

plotted_density = 'summedODy';

clear('oort_zoom_plot','oort_filename');
for j = 1:length(RunDatas)
    [oort_zoom_plot{j}, oort_filename{j}] = oortZoomPlot(...
        RunDatas{j},...
        varied_var,...
        legendvars_each,...
        heldvars_each,...
        'xLim',[0 0],...
        'yLim',[-300 400],...
        'SmoothWindow',10,...
        'PlottedDensity',plotted_density,...
        'NumberShadowTraces',4);
end
saveFigure(oort_zoom_plot, oort_filename, oort_plot_dir);

%% Dual Gauss

%% Save the Figures

% This saveFigure function takes in the figure handle, filename, and the
% directory you'd like to save it in. Automatically handles filesep. Saves
% the figure with that filename to the specified path.
% saveFigure(expansion_plot, expansion_plot_filename, expansion_plot_dir);
% saveFigure(width_evo_plot, width_evo_filename, analysis_output_dir);
% saveFigure(centers_plot_y, centers_plot_filename_y, analysis_output_dir);
% saveFigure(centers_plot_x, centers_plot_filename_x, analysis_output_dir);
% saveFigure(oort_zoom_plot, oort_filename, oort_plot_dir);

%% Open the Ouput Directory
% Because I am lazy and don't want to navigate to the directory where the
% plots were saved.

if ispc
    winopen(analysis_output_dir);
end