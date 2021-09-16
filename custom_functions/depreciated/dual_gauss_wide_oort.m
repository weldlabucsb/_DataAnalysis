function [Y, Y1, Y2] = dual_gauss_wide_oort(x,y,options)
% BIMODAL_FIT returns a fit object Y corresponding to the sum of two gaussians.
%giu
% Returns a fit object Y equal to the sum of two gaussians. 
%
% The peak of higher prominence has...
% amplitude = Y.A1
% std dev = Y.sigma1
% mean = Y.x1.
%
% The second peak (usually 
% amplitude = Y.A2
% std dev = Y.sigma2
% mean = Y.x2.
%
% Also returns a vertical offset, Y.c.

    arguments
        x double
        y double
    end
    arguments
        options.PeakFraction1 (1,1) double = 0.65
        options.PlotFit (1,1) logical = 1
    end

    peakFraction1 = options.PeakFraction1;
    plotFit = options.PlotFit;

    [sigmaGuess1, centerGuess1] = fracWidth(x,y,peakFraction1);
    
    sigmaGuess2 = round(size(y,2)/2);
    centerGuess2 = 0;

    ampGuess1 = max(y);
%     offsetGuess = round(min(y),2);
    offsetGuess = 0;
    
    ampGuess2 = ampGuess1/100;

    Y = two_gauss(x, y, ampGuess1, ampGuess2, centerGuess1, centerGuess2, sigmaGuess1, sigmaGuess2,offsetGuess);

    Y1 = Y.A1 * exp( - ( (x - Y.x1)./Y.sigma1 ).^2 / 2 );

    Y2 = Y.A2 * exp( - ( (x - Y.x2)./Y.sigma2 ).^2 / 2 );
    
    if plotFit
        hold on
        plot(x,Y(x),'--','Color','b','LineWidth',3);
        plot(x,Y1,'-.','Color',[0 0 200]/255,'LineWidth',2);
        plot(x,Y2,'-.','Color',[0 0 100]/255,'LineWidth',2);
        hold off
    end

end

%% Two-Gauss Fit
function [fitresult, gof] = two_gauss(x, y, ampGuess1, ampGuess2, centerGuess1, centerGuess2, sigmaGuess1, sigmaGuess2,offsetGuess)
    
    [xData, yData] = prepareCurveData( x, y );

    % Set up fittype and options.

    ft = fittype( 'A1 * exp( - ( (x - x1)/sigma1 ).^2 / 2 )    + A2 * exp( - ( (x - x2)/sigma2 ).^2 / 2 ) + c', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
%     opts.Lower = [0 0 -100 0 0 -1000 -1000];
    opts.Lower = [0 0 -Inf -Inf 200 0 -Inf];
%     opts.StartPoint = [ampGuess1 ampGuess2 offsetGuess sigmaGuess1 sigmaGuess2 centerGuess1 centerGuess2];
    opts.StartPoint = [2200 30 0.6467 10 300 190 0.0758542895630636];
    opts.Robust = 'Bisquare';
    
    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    
end