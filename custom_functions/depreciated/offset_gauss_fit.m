function [Y,Y2] = offset_gauss_fit(x, y, options)

    arguments
        x double
        y double
    end
    arguments
        options.PlotFit logical = 0
        options.Excluded double = []
        options.ExcludeDomain logical = 0
        options.WidthFraction double = 0.65
    end
    
    excluded = options.Excluded;
    widthFraction = options.WidthFraction;
    plotFit = options.PlotFit;

    %% First Fit
    [xData, yData] = prepareCurveData( x, y );
    
    excludedPoints = ~excludedata( xData, yData, 'domain', excluded );
    
    if options.ExcludeDomain
        excludedPoints = ~excludedPoints;
    end
    
    ampGuess = max(y(~excludedPoints));
    offsetGuess = min(y(~excludedPoints));
    
    [sigmaGuess, centerGuess] = ...
        frac_width(x(~excludedPoints),y(~excludedPoints),widthFraction);

    % Set up fittype and options.
    ft = fittype( 'a1 * exp( - (x - b1)^2/(2*c1^2) ) + d1', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 -Inf 0 -Inf];
    opts.Upper = [Inf Inf Inf Inf];
    opts.Robust = 'Bisquare';
    opts.StartPoint = [ampGuess centerGuess sigmaGuess offsetGuess];
    opts.Exclude = excludedPoints;

    % Fit model to data.
    [Y, gof] = fit( xData, yData, ft, opts );
    
    if options.PlotFit
        h = plot( Y, xData, yData);
    end

    %% Second Fit
    
    first_fit = Y(x);
    y = y - first_fit';
    
    [xData, yData] = prepareCurveData( x, y );
    
    excludedPoints = ~excludedPoints;
    
    ampGuess = max(y(~excludedPoints));
    
    [sigmaGuess, centerGuess] = ...
        frac_width(x(~excludedPoints),y(~excludedPoints),widthFraction);

    % Set up fittype and options.
    ft = fittype( 'a1 * exp( - (x - b1)^2/(2*c1^2) )', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.StartPoint = [ampGuess centerGuess sigmaGuess];
    opts.Lower = [0 -Inf 0];
    opts.Upper = [Inf Inf Inf];
    opts.Robust = 'Bisquare';
    opts.Exclude = excludedPoints;

    % Fit model to data.
    [Y2, gof] = fit( xData, yData, ft, opts );
    
    if options.PlotFit
        hold on
        h2 = plot( x, Y2(x) + Y.d1 );

        Yp = Y(x) + Y2(x);
        plot( x, Yp , 'LineWidth', 2, 'Color', 'k');

        hold off
    end
  
end


