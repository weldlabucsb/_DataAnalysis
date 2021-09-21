function [idx, true_value] = findNearest( value, in_matrix, dimension )
% FINDNEAREST(value, vector) finds the index and true_value in in_matrix
% which is closest to the input value. Takes a dimemsion argument, which
% can be set to 'all'. If dimension == 'all', idx is a linear dimension.

    arguments
        value
        in_matrix
        dimension = 1
    end
    
    if dimension == "all"
        [true_value, idx] = min( abs(in_matrix - value), [], dimension, 'linear' );
    end

end