function [] = pColorCenteredNonGrid(parentAx,xData,yData,valueData,xTol,yTol)

    xMin = -0.0001;
%     xMax = 0.07;
    xMax = max(xData);


    uniqY = unique(yData);
    betweenValues = zeros(1,(length(uniqY)-1));
    for ii = 1:(length(uniqY)-1)
        betweenValues(ii) = (uniqY(ii)+uniqY(ii+1))/2;
    end

    plotBoundaries = [uniqY(1)-0.0001 betweenValues uniqY(end)+0.0001];

    ax = parentAx;

    hold(ax,'on')

    for ii = 1:length(uniqY)
        yMin = plotBoundaries(ii);
        yMax = plotBoundaries(ii+1);
        thisVectBounds = [xMin,xMax,yMin,yMax];

        thisIndices = (abs(yData-uniqY(ii))<yTol);

        thisXData = xData(thisIndices);
        thisYData = yData(thisIndices);
        thisValueData = valueData(thisIndices);

        pColorCenteredGrid(ax,thisXData,thisYData,thisValueData,thisVectBounds,thisXData,uniqY(ii),xTol,yTol);

    end

    xlim(ax,[xMin,xMax])
    ylim(ax,[plotBoundaries(1),plotBoundaries(end)])

end