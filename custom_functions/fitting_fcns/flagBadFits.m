function good_fit_tags = flagBadFits(RunDatas,varied_var,options)
% FLAGBADODYFITS returns a cell array, with each cell corresponding to one
% run in the provided RunDatas. The cell contains a string of booleans,
% where 1 corresponds to a good fit and 0 corresponds to a bad fit. The
% goodness of a fit is user-determined.
% 
% Currently only supports checking the summedODy fit as stored in
% atomdata.fitData_y. Functionality to be added later to assess a general
% cell array of fit objects.

arguments
   RunDatas
   varied_var = 'LatticeHold'
end
arguments
    options.Position = [1469, 390, 765, 420];
    
    options.RunVars = struct()
    options.HeldVars = {'T','tau'}
end

if class(RunDatas) ~= "cell" && length(RunDatas) == 1
   RunDatas = {RunDatas}; 
end

N = length(RunDatas);

heldvars = {'T','tau'};

if options.RunVars ~= []
    % by default uses heldvars_each
    [varied_var,...
        heldvars_each,...
        heldvars_all] = unpackRunVars(options.RunVars);
    heldvars = heldvars_each;
elseif isequal( options.HeldVars, {'T','tau'} )
    heldvars = options.HeldVars;
else
    heldvars = options.HeldVars;
end

fitted_data_varname = 'summedODy';
fit_object_varname = 'fitData_y'; % here actually just a fit evaluated on same axis

fns = {'summedODy','fitData_y','OD','cloudSD_y'};
fns = {fitted_data_varname,fit_object_varname};

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
        
        
        titl = plotTitle(RunDatas{ii},'summedODy',varied_var,heldvars);
        titl(1) = [];
        titl{end+1} = strcat("Run ",num2str(ii),"/",num2str(N),...
            ", Curve ",num2str(j),"/",num2str(Ncurves));
        titl{end+1} = strcat("Fit Width: ",num2str(avgRDs{ii}(j).cloudSD_y*1e6));
        
        title(titl);
        
        nexttile;
        imagesc([avgRDs{ii}(j).OD].');
        colormap(inferno);
        
        set(h,'Position',options.Position);
        
%         answer = questdlg('Good fit?',...
%             'Check out the fit...',...
%             'Yes',...
%             'No',...
%             'Stop Checking',...
%             'Yes'); % default YES
%         switch answer
%             case 'Yes'
%                 good_fit_tags{ii}(j) = 1;
%             case 'No'
%                 good_fit_tags{ii}(j) = 0;
%             case {'','Stop Checking'}
%                 error('Operation terminated by user input.');
%         end
        good_fit_tags{ii}(j) = yes_no_choice();
        
        if ~good_fit_tags{ii}(j)
            refit()
        end
        
    end

end

end

function choice = yes_no_choice()
% YES_NO_CHOICE returns 1 if the user chooses true, 0 if the user choose
% false.

    answer = questdlg('Good fit?',...
            'Check out the fit...',...
            'Yes',...
            'No',...
            'Stop Checking',...
            'Yes'); % default YES
        switch answer
            case 'Yes'
                choice = 1;
            case 'No'
                choice = 0;
            case {'','Stop Checking'}
                error('Operation terminated by user input.');
        end
        
end