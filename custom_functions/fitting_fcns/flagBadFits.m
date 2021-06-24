function output = flagBadFits(RunDatas,varied_var,options)
% FLAGBADODYFITS returns a cell array, with each cell corresponding to one
% run in the provided RunDatas. The cell contains a string of booleans,
% where 1 corresponds to a good fit and 0 corresponds to a bad fit. The
% goodness of a fit is user-determined.
% 
% By default, set up to do dual gaussian fits on data for kickedAA pulse
% decay rate comparison

arguments
   RunDatas
   varied_var = 'LatticeHold'
end
arguments
    options.Position = [1469, 390, 765, 420];
    
    options.RunVars = struct()
    options.ManualHeldVars = {'T','tau'}
    
    options.FittedDataVarname = 'summedODy'
    options.FitObjectVarname = 'fitData_y'
    options.FitParameterVarname = 'gaussAtomNumber_y' % if there is an extracted value from the fit, display it here
    
    options.RefitFunction = 'dualGaussManualFit' % mat file name of fit fcn
    
    options.xConvert = 2 % set to scale independent variable for fitted data
    
    options.SkipRefit = 0
    options.SkipODPreview = 0
    
    options.FitParameterPrecision = '%1.2e' % controls display of fit parameter on plots
    
%     options.OutputOnError = 0
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
  
elseif isequal( options.ManualHeldVars, {'T','tau'} )
    heldvars = options.ManualHeldVars;
else
    heldvars = options.ManualHeldVars;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% aliases for long options
fitted_data_varname = options.FittedDataVarname;
fit_object_varname = options.FitObjectVarname; % here actually just a fit evaluated on same axis
fit_param_varname = options.FitParameterVarname;

N = length(RunDatas);

% here in case I break something with this
% fns = {'summedODy','(fit_object_varname)','OD','cloudSD_y'};
fns = {fitted_data_varname,fit_object_varname,fit_param_varname,'OD'};


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
            plotFit(avgRDs{ii}(j),this_run_plottitle,options,ii,j,N,Ncurves);
        
        %% Ask about fit
        
        
        [good_fit_tags{ii}(j), give_up] = yes_no_choice(options);
        
        if ~options.SkipRefit
            
            % never give up (except when they hit cancel)
            while ~give_up
                
                tempRD = avgRDs{ii}(j); % a copy
                
                try
                    
                    %%%%%%%%%% REFIT %%%%%%%%%%
                    [refit_vector,refit_param] = refit(avgRDs{ii}(j),...
                        fitted_data_varname,xvector{ii}{j},options);
                    
                    tempRD.(fit_object_varname) = refit_vector;
                    tempRD.(fit_param_varname) = refit_param;

                    plotFit(tempRD,this_run_plottitle,options,ii,j,N,Ncurves);

                    [good_fit_tags{ii}(j), give_up] = yes_no_choice(options);

                    if good_fit_tags{ii}(j)
                        avgRDs{ii}(j) = tempRD;
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    
                %%%%%%%%% Error Handling %%%%%%%%%%%    
                catch ME
                    
                    switch ME.identifier
                        case 'curvefit:fit:nanComputed'
                            warning('NaN computed by fit. Try grabbing a different domain/range.');
                             give_up = 0;
                        case 'MATLAB:badsubscript'
                            warning('Looks like you might not have selected any points -- some vector is empty!')
                             give_up = 0;
                        case 'MATLAB:class:InvalidHandle'
                            warning('Refit figure closed. Verify how to proceed.')
                            [good_fit_tags{ii}(j), give_up] = yes_no_choice();
                        otherwise
                            
%                             outputWorkSoFar(good_fit_tags,avgRDs,options) % DO NOT SUPPRESS
                            error(['Unknown error: ' ME.message]);
                            
                    end
                   
                end
            end
        end
        
    end
end

output.good_fit_tags = good_fit_tags ;
output.avgRDs = avgRDs;

end

% function error_output = outputWorkSoFar(good_fit_tags,avgRDs,options)
%     if options.OutputOnError
%         error_output.good_fit_tags = good_fit_tags;
%         error_output.avgRDs = avgRDs;
%     end
% end

function [xvector, fig_handle] = plotFit(this_avgRD,this_run_plottitle,options,ii,j,N,Ncurves)
    
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
        this_run_plottitle{end+1} = strcat(...
            "Fit ",options.FitParameterVarname,": ",...
            num2str(this_avgRD.( options.FitParameterVarname ),options.FitParameterPrecision) );
        title(this_run_plottitle);
        
        % other plot stuff
        ylabel(strcat("Data: ",fitted_data_varname));
        legend(["Data","Fit"]);
        set(fig_handle,'Position',options.Position);
        
        if ~options.SkipODPreview
            % OD preview
            nexttile;
            imagesc([this_avgRD.OD].');
            colormap(inferno);
        end
end

function [choice, give_up] = yes_no_choice(options)
% YES_NO_CHOICE returns 1 if the user chooses true, 0 if the user choose
% false.

    switch options.SkipRefit
        case 0
            answer = questdlg('Good fit?',...
                    'Check out the fit...',...
                    'Yes',...
                    'No (Refit)',...
                    'No (Skip)',...
                    'Yes'); % default YES
        case 1
            answer = questdlg('Good fit?',...
                    'Check out the fit...',...
                    'Yes',...
                    'No',...
                    'Yes'); % default YES
    end
        
            switch answer
                case 'Yes'
                    choice = 1;
                    give_up = 1;
                case 'No (Refit)'
                    choice = 0;
                    give_up = 0;
                case {'No (Skip)','No'}
                    disp("All hope is lost. Setting fit goodness = 0.");
                    choice = 0;
                    give_up = 1;
                case ''
                    error('Operation terminated by user input.');
            end
        
end

% function updated_fit_vector = refit(this_avgRD,fitted_data_varname,fit_object_varname,xvector)
function [refit_vector, refit_param, refit_fit_object]  = refit(this_avgRD,fitted_data_varname,xvector,options)
    ydata = this_avgRD.(fitted_data_varname);
    xdata = xvector;
    
    switch options.RefitFunction 
        case "dualGaussManualFit"
            [Y, Y1, Y2, roiRect] = dualGaussManualFit(xdata,ydata,...
                'PlotFit',0);
            refit_vector = Y;
            refit_fit_object = Y1;
            refit_param = Y1.sigma1;
    end
    
end