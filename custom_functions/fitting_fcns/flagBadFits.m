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
    
    options.FittedDataVarname = 'summedODy'
    options.FitObjectVarname = 'fitData_y'
    options.FitParameterVarname = 'cloudSD_y' % if there is an extracted value from the fit, display it here
    
    options.RefitFunction = 'dualGaussManualFit' % mat file name of fit fcn
    
    options.xConvert = 2; % set to scale independent variable for fitted data
end

%% Definitions


%% Setup

% required bc I interate over cell elements
RunDatas = cellWrap(RunDatas);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% unpack run variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isequal(options.RunVars,struct())
    [varied_var,...
    heldvars_each,...
    heldvars_all] = unpackRunVars(options.RunVars);

    heldvars = heldvars_each; % by default uses heldvars_each
  
elseif isequal( options.HeldVars, {'T','tau'} )
    heldvars = options.HeldVars;
else
    heldvars = options.HeldVars;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% aliases for long options
fitted_data_varname = options.FittedDataVarname;
fit_object_varname = options.FitObjectVarname; % here actually just a fit evaluated on same axis
fit_param_varname = options.FitParameterVarname;

N = length(RunDatas);

% here in case I break something with this
% fns = {'summedODy','(fit_object_varname)','OD','cloudSD_y'};
fns = {fitted_data_varname,fit_object_varname};


N_to_check = 0; %init
good_fit_tags = cell( size(RunDatas) ); %make a cell, element for each run
for ii = 1:length(good_fit_tags)
    
    % independent variable = t
    [avgRDs{ii}, t{ii}] = avgRepeats(RunDatas{ii},varied_var,fns);
    
    % add as many elements to list as number of runs
   good_fit_tags{ii} = zeros( size(avgRDs{ii}) ); 
   
   % for "progress bar"
   N_to_check = N_to_check + length(good_fit_tags{ii});
end

% disp starting message
disp(['There are a total of ' num2str(N_to_check) ' fits to check. Starting...']);

%%

for ii = 1:N
    
    % how many shots in each run
    Ncurves = length(avgRDs{ii});
    
    this_run_plottitle = plotTitle(RunDatas{ii},fitted_data_varname,varied_var,heldvars);
    
    % iterate over shots
    for j = 1:Ncurves
        
        %% Set Up the Plots
        
        [xvector{ii}{j}, fig_handle] = ...
            plotFit(avgRDs{ii}(j),this_run_plottitle,options,ii,j,N);
        
        %% Ask about fit
        
        [good_fit_tags{ii}(j), give_up] = yes_no_choice();
        
        give_up = 0; % never give up (except when they hit cancel)
        while ~give_up
            
            tempRD = avgRDs{ii}(j);
            
            refitted_vec = refit(avgRDs{ii}(j),fitted_data_varname,...
                fit_object_varname,xvector{ii}{j},options);
            
             [good_fit_tags{ii}(j), give_up] = yes_no_choice();
             
            plotFit(avgRDs{ii}(j),this_run_plottitle,options,ii,j)
        end
        
    end

end

end

function [xvector, fig_handle] = plotFit(this_avgRD,this_run_plottitle,options,ii,j,N)
    
        fitted_data_varname = options.FittedDataVarname;
        fit_object_varname = options.FitObjectVarname;

        % make an x-vector
        xvector = (1:length([this_avgRD.(fitted_data_varname)])) * options.xConvert;

        fig_handle = figure(800);
        tiledlayout(2,1,'TileSpacing','none');
        nexttile;
        
        % plot the data
        plot( xvector, [this_avgRD.(fitted_data_varname)] );
        hold on;
        % plot the fit
        plot(xvector, [this_avgRD.(fit_object_varname)] );
        hold off;
        % crop to tight x-axis
        xlim([xvector(1), xvector(end)]);
        
        
        % title with good info about this specific plot (progress, fit val)
        this_run_plottitle(1) = [];
        this_run_plottitle{end+1} = strcat("Run ",num2str(ii),"/",num2str(N),...
            ", Curve ",num2str(j),"/",num2str(Ncurves));
        this_run_plottitle{end+1} = strcat("Fit ",fit_param_varname,": ",...
            num2str(this_avgRD.( fit_param_varname )) );
        title(this_run_plottitle);
        
        % other plot stuff
        ylabel("Data: ",fitted_data_varname);
        legend(["Data","Fit"]);
        set(fig_handle,'Position',options.Position);
        
        % OD preview
        nexttile;
        imagesc([this_avgRD.OD].');
        colormap(inferno);
end

function [choice, give_up] = yes_no_choice()
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
                give_up = 1;
            case 'No (Refit)'
                choice = 0;
                give_up = 0;
            case 'No (Skip)'
                warning('Refit aborted. Fit goodness = 0.');
                choice = 0;
                give_up = 1;
            case ''
                error('Operation terminated by user input.');
        end
        
end

% function updated_fit_vector = refit(this_avgRD,fitted_data_varname,fit_object_varname,xvector)
function updated_fit_vector = refit(this_avgRD,fitted_data_varname,xvector,options)
    ydata = this_avgRD.(fitted_data_varname);
    xdata = xvector;
    
    switch options.RefitFunction 
        case "dualGaussManualFit"
            [Y, Y1, Y2, roiRect] = dualGaussManualFit(xdata,ydata,...
                'PlotFit',0);
            updated_fit_vector = Y;
    end
    
end