function [figH, fig_filename] = mixOD(RunData,RunVars,options)
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
    options.yLim = [100,350]; %  
    options.WidthCropOD = 40; % remove this much from either side (horizontally) of the OD
end

    [avgOD, var_vars] = avgRepeats(RunData,RunVars.varied_var,{'OD'});
    
    w = size([avgOD(1).OD],2);
    h = size([avgOD(1).OD],1);
    
    N = length(avgOD);
    
    x_tick_positions = [];
    OD = [];
    
    leftside = options.WidthCropOD;
    rightside = w - options.WidthCropOD;
    wCropped = rightside - leftside;
    ODx_range = leftside:rightside;
    
    for ii = 1:N
       x_tick_positions(ii) = 1 + wCropped/2 + wCropped * (ii - 1);
       x_tick_label{ii} = num2str(var_vars(ii));
       
       thisOD = [avgOD(ii).OD];
       OD = [OD, [thisOD(:,ODx_range)] ];
    end

    figH = figure();
    
    imagesc(OD);
    colormap(jet);

%     options.PlotTitle = "MixOD";
    
    [~, fig_filename] = ...
        setupPlotWrap( ...
                figH, ...
                options, ...
                RunData, ...
                'MixOD', ...
                RunVars.varied_var, ...
                [], ...
                RunVars.heldvars_each);
            
    ax = gca;
    
    ax.XTick = x_tick_positions;
    ax.XTickLabel = x_tick_label;
    
    xlabel(RunVars.varied_var,...
        'FontSize',options.FontSize);
    
%     set(gca,'YTickLabel',[]);
   
end