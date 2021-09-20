function avgMax = avgAroundMax( ydata, radius )
    [maxVal, maxIdx] = max(ydata);
    
    xmin = max( [maxIdx - radius, 1]);
    xmax = min( [maxIdx + radius, length(ydata) ] );
    
    avgRange = xmin:xmax;
    
    avgMax = mean( ydata(avgRange) );
end

