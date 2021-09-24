function [run_date_list, runNumberStrings, theUniqueDates] = runDateList(RunDatas)
% RUNSLABELEDTITLE outputs a title of the format specified

RunDatas = cellWrap(RunDatas);

dates = string( cellfun(@(x) strcat( num2str(x.Month), ".", num2str(x.Day) ), RunDatas, 'UniformOutput', 0) );
runNumbers = string( cellfun(@(x) x.RunNumber, RunDatas, 'UniformOutput', 0) );


[theUniqueDates, dateIdx] = unique(dates);
N = length(theUniqueDates);

for ii = 1:N
    if ii ~= N
        thisDateIdx = dateIdx(ii):( dateIdx(ii + 1) );
    else
        thisDateIdx = dateIdx(ii):length(dates);
    end
    thisDateRunNums = runNumbers(thisDateIdx);
    thisDateRunNums = strrep(thisDateRunNums,'-','');
    
    thisDateRunNums = contractRunList(thisDateRunNums);
    
    runNumberStrings(ii) = strjoin(thisDateRunNums);
    dateNumTitle(ii) = strcat( theUniqueDates(ii), " - ", runNumberStrings(ii) );
end

if length(runNumbers) == 1
    pluraltag = " ";
else
    pluraltag = "s ";
end

run_date_list = strcat("Run", pluraltag, strjoin(dateNumTitle,", "));

end

function runNumberString = contractRunList(thisDateRunNums)
    
    % convert the string run numbers into ints
    a = str2num(cell2mat(convertStringsToChars(thisDateRunNums)));

    idx_markers = diff(a) - 1;

    idx = find( idx_markers > 0 );

    nBins = length(idx);
    N = length(a);

    for ii = 1:(nBins+1)

        if ii == 1
            idx1 = 1;
            idx2 = idx(1);
        else
            idx1 = idx(ii-1) + 1;
        end

        if ii <= nBins
            idx2 = idx(ii);
        else
            idx2 = N;
        end

        consecutiveNumString(ii) = strcat( num2str(a(idx1))," to ",num2str(a(idx2)) );

    end
    
    runNumberString = strjoin( consecutiveNumString, ", " );
end