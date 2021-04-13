function [Y1,Y2] = dualGaussTrimFit(x, y, options)

    arguments
        x double
        y double
    end
    arguments
        options.PlotFit logical = 0
        options.Excluded double = []
        options.ExcludeDomain logical = 0
        options.WidthFraction double = 0.65
        options.peakROI = []
        options.MaximumAmplitude (1,1) double = Inf
        options.LineWidth = 1.5
%         options.NarrowAmplitudeGuess = []
%         options.NarrowSigmaGuess = []
%         options.NarrowOffsetGuess = []
        
    end
    
    excluded = options.Excluded;
    widthFraction = options.WidthFraction;
    plotFit = options.PlotFit;
    
%     if ~isempty(options.NarrowAmplitudeGuess)
%         ampGuess = options.NarrowAmplitudeGuess;
%     end
%     
%     if ~isempty(options.NarrowSigmaGuess)
%        sigmaGuess = options.NarrowSigmaGuess; 
%     end
%     
%     if ~isempty(options.NarrowOffsetGuess)
%         offsetGuess = options.NarrowOffsetGuess;
%     end
%     
%     if ~isempty(options.NarrowCenterGuess)
%         
%     end

    %% First Fit
    [xData, yData] = prepareCurveData( x, y );
    
    if ~isempty(options.peakROI)
        
        roiPos = options.peakROI;
        
        roi_x = [roiPos(1), roiPos(1) + roiPos(3)];
        roi_y = [roiPos(2), roiPos(2) + roiPos(4)];
        
        ampGuess = roi_y(2) - roi_y(1);
        centerGuess = ( roi_x(2) + roi_x(1) ) / 2;
        sigmaGuess = roi_x(2) - roi_x(1);
        offsetGuess = roi_y(1);
    end
    
    if ~isempty(options.peakROI)
        excludedPoints = ~excludedata(xData, yData, 'domain', roi_x);  
    else
        excludedPoints = ~excludedata( xData, yData, 'domain', excluded );
    end
    
    if isempty(options.peakROI)
        ampGuess = max(y(~excludedPoints));
        offsetGuess = min(y(~excludedPoints));

        [sigmaGuess, centerGuess] = ...
            fracWidth(x(~excludedPoints),y(~excludedPoints),widthFraction);
    end
    
    if options.ExcludeDomain
        excludedPoints = ~excludedPoints;
    end

    % Set up fittype and options.
    ft = fittype( 'A1 * exp( - (x - x1)^2/(2*sigma1^2) ) + c1', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 -Inf 0 -Inf];
    opts.Upper = [options.MaximumAmplitude Inf Inf Inf];
    opts.Robust = 'Bisquare';
    opts.StartPoint = [ampGuess offsetGuess sigmaGuess centerGuess];
    opts.Exclude = excludedPoints;

    % Fit model to data.
    [Y1, ~] = fit( xData, yData, ft, opts );
    
    if options.PlotFit
        h = plot( Y1, xData, yData, 'LineWidth', options.LineWidth);
    end

    %% Second Fit
    
    first_fit = Y1(x);
    y = y - first_fit';
    
    [xData, yData] = prepareCurveData( x, y );
    
    excludedPoints = ~excludedPoints;
    
    ampGuess = max(y(~excludedPoints));
    
    [sigmaGuess, centerGuess] = ...
        fracWidth(x(~excludedPoints),y(~excludedPoints),widthFraction);
    
    if sigmaGuess > 300
        ampGuess = 0;
        sigmaGuess = Inf;
    end

    % Set up fittype and options.
    ft = fittype( 'A2 * exp( - (x - x2)^2/(2*sigma2^2) )', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [ampGuess sigmaGuess centerGuess];
    opts.Lower = [0 -Inf 0];
    opts.Upper = [options.MaximumAmplitude Inf Inf];
    opts.Robust = 'Bisquare';
    opts.Exclude = excludedPoints;

    % Fit model to data.
    [Y2, ~] = fit( xData, yData, ft, opts );
    
%     if options.PlotFit
%         hold on
%         h2 = plot( x, Y2(x) + Y1.d1 );
% 
%         Yp = Y1(x) + Y2(x);
%         plot( x, Yp , 'LineWidth', 2, 'Color', 'k');
% 
%         hold off
%     end
  
end


