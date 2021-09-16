function output = cellmean(cellIn, dim)
% CELLMEAN averages the vectors contained in the input cell. If their size
% does not match, returns an error.

    cellD = numel( size(cellIn) );

    if nargin == 1
        dim = cellD+1;
    end
    
    dataAsNumericArray = cat(cellD + 1, cellIn{:});
    output = mean( dataAsNumericArray, dim );

end