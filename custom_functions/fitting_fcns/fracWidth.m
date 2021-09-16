function [width, center, peakLeftEdge, peakRightEdge, thisFracWidthHeight] = fracWidth(x,y,widthFraction,options)
% FRACWIDTHS takes in an x and y vector, and outputs the width (relative to
% x) at which y takes values widthFraction*y on either side of a peak.
%
% If options.PeakRadius = R is specified, averages R points around the
% maximum peak to determine the "maximum" value for the distribution.
%
% If options.PlotWidth (logical), plots a horizontal line to visualize the
% fractional width.
%
% If options.SmoothWindow = w (double) is specified, data will be smoothed
% (moving mean) over w datapoints before computing fracWidth.

    arguments
        x 
        y 
        widthFraction (1,1) double
    end
    arguments
        options.PeakRadius (1,1) = 1
        options.PlotWidth (1,1) logical = 0
        options.Position (1,4) double = [-1078, -206, 1078, 854];
        options.SmoothWindow (1,1) double = 1
    end
    
    y = movmean(y,options.SmoothWindow);
    
    radius = options.PeakRadius;
    [peakValue, knownIndex] = averageAroundMaximum(x,y,radius);

    peakValue = peakValue - min( y );

    thisFracWidthHeight = peakValue * widthFraction + min(y);

%     [~,knownIndex] = max(y);

    aboveFracWidthHeight = y > thisFracWidthHeight;

    logic = logical(aboveFracWidthHeight);

    edges = diff(logic);
    leftedges = find(edges == 1) + 1;
    rightedges = find(edges == -1);

    edgevals = edges(edges ~= 0);

    if edgevals(1) == -1
        leftedges = [1, leftedges];
    end

    if edgevals(end) == 1
        rightedges = [rightedges, length(logic)];
    end

    for n = 1:length(leftedges)
        blockN = [leftedges(n):rightedges(n)];
        % find the block that contains the center
        if sum( blockN == knownIndex ) == 1  
            peakLeftEdge = x( blockN(1) );
            peakRightEdge = x( blockN(end));
        end
    end

    center = (peakLeftEdge + peakRightEdge)/2;
    width = peakRightEdge - peakLeftEdge;
    
    if options.PlotWidth
       hFrac = figure(14);
       plot(x,y);
       hold on;
       line([peakLeftEdge peakRightEdge], thisFracWidthHeight * [1 1]);
%        set(hFrac,'Position',options.Position);
       hold off;
    end
    
    function [avgMaxValue, peakIndex, centerX] = averageAroundMaximum(x,y,radius)
        
        [~, peakIndex] = max(y);
        centerX = x(peakIndex);
        peakWindowLeft = max(1,(peakIndex - radius));
        peakWindowRight = min(length(y),(peakIndex + radius));
        window = [ peakWindowLeft : peakWindowRight ];
        avgMaxValue = mean(y(window));
        
    end
    
end