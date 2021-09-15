function [whereThisVarLives, isRunDataVar, isNCVar, isAtomdataVar]  = findVarField(RunDatas, var_name)
% FINDVARFIELD determines where a given variable name resides by checking the
% fields of RunDatas.vars, RunDatas.Atomdata.vars, and RunDatas.ncVars.
% First output is 'runDataVars', 'ncVars', 'atomdataVars', or 'atomdata'.
%
% If field does not exist in vars, ncVars, atomdata.vars, or atomdata,
% throws error.
%
% Field will be rejected as existing from a particular location if it is
% missing from any of the input RunDatas.
%
% If 'runDataVars', variable exists in all RunDatas.vars.
% If 'ncVars', variable exists in all RunDatas.ncVars.
% If 'atomdataVars', variable exists in all RunDatas.Atomdata.vars.
% If 'atomdata', variable exists in all RunDatas.Atomdata as a top-level
% field.
%
% If field exists in both RunDatas.vars and in Atomdata.vars, returns
% 'runDataVars'.

    isRunDataVar = all(cellfun(@(x) isfield(x.vars,var_name), RunDatas));
    isNCVar = all(cellfun(@(x) isfield(x.ncVars,var_name), RunDatas));
    isAtomdataVar = all(cellfun( @(rdcells) all(arrayfun( @(ad) isfield(ad.vars,var_name), rdcells.Atomdata)), RunDatas));
    isAtomdataField = all(cellfun( @(rdcells) all(arrayfun( @(ad) isfield(ad,var_name), rdcells.Atomdata)), RunDatas));
    
    if isRunDataVar
        whereThisVarLives = 'runDataVars';
    elseif isNCVar
        whereThisVarLives = 'ncVars';
    elseif isAtomdataVar
        whereThisVarLives = 'atomdataVars';
    elseif isAtomdataField
        whereThisVarLives = 'atomdata';
    end
                
    if ~isRunDataVar && ~isNCVar && ~isAtomdataVar && ~isAtomdataField
        errMsg = strcat(...
            "The variable ",var_name,...
            " is not a field in any of vars, ncVars, or atomdata.vars",...
            " for one or more of the provided runs.");
        error(errMsg);
    end
end