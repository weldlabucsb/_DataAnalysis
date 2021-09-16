function [ ] = dynaLocal(RunDatas,RunVars,options)
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

    
    vars_to_be_averaged = {'cloudSD_y','summedODy'};
    for j = 1:length(RunDatas)
        [avg_atomdata{j}, varied_var_values{j}] = avgRepeats(...
            RunDatas{j}, varied_variable_name, vars_to_be_averaged);
    end



    
    first_fig = figure(1);
    cmap = colormap( jet( length(RunDatas) ) );
    
    cutoff = 0.2;
    Jvals = zeros(length(RunDatas));
    for j = 1:length(RunDatas)
        
        [~,~,pixelsize,mag] = paramsfnc('ANDOR');
        xConvert = pixelsize/mag * 1e6; % convert from pixel to um
        
%         X{j} = ( 1:size( avg_atomdata{j}(1).summedODy, 2 ) ) * xConvert;
        
        
        for ii = 1:size(avg_atomdata{j}, 2)
            
            
            max_ratio = mean(abs(avg_atomdata{j}(ii).summedODy),'all')/max(abs(avg_atomdata{j}(ii).summedODy),[],'all');
            
            if (max_ratio > cutoff)||(avg_atomdata{j}(ii).cloudSD_y > 1)
                SDys{j}(ii) = NaN;
            else
                SDys{j}(ii) = avg_atomdata{j}(ii).cloudSD_y;
            end
            
        end
        
        if(0)%smooth data if you want
            SDys{j} = smoothdata(SDys{j});
        end
        
        %fit to linear expansion
        p{j} = polyfit(varied_var_values{j}(~isnan(SDys{j})), SDys{j}(~isnan(SDys{j})),1);
        %get the slope
        Jvals(j) = p{j}(1);
%         fracWidths{j} = smoothdata(fracWidths{j});
%         fracWidthsvec = [fracWidthsvec fracWidths{j}];
    end

    %%% End Data Manipulation %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Then plot things, just looping over the values I computed above.
    figure(1); clf;
    figure_title_dependent_var = ['Cloud SD y vs latt hold'];
    hold on;
    for j = 1:length(RunDatas)
        plot( varied_var_values{j}, SDys{j}, 'x-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
        
        if(1) %plot the linear fit
            plot(varied_var_values{j}(~isnan(SDys{j})), polyval(p{j},varied_var_values{j}(~isnan(SDys{j}))),'-',...
                'LineWidth', options.LineWidth,...
                'Color',cmap(j,:));
        end
    end
    hold off;
    
    %now to plot J values
    freqs = zeros(length(RunDatas));
    amps = zeros(length(RunDatas));
    %note I wanted to find a way to do the below without a for loop, but
    %the only way I've found so far is a big memory user:
    %ye = [RunDatas{:}]; ye = [ye.vars]; freqs = ye.LatticeModFreq;
    %since I can't do RunDatas{:}.vars.LatticeModFreq which is really what
    %I want. But oh well. A for loop is probably better than the above.
    for j = 1:length(RunDatas)
        freqs(j) = RunDatas{j}.vars.LatticeModFreq;
        amps(j) = RunDatas{j}.vars.PiezoAmp;
    end
    
    %note that freqs below could be gotten from the RunDataLib, but I just
    %don't want to pass it as an argument (it would be huge), so I just
    %define it manually here.
    freqVals = [500;750;1000];
    figure(2); clf;
    hold on;
    for j = 1:3
        plot( amps(freqs==freqVals(j)), Jvals(freqs==freqVals(j)), '.',...
            'LineWidth', options.LineWidth,'markersize',20);
    end
    hold off;
            xlabel('Piezo Amplitude','fontsize',12);
        ylabel('$\frac{d \sigma_{y}}{dt} \propto J_{eff}$','fontsize',30,'interpreter','latex')
        title({'Effective J Value vs Piezo Amplitude'},'fontsize',15,'interpreter','latex');
    legend(string(freqVals));
    
    for j = 1:3
        figure(j+2); clf;
        
        plot( amps(freqs==freqVals(j)), Jvals(freqs==freqVals(j)), '.',...
            'LineWidth', options.LineWidth,'markersize',20);
        xlabel('Piezo Amplitude','fontsize',12);
        ylabel('$\frac{d \sigma_{y}}{dt} \propto J_{eff}$','fontsize',30,'interpreter','latex')
        title({'Effective J Value vs Piezo Amplitude', ['freq =  ' num2str(freqVals(j)) 'Hz']},'fontsize',15,'interpreter','latex');
    end
    
    for j = 1:3
        figure(j+2); clf;
        xs = amps(freqs==freqVals(j));
        ys = Jvals(freqs==freqVals(j));
        
        plot(xs(xs < 2.5) , ys(xs < 2.5), '.',...
            'LineWidth', options.LineWidth,'markersize',20);
        xlabel('Piezo Amplitude','fontsize',12);
        ylabel('$\frac{d \sigma_{y}}{dt} \propto J_{eff}$','fontsize',30,'interpreter','latex')
        title({'Effective J Value vs Piezo Amplitude', ['freq =  ' num2str(freqVals(j)) 'Hz']},'fontsize',15,'interpreter','latex');
    end

    
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

end
