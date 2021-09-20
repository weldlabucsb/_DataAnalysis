function good_fit_tags = flagBadODyFits(RunDatas,varied_var,options)
% FLAGBADODYFITS returns a cell array, with each cell corresponding to one
% run in the provided RunDatas. The cell contains a string of booleans,
% where 1 corresponds to a good fit and 0 corresponds to a bad fit. The
% goodness of a fit is user-determined.

arguments
   RunDatas
   varied_var = 'LatticeHold'
end
arguments
    options.Position = [1469, 390, 765, 420]
end

if class(RunDatas) ~= "cell" && length(RunDatas) == 1
   RunDatas = {RunDatas}; 
end

N = length(RunDatas);

fns = {'summedODy','fitData_y','OD','cloudSD_y'};

xconvert_to_um = 2;

N_to_check = 0;

good_fit_tags = cell( size(RunDatas) );
for ii = 1:length(good_fit_tags)
    
    [avgRDs{ii}, t{ii}] = avgRepeats(RunDatas{ii},varied_var,fns);
    
   good_fit_tags{ii} = zeros( size(avgRDs{ii}) ); 
   N_to_check = N_to_check + length(good_fit_tags{ii});
end

disp(['There are a total of ' num2str(N_to_check) ' fits to check. Starting...']);

%%

for ii = 1:N
    
    [avgRDs{ii}, t{ii}] = avgRepeats(RunDatas{ii},varied_var,fns);
    
    Ncurves = length(avgRDs{ii});
    
    for j = 1:Ncurves
        
        xvector{ii}{j} = (1:length([avgRDs{ii}(j).summedODy])) * xconvert_to_um;

        h = figure(800);
        
        tiledlayout(2,1,'TileSpacing','none');
        
        nexttile;
        
        plot( xvector{ii}{j}, [avgRDs{ii}(j).summedODy] );
        hold on;
        plot(xvector{ii}{j}, [avgRDs{ii}(j).fitData_y] );
        hold off;
        xlim([xvector{ii}{j}(1), xvector{ii}{j}(end)]);
        
        titl = plotTitle(RunDatas{ii},'summedODy',varied_var,{'T','tau'});
        titl(1) = [];
        titl{end+1} = strcat("Run ",num2str(ii),"/",num2str(N),...
            ", Curve ",num2str(j),"/",num2str(Ncurves));
        titl{end+1} = strcat("Fit Width: ",num2str(avgRDs{ii}(j).cloudSD_y*1e6));
        
        title(titl);
        
        nexttile;
        imagesc([avgRDs{ii}(j).OD].');
        colormap(inferno);
        
        set(h,'Position',options.Position);
        
        answer = questdlg('Good fit?',...
            'Check out the fit...',...
            'Yes',...
            'No',...
            'Stop Checking',...
            'Yes'); % default YES
        switch answer
            case 'Yes'
                good_fit_tags{ii}(j) = 1;
            case 'No'
                good_fit_tags{ii}(j) = 0;
%             case 'Go Back!'
%                 if j == 1
%                     ii = ii - 1;
%                 else
%                     j = j - 1;
%                 end
%                 disp('Going back!');
            case {'','Stop Checking'}
                error('Operation terminated by user input.');
        end
        
    end

end

end