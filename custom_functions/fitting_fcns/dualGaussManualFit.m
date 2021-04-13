function [Y, Y1, Y2, roiRect] = dualGaussManualFit(x,y,options)
% BIMODAL_FIT returns two fit objects (Y1 and Y2). Y1's starting parameters
% are specified by a user-drawn rectangle.
%
% The peak selected by the user-specified ROI:
% amplitude = Y1.A1
% std dev = Y1.sigma1
% mean = Y1.x1.
% vertical offset = Y1.c
%
% The other gaussian:
% amplitude = Y2.A2
% std dev = Y2.sigma2
% mean = Y2.x2.
%
% Y is the sum of the fits Y1 and Y2.

    arguments
        x double
        y double
    end
    arguments
        options.PeakFraction1 (1,1) double = 0.96
        options.PeakFraction2 (1,1) double = 0.05
        options.PlotFit (1,1) logical = 1
        options.PlotComponents (1,1) logical = 0
        options.OriginalFigureHandle = []
        options.MaximumAmplitude (1,1) double = 10000
        options.FitRects = [];
        options.LineWidth = 1.5;
    end
    
    if ~isempty(options.OriginalFigureHandle)
        h = options.OriginalFigureHandle;
        tag = true;
    end
    
    %% User-specified guesses
    
    if isempty(options.FitRects)
        % ask user for estimate of the peak width, height
        thisfig = figure();
        plot(x,y,'LineWidth',1.5);
        roi = drawrectangle();
        roiRect = roi.Position;
    else
        roiRect = options.FitRects;
    end
    
    %% Fit first peak
    
    [Y1,Y2] = dualGaussTrimFit(x, y,...
        'peakROI', roiRect, ...
        'MaximumAmplitude', options.MaximumAmplitude);
    
    Y1p = Y1.A1 * exp( - ( (x - Y1.x1)./Y1.sigma1 ).^2 / 2 );
    Y2p = Y2.A2 * exp( - ( (x - Y2.x2)./Y2.sigma2 ).^2 / 2 );
    
    Y = Y1p + Y2p + Y1.c1;
       
    %% Plotting
    
    if isempty(options.FitRects)
        close(thisfig);
    end
    
    if tag
        figure(h);  
    end
    
    if options.PlotFit
        hold on
        plot(x,Y,':','Color',[5 5 5]/255,'LineWidth',options.LineWidth);
        if options.PlotComponents
            plot(x,Y1,'-.','Color',[50 50 50]/255,'LineWidth',options.LineWidth);
            plot(x,Y2,'-.','Color',[80 80 80]/255,'LineWidth',options.LineWidth);
        end
        hold off
    end

end