function labels = makeLegendLabels(RunDatas, varied_var, legendvars, plot_every)
% MAKELEGENDLABELS takes in a cell array of RunDatas and a cell array of
% variable (cicero or ncVar) names, and returns a string array of legend
% entries each formatted as follows:
% "RunNumber0: Run0_LegendVarValue1, Run0_LegendVarValue2, ...".
%
% If legendvars contains the varied variable, legend will be for a
% one-plot-per-run type, where the varied variable labels each trace in the
% plot. The run number will be suppressed from the legend entries in this
% case.
%
% The plot_every argument controls which legend variables are generated.
% If plot_every = N, then every Nth legend entry will be included (starting
% from entry 1).
%     - I should eventually update this to take a logical array instead.

% General idea: grab the values of each legend variable and add to legend

if ~contains(legendvars,varied_var) % handle case for "all" legendvars
    
    % get legendvar values
    for k = 1:length(legendvars)
        legendvals_0{k} = getHeldVarValues(RunDatas,legendvars{k});
    end
    
    % reorganize the cell array to make it the format I need
    % (needed since I wrote the next part before redoing getHeldVarValues)
    for k = 1:numel(legendvals_0)
        for j = 1:numel(legendvals_0{k})
            legendvals{j}{k} = legendvals_0{k}(j);
        end
    end
    
    % stick the values together into proper legend labels.
    for j = 1:length(RunDatas)
        thisRunNumber = strrep(RunDatas{j}.RunNumber,'-','');
        labels(j) = strcat( thisRunNumber , ": " );
        
        thisvarval = num2str(legendvals{j}{1});
        labels(j) = strcat(labels(j), thisvarval );
        
        if length(legendvars) > 1
            
            labels(j) = strcat(labels(j), ", ");
        
            for k = 2:(length(legendvars)-1)
                thisvarval = num2str( legendvals{j}{k} );
                labels(j) = strcat(labels(j), thisvarval, ", " );
            end
        
            labels(j) = strcat(labels(j), num2str( legendvals{j}{end} ));
        end
    end
    
else % handle case for "each" legendvars
    
    for k = 1:length(legendvars)
        legendvals{k} = getVariedVarValues(RunDatas,legendvars{k});
    end
    
    legendvals = cellfun(@(x) x(1:plot_every:end), legendvals, ...
        'UniformOutput', false);
    
    % check that the number of values matches the number of plots
    % I don't remember writing this lol, it is a mess
    for ii = 1:length(legendvals)
        if ii == 1
            right_length = true;
            thislength = length(legendvals{1});
        else
            right_length = right_length && (thislength == length(legendvals{ii}));
            if ~right_length
                disp(strcat("The legend variable '",legendvals{ii},"' has more/fewer values than the number of plotted traces."));
                return;
            end
        end
    end
    
    
    % stick the values together into proper legend labels.
    labels = string(legendvals{1});
    for ii = 2:length(legendvals)
        labels = arrayfun( @(x,y) strcat(x,", ",y),labels,string(legendvals{ii}));
    end
    
end