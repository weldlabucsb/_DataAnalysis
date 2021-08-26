function plot_title_out = plotTitle(RunDatas,plotted_dependent_var,varied_variable_name,varargin)
% PLOTTITLE(RunDatas,plotted_dependent_var,varied_variable_name,varargin)
% outputs string: "{plotted_depednent_var} vs {varied variable name}"
%
%   plotted_dependent_var is a string describing the y-axis: example,
%   "SummedODy".
%
%   varied_variable_name is a string that corresponds to a cicero variable
%   stored in atomdata.
%
%   varargin takes in any number of cicero variables that are held
%   constant.

arguments
    RunDatas
    plotted_dependent_var
    varied_variable_name
end
arguments (Repeating)
    varargin
end

%% Get Folder, Date for Run

% the following nested list of nonsense is the unfortunate consequence of
% me not intially realizing how varargins passed from function to function
% get nested further and further into cell arrays. If it works, don't
% question it. If it doesn't, let me know and I'll properly unpack the
% varargins as they are passed between functions.
try
    if class(varargin{1}) ~= "cell"
       varargin{1} = {varargin{1}}; 
    end
end

if ~isempty(varargin)
    if ~isempty(varargin{1})
        held_var_flag = 1;
        for ii = 1:length(varargin{1})
            try
                held_var_name(ii) = string(varargin{1}{ii});
            catch
                held_var_name(ii) = string(varargin{1});
            end
            [~,held_var_value(ii)] = determineIfHeldVarConstant(RunDatas,held_var_name(ii));
            if ii == 1
                held_var_string = strcat(held_var_name(ii), " - ", num2str( held_var_value(ii) ));
            else
                held_var_string = strcat(held_var_string,", ",held_var_name(ii), " - ", num2str( held_var_value(ii) ));
            end
        end
        held_var_string = fix(held_var_string);
    else
        held_var_flag = 0;
    end
else
    held_var_flag = 0;
end

runNumberTitles = fix( runDateList(RunDatas) );

Title1 = strcat( plotted_dependent_var ," vs ", varied_variable_name );
Title1 = fix(Title1);

if held_var_flag
    plot_title_out = {Title1; held_var_string; runNumberTitles};
else
    plot_title_out = {Title1; runNumberTitles};
end

    function out = fix(in)
        out = strrep(in,'_','');
    end

end