function runNumbers = makeRunNumberList(runNumbers)
% MAKERUNNUMBERLIST takes in a 1-by-N (or N-by-1) vector of doubles, and
% returns a cell array of the run numbers specified. Use for feeding
% conditions to the libraryConstruct method of RunDataLibrary objects:
%
% Example: condition = {'RunNumber', makeRunNumberList(27:28)};
%          Data = RunDataLibrary();
%          Data = Data.libraryConstruct(DATA, condition);

    runNumbers = arrayfun( @(x) {num2str(x)}, runNumbers );

end