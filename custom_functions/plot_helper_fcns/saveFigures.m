function saveFigures(figure_handle, filename, varargin, options)
% SAVE_FIGURES saves the figure specified by figure_handle to the location
% specified by filename. If a third argument is provided, it is treated as
% the directory to which the figure should be saved.

arguments
    figure_handle
    filename
end
arguments (Repeating)
    varargin
end
arguments
    options.SaveFigFile (1,1) logical = 0
    options.OpenDir (1,1) logical = 0
    options.FileType string = ".png"
end

varargin{1} = strrep(varargin{1},'.','-');

if ~isfolder( varargin{1} )
    disp(strcat(...
        "Output folder at ",varargin{1}, " does not exist. Creating directory."));
    mkdir( varargin{1} );
end

if isempty(varargin)
    open_flag = 0;
else 
    open_flag = 1;
end

% shove things into cells if they aren't already to make the loop work.
if class(filename) ~= "cell"
    filename = {filename};
end
if class(figure_handle) ~= "cell"
    figure_handle = {figure_handle};
end

N_figures = length(filename);
for j = 1:N_figures
   filename{j} = changeFileType(filename{j}, options.FileType); 
end

% loop over the figures and save them all
for j = 1:N_figures
    
    disp(strcat("Saving ", num2str(j), "/", num2str(N_figures) ," figures."));
    
    % if output folder is specified, change filename to include it
    if ~isempty(varargin)
        filename{j} = fullfile( varargin{1}, filename{j} );
    end
    
    saveas( figure_handle{j}, filename{j} );
end

if options.SaveFigFile
    
    for j = 1:N_figures
        
        disp(strcat("Saving ", num2str(j), "/", num2str(N_figures) ," figure files."));

%         filename{j} = strrep(filename{j},options.FileType,".fig");
        filename{j} = changeFileType(filename{j}, ".fig");

        saveas( figure_handle{j}, filename{j} );
    
    end
    
end

if options.OpenDir
    
    if open_flag
        ofile = varargin{1};
    else
        ofile = pwd;
    end
    
    if ispc
        winopen(ofile);
    end
    
    
end

end

function out = changeFileType(in_string, newFileType)
    
    newFileType = strrep(newFileType,".","");

    spl = split(in_string,".");
    if length(spl) > 1
       spl(end) = newFileType;
       out = strjoin([strjoin(spl(1:(end-1)),""),spl(end)],".")
    else
       out = strcat(spl, ".", newFileType);
    end
end