function [avg_atomdata, varied_var_values]  = avgRepeats(RunDatas, varied_variable_name, vars_to_be_avgd)
% AVG_REPEATS averages the repeats over the provided RunDatas.Atomdata
% Provide the varied_variable_name as a string corresponding to a variable
% in RunDatas.Atomdata.vars.(varied_variable_name).
%
% vars_to_be_avgd should be a cell array of cicero variable names.
% Repeat-averaged values of these variables will be put in the output
% (avg_atomdata). This will later be updated to just repeat-average all the
% variables that you want and generate a complete repeat-averaged atomdata

    arguments
        RunDatas23
        varied_variable_name string
        vars_to_be_avgd
    end
    
    % if some knucklehead gave me a string with one variable name instead
    % of a cell array, pack it into a cell array
    if (class(vars_to_be_avgd) == "string" || class(vars_to_be_avgd) == "char") ...
            && length(string(vars_to_be_avgd)) == 1
        vars_to_be_avgd = {vars_to_be_avgd};
    end
    
    Nvars = length(vars_to_be_avgd);
    
    varnames = vars_to_be_avgd;
    
    raw_atomdata.(varied_variable_name) = [];
    for j = 1:Nvars
       raw_atomdata.(varnames{j}) = [];
    end
    
    if ~rdclass(RunDatas)
        RunDatas = {RunDatas};
    end
    
    ads = [];
    for ii = 1:length(RunDatas)
        ads = [ads; RunDatas{ii}.Atomdata];
    end
    
    if isa(ads(1).vars.(varied_variable_name),'datetime')
        raw_atomdata.(varied_variable_name) = datetime.empty;
    end
    
    for j = 1:Nvars
       if all( arrayfun(@(x) isfield(x.vars,varnames{j}), ads ) )
           varnameIsAtomDataVar{j} = 1;
       elseif all( arrayfun(@(x) isfield(x,varnames{j}), ads ) )
           varnameIsAtomDataVar{j} = 0;
       else
          error(['The provided variable (',varnames{j},') is not present in ' ...
              'Atomdata or Atomdata.vars for one or more runs. Did you spell ' ...
              'the variable name correctly?']);
       end
    end
    
    for ii=1:length(ads)
        raw_atomdata(ii).(varied_variable_name) = [ads(ii).vars.(varied_variable_name)];
        
        for j = 1:Nvars
            
            if varnameIsAtomDataVar{j}
                raw_atomdata(ii).(varnames{j}) = [ads(ii).vars.(varnames{j})];
            elseif ~varnameIsAtomDataVar{j}
                raw_atomdata(ii).(varnames{j}) = [ads(ii).(varnames{j})];
            end
            
        end
        
    end
    
    [varied_var_raw, inds] = sort( [raw_atomdata.(varied_variable_name)] );
    N_raw = length(varied_var_raw);
    
    for j = 1:Nvars
        for ii = 1:length(raw_atomdata)
            sort_raw_atomdata(ii).(varnames{j}) = [raw_atomdata( inds(ii) ).(varnames{j})];
        end
    end
    
%     ywidths_raw = ywidths_raw(inds);
%     xwidths_raw = xwidths_raw(inds);
%     density_raw = density_raw(inds,:);
    
    [varied_var_values,~,idx] = unique(varied_var_raw);
    for ii = 1:length(varied_var_values)
        avg_atomdata(ii).(varied_variable_name) = varied_var_values(ii);
    end
    
    N = length(varied_var_values);
    
    for j = 1:Nvars
        % if variable maps 1-to-1 with the varied variable, average with
        % same value of varied variable
        if ~varnameIsAtomDataVar{j} && size([raw_atomdata.(varnames{j})],2) == N_raw
            avgVarVals = ...
                [accumarray(idx, [sort_raw_atomdata.(varnames{j})], [], @mean)];
            for ii = 1:N
               avg_atomdata(ii).(varnames{j}) = avgVarVals(ii);
            end
        end
    end

    density = [];
    
    % Averages profiles with same holdtime together, returns averaged
    % density
    for j = 1:Nvars
        if size([raw_atomdata.(varnames{j})],2) ~= N_raw
            for ii = 1:N
                this_varvar = varied_var_values(ii);
                theseprofiles = {sort_raw_atomdata(varied_var_raw == this_varvar).(varnames{j})}; 
                thisprofile = cellmean(theseprofiles); 
                avg_atomdata(ii).(varnames{j}) = thisprofile;
            end
        end
    end
end

