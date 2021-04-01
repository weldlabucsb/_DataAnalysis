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