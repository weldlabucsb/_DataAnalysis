function figure_filename = filenameFromPlotTitle(plot_title,options)
% FILENAMEFROMPLOTTITLE takes in a cell array of strings from plotTitle,
% outputs a filename (default .png) formed by concatenating the lines in the
% plotTitle.
%
% Options:
% 1. Delimiter (string) specifies the join character used to concatenate
% the plotTitle into a filename. Default: ", "
% 2. ReplaceSpaces (logical) toggles swapping out spaces in filename for
% another character (specified by ReplaceSpacesWith option)
% 3. ReplaceSpacesWith (string) is the character(s) that replace spaces in
% the output filename. Default: "_"
% 4. FileType (string) is the file extension you want. Default: ".png"

arguments
   plot_title 
end
arguments
   options.Delimiter string = ", "
   options.ReplaceSpaces (1,1) logical = 0
   options.ReplaceSpacesWith string = "_"
   options.FileType string = ".png"
end

if class(plot_title) == "string" || class(plot_title) == "char"
   plot_title = {plot_title}; 
end

% gets rid of comma delimiter if replacing spaces (looks better)
if options.ReplaceSpaces
   options.Delimiter = " "; 
end

% builds the title from the cells
for j = 1:length(plot_title)
    if j == 1
        figure_filename = plot_title{j};
    else
        figure_filename = strcat( figure_filename, options.Delimiter, plot_title{j});
    end
end

% tacks on the filetype extension
figure_filename = strcat(figure_filename,options.FileType);

% swaps out spaces if specified
if options.ReplaceSpaces
    figure_filename = strrep( figure_filename, " ", options.ReplaceSpacesWith );
end

figure_filename = strrep( figure_filename, "$", "" );
figure_filename = strrep( figure_filename, "\", "" );
figure_filename = strrep( figure_filename, "{", "" );
figure_filename = strrep( figure_filename, "}", "" );
figure_filename = strrep( figure_filename, "mathrm", "");

end