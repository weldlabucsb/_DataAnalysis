function [Y, Y2] = isolate_oort(x, y, options)

    arguments
        x double
        y double
    end
    arguments
        options.PlotFit logical = 0
        options.PlotConcavity logical = 0
        options.Excluded double = []
%         options.ExcludeDomain logical = 0
        options.WidthFraction double = 0.8
        options.MinPeakDistance double = 10
        options.MinPeakHeightFraction double = 1/2
        options.EdgeFudge double = 2
    end
    
    fudge = options.EdgeFudge;
    widthFraction = options.WidthFraction;
    plotFit = options.PlotFit;
    excludedPoints = options.Excluded;

    %% Determine Edges
    
    dydx = gradient(y)./gradient(x);
    
    dydx2 = gradient(dydx) ./ gradient(x);
    
    if options.PlotConcavity
       plot( x, dydx2 , 'Color', 'k', 'LineWidth', 1);
    end
     
    [~,edges,~,~] = ...
        findpeaks( dydx2, x, ...
        'MinPeakHeight', max(dydx2) * options.MinPeakHeightFraction , ...
        'MinPeakDistance', options.MinPeakDistance );
    
    edges = [min(edges), max(edges)];
    
    %% Second Fit
    
    [xData, yData] = prepareCurveData( x, y );
    
    excluded = edges + fudge*[1,-1];
    
    excludedPoints = ~excludedPoints;
    
    ampGuess = max(y(~excludedPoints));
    
    [sigmaGuess, centerGuess] = ...
        fracWidth(x(~excludedPoints),y(~excludedPoints),widthFraction);

    % Set up fittype and options.
    ft = fittype( 'A2 * exp( - (x - x2)^2/(2*sigma2^2) )', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [ampGuess sigmaGuess centerGuess];
    opts.Lower = [0 -Inf 0];
    opts.Upper = [Inf Inf Inf];
    opts.Robust = 'Bisquare';
    opts.Exclude = excludedPoints;

    % Fit model to data.
    [Y2, gof] = fit( xData, yData, ft, opts );
    
    if options.PlotFit
        hold on
        h2 = plot( Y2, xData, yData );

        hold off
    end
    
end