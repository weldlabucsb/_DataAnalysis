function rmse = checkGOF(ydata,fitdata,options)

arguments
    ydata
    fitdata
end
arguments
    options.Plot = 0
end
    
    if any( size(ydata) ~= size(fitdata) )
        error('Reference data and fit data are not the same size.');
    end
    
    
    N = length(ydata);
    rmse = sqrt( sum(  (ydata - fitdata).^2 ) / N );
    
    if options.Plot
       plot(ydata);
       hold on;
       plot(fitdata);
       hold off;
    end
end