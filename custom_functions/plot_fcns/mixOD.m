function [figH, fig_filename, plot_title] = mixOD(RunData,RunVars,options)
% MIXOD(RunData,RunVars) takes in a single RunData, and outputs a figure of
% a mixOD wrt RunVars.varied_var

arguments
    RunData
    RunVars
end
arguments
    options.FontSize = 16
    options.Position = [237, 259, 1140, 840]; % window open position
    options.TitleFontSize = 16;
    options.TickLabelFontSize = 12;
    options.yLim = [100,350]; %  
    options.WidthCropOD = 25; % remove this much from either side (horizontally) of the OD
    options.HeightCropOD = 150; % removes this much from either side (vertically) of the OD
    options.ShiftYPixels = 20;
    options.ShiftXPixels = 10;
    options.WrapPlot = 1 % toggles dressing up the plot all nice
    options.FigureHandle = [] % optionally, specify an existing figure handle
    options.Interpreter = 'latex'
    options.PlotEvery = 1
end

    [avgOD, var_vars] = avgRepeats(RunData,RunVars.varied_var,{'OD'});
    
    for ii = 1:length(avgOD)
       idx(ii) = ~mod(ii-1,options.PlotEvery);
    end
    
    avgOD = avgOD(idx);
    var_vars = var_vars(idx);
    
    w = size([avgOD(1).OD],2);
    h = size([avgOD(1).OD],1);
    
    N = length(avgOD);
    
    x_tick_positions = [];
    OD = [];
    
    leftside = options.WidthCropOD;
    rightside = w - options.WidthCropOD;
    wCropped = rightside - leftside + 1;
    ODx_range = leftside:rightside;
    
    topside = options.HeightCropOD;
    botside = h - options.HeightCropOD;
    hCropped = botside - topside;
    ODy_range = topside:botside + options.ShiftYPixels;
    
    for ii = 1:N
       x_tick_positions(ii) = 1 + (wCropped)/2 + (wCropped) * (ii - 1) ;
       x_tick_label{ii} = num2str(var_vars(ii));
       
       thisOD = [avgOD(ii).OD];
       OD = [OD, [thisOD(ODy_range,ODx_range)] ];
    end

    if isempty(options.FigureHandle)
        figH = figure();
    else
        figH = options.FigureHandle;
    end
    
    imagesc(OD);
    colormap(jet);

%     options.PlotTitle = "MixOD";
    
    if options.WrapPlot
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
                figH, ...
                options, ...
                RunData, ...
                'MixOD', ...
                RunVars.varied_var, ...
                [], ...
                RunVars.heldvars_each);
    else
        plot_title = plotTitle(RunData,'MixOD',RunVars.varied_var,RunVars.heldvars_each);
    end
            
    ax = gca;
    
    ax.XTick = x_tick_positions;
    ax.XTickLabel = x_tick_label;
    ax.FontSize = options.TickLabelFontSize;
    
    ax.YTickLabel = "";
    
    xlabel(RunVars.varied_var,...
        'FontSize',options.FontSize);
    
%     set(gca,'YTickLabel',[]);
   
end