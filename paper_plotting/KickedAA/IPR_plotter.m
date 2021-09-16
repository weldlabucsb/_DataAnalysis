function [fig_handle, fig_filename] = IPR_plotter(RunDatas,RunVars,options)
% PLOTFUNCTIONTEMPLATE makes a plot from the given RunDatas against the
% dependent variable {varied_variable_name}. Optional arguments are passed
% to setupPlot, which automatically puts axes and a legend on the plot,
% resizes the axes, etc.
% 


%%%%%Note %%%%%%%%%%
%unlike the rest of the functions I made this one work so that just RunVars
%is an input to avoid having to do unpackRunVars



arguments
    RunDatas
    RunVars
end
arguments
    options.LineWidth (1,1) double = 1.5
    %
    options.yLabel string = ""
    options.yUnits string = ""
    %
    options.xLabel string = RunVars.varied_var;
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
varied_variable_name = RunVars.varied_var;
legendvars = RunVars.heldvars_each;
varargin = {RunVars.heldvars_all};
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
            norm_distr = (avg_atomdata{j}(ii).summedODy)./norm(avg_atomdata{j}(ii).summedODy);
            
            norm_wavefunc = (avg_atomdata{j}(ii).summedODy)./norm(avg_atomdata{j}(ii).summedODy,1);
            
            
            max_ratio{j}(ii) = mean(abs(avg_atomdata{j}(ii).summedODy),'all')/max(abs(avg_atomdata{j}(ii).summedODy),[],'all');
%             [width, center] = fracWidth( X{j}, avg_atomdata{j}(ii).summedODy, frac);
            if max_ratio{j}(ii) > cutoff
                IPR{j}(ii) = NaN;
            else
                IPR{j}(ii) = sum(abs(norm_distr).^4);
            end
            IPR_nosort{j}(ii) = sum(abs(norm_wavefunc).^2);
            
        end
    end
    %%% End Data Manipulation %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    interp_points = linspace(0,5,100);
    for j = 1:length(RunDatas)
        IPR_interp{j} = interp1(varied_var_values{j},smoothdata(IPR_nosort{j}),interp_points,'linear');
    end
    
    % Then plot things, just looping over the values I computed above.
    
    figure_title_dependent_var = ['IPR ($\sum | \psi(x)|^4$)'];
    first_fig = figure(1);
    for j = 1:length(RunDatas)
        plot( varied_var_values{j}, smoothdata(IPR{j}), 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
        hold on;
    end
    hold off;
    
    secfigure_title_dependent_var = ['IPR ($\sum | \psi(x)|^4$)'];
    sec_fig = figure(2);
    for j = 1:length(RunDatas)
        plot( varied_var_values{j}, smoothdata(IPR_nosort{j}), 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
        hold on;
    end
    hold off;
    
        thirdfigure_title_dependent_var = ['IPR ($\sum | \psi(x)|^4$)'];
    third_fig = figure(3);
    for j = 1:length(RunDatas)
        plot(interp_points, IPR_interp{j}, '-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
        hold on;
    end
    hold off;
    
    options.yLabel = figure_title_dependent_var;
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            first_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
    options.yLabel = secfigure_title_dependent_var;
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            sec_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
    options.yLabel = thirdfigure_title_dependent_var;
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            third_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
    
end