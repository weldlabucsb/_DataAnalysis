function runDatas = fixMislabeledData(Data)
% FIXMISLABELEDQUANITIES should be updated with cases of data which are
% mislabeled. Takes in RunDataLibrary, fixes quantities on the cases
% specified below.

% 12/15, runs 23-37
runNumbersToFix = makeRunNumberList([23:37]);
condition = {'RunID','12_15','RunNumber',runNumbersToFix};
runsToFix = Data.whichRuns(condition);
mislabeledVar = 'VVA915_Er';
realVarValue = 0.5;

for j = 1:length(runsToFix)
    thisRun = runsToFix{j};
    thisAd = thisRun.Atomdata;
    
    thisRun.vars.(mislabeledVar) = realVarValue;
    
    for ii = 1:length(thisAd)
       thisAd(ii).vars.(mislabeledVar) = realVarValue;
    end
    
    runsToFix{j}.Atomdata = thisAd;
end



end