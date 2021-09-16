function [fig_handle, fig_filename] = QCQKR_fwhm_plot(RunDatas,varied_variable_name,legendvars,varargin,options)
% PLOTFUNCTIONTEMPLATE makes a plot from the given RunDatas against the
% dependent variable {varied_variable_name}. Optional arguments are passed
% to setupPlot, which automatically puts axes and a legend on the plot,
% resizes the axes, etc.
% 
%         I recommend starting out by not touching the optional arguments.
%
% The RunDatas input can either be a single RunData object, or a cell array
% of RunData objects.
%
% varied_variable_name is the cicero variable name (as a string) of the
% independent variable for the RunDatas you've provided.
%
% legendvars must be specified as a cell array of strings. The names of
% the variables are used as the title of the legend, and their values for
% each plotted RunData are added to the legend.
%
% varargin can be provided as a cell array of cicero variable names which
% are held constant across ALL RunDatas provided in the set. These
% variables (and their values) are added to the plot title. 
%
%       For variables held constant in just one RunData out of the provided
%       set (such as the 915 depth when plotting widths of many runs vs.
%       time on the same axes), specify those variables in legendvars so
%       that the runs will be labeled in the legend.

arguments
    RunDatas
    varied_variable_name
    legendvars
end
arguments (Repeating)
    varargin
end
arguments
    options.LineWidth (1,1) double = 1.5
    %
    options.yLabel string = ""
    options.yUnits string = ""
    %
    options.xLabel string = varied_variable_name
    options.xUnits string = ""
    %
    options.FontSize (1,1) double = 20
    options.LegendFontSize (1,1) double = 16
    options.TitleFontSize (1,1) double = 20
    %
    options.Interpreter (1,1) string = "latex" % alt: 'none', 'tex'
    %
    options.LegendLabels = [] % leave as is if you want auto-labels
    options.LegendTitle string = "" % leave as is if you want auto-title
    options.Position (1,4) double = [461, 327, 420, 463];
    %
    options.PlotTitle = "" % leave as is if you want auto-title
    %
    options.xLim (1,2) double = [0,0] % leave as [0, 0] to NOT set limits
    options.yLim (1,2) double = [0,0] % leave as [0, 0] to NOT set limits
    %
    options.PlotPadding = 0;
end

% [varied_var, ...
%  heldvars_each, ...
%  heldvars_all, ...
%  legendvars_each, ...
%  legendvars_all] = unpackRunVars(RunVars);

    % Use avgRepeats on your RunDatas to extract repeat-averaged values of
    % whichever cicero variables (vars_to_be_averaged) you want to work
    % with. Here I wanted those values associated with each RunData
    % individually, so I looped over the RunDatas and repeat-averaged each
    % one.
    
    vars_to_be_averaged = {'summedODy','RawMaxPeak3Density'};
    for j = 1:length(RunDatas)
        [avg_atomdata{j}, varied_var_values{j}] = avgRepeats(...
            RunDatas{j}, varied_variable_name, vars_to_be_averaged);
    end

    % Work is in progress to make it easier to repeat-average subsets of
    % RunDatas while only repeat-averaging other individual RunDatas.
    %
    % The output, avg_atomdata will be a struct which will have fields of
    % the averaged values. I recommend you look at how this is structured
    % before writing the rest of the plot function.
    
    % You could also feed avgRepeats a cell array of RunDatas, as done
    % below. If you do, it will try to repeat-average all of them together.
    % Careful here -- I haven't put in error messages for if you feed it
    % RunDatas that shouldn't be repeat-averaged, and will yield unexpected
    % results. Better handling is in development.
    
%     vars_to_be_averaged = {'summedODy'};
%         [avg_atomdata, varied_var_values{1}] = avgRepeats(...
%             RunDatas, varied_variable_name, vars_to_be_averaged);
        
    % Obviously I would not do both of the above. They are applicable in
    % different cases.
    
    % Now that you have the repeat-averaged values for each RunData (or for
    % the averaged set, if you averaged all of them together), you can
    % compute and plot whichever quantities you want to plot.
    %
    % The output of plotFunctions should include a figure handle and a
    % filename to which the figure can be saved. Define the handle when you
    % make the figure. The filename will be generated later.
    %
    % I also define a colormap here to get good contrast between the
    % different traces (with default, more than 5 traces will start
    % repeating colors).
    
    fig_handle = figure(1);
    cmap = colormap( jet( length(RunDatas) ) );
    
    % I also typically define here the dependent variable string that will
    % appear in my plot title. "vs. {varied_variable_name}" will be
    % appended. As an example, I'll use the specific case of plotting the
    % fractional widths based on the summedODy:
    
    
    
    % As an example of doing things with the repeat-averaged output, here I
    % use the averaged atomdata to compute the fractional widths of each
    % RunData. To get these, I used the first option above, and just
    % repeat-averaged each set within itself.
    
    cutoff = 0.2;
    frac = 0.55;
    for j = 1:length(RunDatas)
        
        % Here I compute each fracWidth from the repeat-averaged densities
        % for the iith entry in each RunData, which are stored in
        % avg_atomdata{j}(ii).summedODy
        [~,~,pixelsize,mag] = paramsfnc('ANDOR');
        xConvert = pixelsize/mag * 1e6; % convert from pixel to um
        
        X{j} = ( 1:size( avg_atomdata{j}(1).summedODy, 2 ) ) * xConvert;
        
        for ii = 1:size(avg_atomdata{j}, 2)
            %find the center information
            max_ratio{j}(ii) = mean(abs(avg_atomdata{j}(ii).summedODy),'all')/max(abs(avg_atomdata{j}(ii).summedODy),[],'all');
            [width, center] = fracWidth( X{j}, avg_atomdata{j}(ii).summedODy, frac);
            if max_ratio{j}(ii) > cutoff
                fracWidths{j}(ii) = NaN;
            else
                fracWidths{j}(ii) = width;
            end
            x2FromCen{j} = (X{j} - center).^2;
            rms{j}(ii) = sqrt(trapz(x2FromCen{j}.*(avg_atomdata{j}(ii).summedODy./norm(avg_atomdata{j}(ii).summedODy)).^2));
            peak_density{j}(ii) = avg_atomdata{j}(ii).RawMaxPeak3Density;
            
        end
    end
    %%% End Data Manipulation %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Add a data interpolation to identify localization transition
    interp_points = linspace(0,5,100);
    smoth_method = 'movmean';
    for j = 1:length(RunDatas)
        fracWidths_interp{j} = interp1(varied_var_values{j},smoothdata(fracWidths{j},smoth_method),interp_points,'linear');
    end
    
    % Then plot things, just looping over the values I computed above.
    
    figure_title_dependent_var = ['width at ' num2str(frac) ' maximum (summedODy, au)'];
    for j = 1:length(RunDatas)
        plot( varied_var_values{j}, fracWidths{j}, 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
        hold on;
    end
    hold off;
    
    sec_fig = figure(2);
    sec_figure_title_dependent_var = 'peak density ratio';
    hold on;
    for j = 1:length(RunDatas)
        plot( varied_var_values{j}, max_ratio{j}, 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
    end
    plot(varied_var_values{1},cutoff.*ones(length(varied_var_values{1}),1),'k-',...
        'LineWidth',4);
    hold off;
    
    third_fig = figure(3);
    third_figure_title_dependent_var = ['Interpolated width at ' num2str(frac) ' maximum (summedODy, au)'];
    hold on;
    for j = 1:length(RunDatas)
        plot(interp_points, fracWidths_interp{j}, '-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
    end
%     ylim([0,160]);
    hold off;
    
    
    fourth_fig = figure(4);
    fourth_figure_title_dependent_var = ['Derivative of Width'];
    hold on;
    for j = 1:length(RunDatas)
        plot(interp_points(1:length(interp_points)-1),smoothdata(diff(fracWidths_interp{j})), '-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
    end
%     ylim([0,160]);
    hold off;
    
    % Finally, to take advantage of a lot of the automation I've built
    % around the RunData objects, you need to copy-paste the following. You
    % shouldn't have to change anything here, unless (obviously) you used
    % different variable names for the figure_title_dependent_var or
    % fig_handle.
    options.yLabel = figure_title_dependent_var;
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            fig_handle, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        options.yLabel = sec_figure_title_dependent_var;
        [plot_title2, fig_filename2] = ...
        setupPlotWrap( ...
            sec_fig, ...
            options, ...
            RunDatas, ...
            sec_figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
    
        
        options.yLabel = third_figure_title_dependent_var;
        [plot_title2, fig_filename2] = ...
        setupPlotWrap( ...
            third_fig, ...
            options, ...
            RunDatas, ...
            third_figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
        options.yLabel = fourth_figure_title_dependent_var;
        [plot_title2, fig_filename2] = ...
        setupPlotWrap( ...
            fourth_fig, ...
            options, ...
            RunDatas, ...
            fourth_figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
    % Note that the setupPlot function outputs a figure filename to be used
    % when saving the figure. It will include the run numbers, dates, and
    % the independent variable and held variable names/values.
    
end