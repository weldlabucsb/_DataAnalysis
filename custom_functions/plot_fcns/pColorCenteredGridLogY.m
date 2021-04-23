function [outPlot] = pColorCenteredGridLogY(xData,yData,valueData,vectBoundaries,xGrid,yGrid,xTol,yTol)
% Used for making a grid of data with rectangular color rectangles on each
% point. 
%   xData, yData, valueData are the data points.  They can either be vectors with 
%   data point i is (xData(i),yData(i),valueData(i)) or they can be
%   matrices of equal dimension in meshgrid style.
%
%   xGrid and yGrid are all of the points where data is expected to lie.
%   In other words, data values will be assigned to the points
%   (xGrid(i), yGrid(j)) for indices i and j.
%   If no data point from xData, yData, data is matched to a grid point, it 
%   is given the value "NaN" which plots as a blank space in the data.
%
%   vectBoundaries determine what region will be plotted.  It is of the
%   form [xMin, xMax, yMin, yMax] where xMin (yMin) is the minimum x (y)
%   boundary and xMax (yMax) is the maximum x (y) boundary.
%
%   xTol and yTol are used to determine if a data point lands on a grid
%   point.  If abs(xGrid - xData) < xtol and abs(yGrid - yData) < ytol,
%   then it will be considered a match.
%
%   If a data point has no grid point, an error will be thrown.

if nargin<3
    error('Insufficient input arguments')
elseif nargin==3
    xGrid = unique(xData);
    yGrid = unique(yData);
    [xData,yData,valueData,xGrid,yGrid]=checkDataFormat(xData,yData,valueData,xGrid,yGrid);
    vectBoundaries = makeDefaultVectBoundaries(xData,yData);
    [xTol,yTol] = makeDefaultTolerances(xGrid,yGrid);
elseif nargin==4
    xGrid = unique(xData);
    yGrid = unique(yData);
    [xData,yData,valueData,xGrid,yGrid]=checkDataFormat(xData,yData,valueData,xGrid,yGrid);
    [xTol,yTol] = makeDefaultTolerances(xGrid,yGrid);
elseif nargin==5
    yGrid = unique(yData);
    [xData,yData,valueData,xGrid,yGrid]=checkDataFormat(xData,yData,valueData,xGrid,yGrid);
    [xTol,yTol] = makeDefaultTolerances(xGrid,yGrid);
elseif nargin==6
    [xData,yData,valueData,xGrid,yGrid]=checkDataFormat(xData,yData,valueData,xGrid,yGrid);
    [xTol,yTol] = makeDefaultTolerances(xGrid,yGrid);
elseif nargin==7
    [xData,yData,valueData,xGrid,yGrid]=checkDataFormat(xData,yData,valueData,xGrid,yGrid);
    [~,yTol] = makeDefaultTolerances(xGrid,yGrid);
else
    [xData,yData,valueData,xGrid,yGrid]=checkDataFormat(xData,yData,valueData,xGrid,yGrid);
end



% MAYBE ADD A CHECK ON THE SIZES OF xTol and yTol

%% Setup Some Useful Variables

numGridPts = length(xGrid)*length(yGrid);

% gridPoints is a matrix of all point pairs (x,y,val) that lie on the grid.
% e.g., xGrid = [1;2], yGrid = [1;2], then gridPoints = [1,1,data11;
% 1,2,data12; 2,1,data21; 2,2,data22], where the "dataAB" values correspond
% to the data value at each of the grid points
gridPoints = NaN*ones(numGridPts,4);
gridPoints(:,4) = zeros(numGridPts,1);  % the forth column counts the number of averages for each point.
for ii=1:length(xGrid)
    for jj=1:length(yGrid)
        gridPoints((ii-1)*length(yGrid)+jj,1) = xGrid(ii);
        gridPoints((ii-1)*length(yGrid)+jj,2) = yGrid(jj);
    end
end


numDataPts = length(xData);


%% Setting values to the grid

for ii=1:numDataPts
    numMatches = 0;
    
    for jj=1:numGridPts
    % Looking for a grid point to place data point ii on
        if (abs(xData(ii)-gridPoints(jj,1))<xTol) 
            if (abs(yData(ii)-gridPoints(jj,2))<yTol)
                % Found a grid point
                numMatches = numMatches + 1;
                if numMatches > 1
                    warning('The data point with x value %g, y value %g, and data value %g matched (within tolerance) to more than one grid value and an attempt was made to assign it to both',xData(ii),yData(ii),valueData(ii))
                end
                
                if isnan(gridPoints(jj,3))
                    gridPoints(jj,3) = valueData(ii);
                    gridPoints(jj,4) = 1;
                else
                    % The number is incorporated into the average
                    numOfPreviousAverages = gridPoints(jj,4);
                    gridPoints(jj,3) = (numOfPreviousAverages*gridPoints(jj,3) + valueData(ii))/(numOfPreviousAverages+1);
                    gridPoints(jj,4) = numOfPreviousAverages + 1;
                    warning('An attempt was made to assign more than one value to the grid point with x value %g and y value %g.  The new value was averaged with all other data points on the same grid points.',gridPoints(jj,1),gridPoints(jj,2))
                end
                
            end
        end
        
    end
    if numMatches==0
        warning('The data point with x value %g, y value %g, and data value %g found no matching point on the grid (within tolerance)',xData(ii),yData(ii),valueData(ii))
    end
end


%% Sort Grid of Points
gridPoints = sortrows(gridPoints,[1,2]);

%% Make a matrix of the lower left corners between grid plaquets.  
% The lower left corner is assigned the value of its plaquet because this is how pcolor plots
% The upper and right edges are all assigned "NaN" because pcolor will ignore them anyway.

XCorners = zeros(length(xGrid),length(yGrid));
YCorners = zeros(length(xGrid),length(yGrid));
ValueCorners = zeros(length(xGrid),length(yGrid));
xMin = vectBoundaries(1);
xMax = vectBoundaries(2);
yMin = vectBoundaries(3);
yMax = vectBoundaries(4);


gg = 1;  %Index used to count grid calls
for ii = 1:length(xGrid)
    for jj = 1:length(yGrid)
        %Assign x position of the corner
        if ii == 1
            XCorners(ii,jj) = xMin;
        else
            XCorners(ii,jj) = (xGrid(ii)+xGrid(ii-1))/2; % Takes the geometric mean of the two x values
        end
        %Assign y position of the corner and the value
        if jj==1
            YCorners(ii,jj) = yMin;
            ValueCorners(ii,jj) = gridPoints(gg,3);
            gg = gg + 1;
        else
            YCorners(ii,jj) = sqrt(yGrid(jj)*yGrid(jj-1));
            ValueCorners(ii,jj) = gridPoints(gg,3);
            gg = gg + 1;
        end
    end
    
    % Stick a yMax on the upper edge
    if ii == 1
        XCorners(ii,length(yGrid)+1) = xMin;
    else
        XCorners(ii,length(yGrid)+1) = (xGrid(ii)+xGrid(ii-1))/2; % Takes the geometric mean of the two x values
    end
    YCorners(ii,length(yGrid)+1) = yMax;
    ValueCorners(ii,length(yGrid)+1) = NaN;
end

%Stick an xMax on (most of) the right edge
for jj = 1:length(yGrid)
    %Assign x position of the corner
    XCorners(length(xGrid)+1,jj) = xMax;
    %Assign y position of the corner and the value
    if jj==1
        YCorners(length(xGrid)+1,jj) = yMin;
        ValueCorners(length(xGrid)+1,jj) = NaN;
    else
        YCorners(length(xGrid)+1,jj) = sqrt(yGrid(jj)*yGrid(jj-1));
        ValueCorners(length(xGrid)+1,jj) = NaN;
    end
end

% Last NaN at the upper right corner
XCorners(length(xGrid)+1,length(yGrid)+1) = xMax;
YCorners(length(xGrid)+1,length(yGrid)+1) = yMax;
ValueCorners(length(xGrid)+1,length(yGrid)+1) = NaN;


%% Producing pcolor plot for the gridded data

outPlot = pcolor(XCorners, YCorners,ValueCorners);
outPlot.EdgeColor = 'none';
set(gca,'layer','top')
set(gca, 'YScale', 'log')

end

function [outXData,outYData,outValueData,outXGrid,outYGrid]=checkDataFormat(xData,yData,valueData,xGrid,yGrid)
    %% Check Data of Correct Form
    % Check that things are provided as vectors
    if ~isvector(xGrid)
        error('xGrid must be a vector')
    end
    if ~isvector(yGrid)
        error('yGrid must be a vector')
    end
    if max(size(xData)~=size(yData)) || max(size(xData)~=size(valueData))
        error('xData, yData, and valueData must all be vectors or matrices of the same size.')
    end
    
    if (size(xData,1)>1 && size(xData,2)>1)
        numPts = size(xData,1)*size(xData,2);
        outXData = zeros(numPts,1);
        outYData = zeros(numPts,1);
        outValueData = zeros(numPts,1);
        % if xData is a matrix, newXData will be a vector.  And similarly for
        % the rest
        for ii = 1:numPts
            outXData(ii) = xData(ii);
            outYData(ii) = yData(ii);
            outValueData(ii) = valueData(ii);
        end
    else
        outXData=xData;
        outYData=yData;
        outValueData=valueData;
    end

    % Make all vectors column vectors
    if size(outXData,1) < size(outXData,2)
        outXData = transpose(outXData);
    end
    if size(outYData,1) < size(outYData,2)
        outYData = transpose(outYData);
    end
    if size(outValueData,1) < size(outValueData,2)
        outValueData = transpose(outValueData);
    end
    if size(xGrid,1) < size(xGrid,2)
        xGrid = transpose(xGrid);
    end
    if size(yGrid,1) < size(yGrid,2)
        yGrid = transpose(yGrid);
    end

    % Check that data lengths are equal
    if ~(length(outXData)==length(outYData)) || ~(length(outXData)==length(outValueData))
        error('xData, yData, and valueData are not all vectors of equal length')
    end

    % Check if there are redundant entries in xGrid or yGrid, and remove if
    % necessary
    if length(xGrid)>length(unique(xGrid))
        xGrid = unique(xGrid);
        warning('xGrid contained redundant entries.  The redundancies were removed')
    end
    if length(yGrid)>length(unique(yGrid))
        yGrid = unique(yGrid);
        warning('yGrid contained redundant entries.  The redundancies were removed')
    end
    outXGrid = xGrid;
    outYGrid = yGrid;
    
end

function vectBoundaries = makeDefaultVectBoundaries(xData,yData)
    sortedXData = sort(unique(xData));
    xmin = sortedXData(1) - (sortedXData(2) - sortedXData(1))/2;
    xmax = sortedXData(end) + (sortedXData(end) - sortedXData(end-1))/2;
    sortedYData = sort(unique(yData));
    ymin = sqrt((sortedYData(1).^3)/sortedYData(2));
    ymax = sqrt((sortedYData(end).^3)/sortedYData(end-1));
    
    vectBoundaries = [xmin,xmax,ymin,ymax];

end

function [xTol,yTol] = makeDefaultTolerances(xGrid,yGrid)

    minNonZeroXDiff = NaN;
    for ii=1:length(xGrid)
        for jj=(ii+1):length(xGrid)
            absDiffX = abs(xGrid(ii)-xGrid(jj));
            if abs(xGrid(ii)-xGrid(jj))>0
                if isnan(minNonZeroXDiff)
                    minNonZeroXDiff = absDiffX;
                end
                if absDiffX < minNonZeroXDiff
                    minNonZeroXDiff = absDiffX;
                end
            end
        end
    end
    xTol = minNonZeroXDiff/1000;
    
    
    minNonZeroYDiff = NaN;
    for ii=1:length(yGrid)
        for jj=(ii+1):length(yGrid)
            absDiffY = abs(yGrid(ii)-yGrid(jj));
            if abs(yGrid(ii)-yGrid(jj))>0
                if isnan(minNonZeroYDiff)
                    minNonZeroYDiff = absDiffY;
                end
                if absDiffY < minNonZeroYDiff
                    minNonZeroYDiff = absDiffY;
                end
            end
        end
    end
    yTol = minNonZeroYDiff/1000;
    
end
