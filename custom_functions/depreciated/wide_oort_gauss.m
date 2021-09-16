function [Y_wide, Y_peak, data_peak] = wide_oort_gauss(x, y, options)
% WIDE_OORT_GAUSS(x,y) fits to wide base population, subtracts off the
% base, then fits to the remaining peak.

    arguments
        x double
        y double
    end
    arguments
        options.PlotConcavity logical = 0
%         options.Excluded double = []
%         options.ExcludeDomain logical = 0
        options.WidthFraction double = 0.5
        options.MinPeakDistance double = 10
        options.MinPeakHeightFraction double = 1/2
        options.EdgeFudge double = 2
        options.PlotFitWide logical = 0
        options.PlotFitSum logical = 0
        options.PlotFitPeak logical = 0
        options.LineWidth double = 1
        options.WidthThreshold logical = 1
        options.AmplitudeThreshold logical = 1
    end
    
    fudge = options.EdgeFudge;
    widthFraction = options.WidthFraction;
    line_width = options.LineWidth;

    %% Determine Edges
    
    ySmooth = movmean(y,10);
    
    dydx = gradient(ySmooth)./gradient(x);
    
    dydx2 = gradient(dydx) ./ gradient(x);
    
    if options.PlotConcavity
       plot( x, dydx2 , 'Color', 'k', 'LineWidth',line_width);
    end
     
    [~,edges,~,~] = ...
        findpeaks( dydx2, x, ...
        'MinPeakHeight', max(dydx2) * options.MinPeakHeightFraction , ...
        'MinPeakDistance', options.MinPeakDistance );
    
    edges = [min(edges), max(edges)];
    
    %% First Fit
    [xData, yData] = prepareCurveData( x, y );
    
    excluded = edges + fudge*[-1,1];
    
    excludedPoints = ~excludedata( xData, yData, 'domain', excluded );
    
    ampGuess = max(y(~excludedPoints));
    offsetGuess = min(y(~excludedPoints));
    
    [sigmaGuess, centerGuess] = ...
        frac_width(x(~excludedPoints),y(~excludedPoints),widthFraction);

%     centerGuess = (max(excluded) + min(excluded))/2;
%     sigmaGuess = round(size(y,2)/2);

    % Set up fittype and options.
    ft = fittype( 'A1 * exp( - ( (x - x1)/sigma1 ).^2 / 2 ) + c', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 0 0 -Inf];
    opts.Upper = [Inf Inf Inf Inf];
    opts.Robust = 'Bisquare';
    opts.StartPoint = [ampGuess offsetGuess sigmaGuess centerGuess];
    opts.Exclude = excludedPoints;

    % Fit model to data.
    [Y_wide, gof] = fit( xData, yData, ft, opts );
    wide_fit = Y_wide(x);
    
    if options.AmplitudeThreshold
    
        if Y_wide.A1 > 1.25*ampGuess
            wide_fit = zeros(size(wide_fit));
            disp("Amplitude of wide peak too large -- setting to zero!")
        end
        
    end
    
    if options.WidthThreshold
       
       if Y_wide.sigma1 < 100
           wide_fit = zeros(size(wide_fit));
           disp("Width of wide peak too small -- setting to zero!")
       end
        
    end
        
    if options.PlotFitWide
        h = plot( x, wide_fit,'LineWidth',line_width);
    end
    
    %% Second Fit
    
    y = y - wide_fit';
    data_peak = y;
    
    [xData, yData] = prepareCurveData( x, y );
    
    excluded = edges + fudge*[1,-1];
    
    excludedPoints = ~excludedPoints;
    
    ampGuess = max(y(~excludedPoints));
    
    [sigmaGuess, centerGuess] = ...
        frac_width(x(~excludedPoints),y(~excludedPoints),widthFraction);

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
    [Y_peak, gof] = fit( xData, yData, ft, opts );
    
    if options.PlotFitPeak
        hold on
%         h2 = plot( Y2, xData, yData );
        h2 = plot(x,Y_peak(x),'LineWidth',line_width);
        hold off
    end
    
    if options.PlotFitSum
        hold on
        Yp = Y_wide(x) + Y_peak(x);
        plot( x, Yp ,'LineWidth',line_width, 'Color', 'k');
        hold off
    end
    
end