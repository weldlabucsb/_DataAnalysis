function [fig_handle, fig_filename] = frequencyDisorder2DWidth(RunDatas,RunVars,options)
% PLOTFUNCTIONTEMPLATE makes a plot from the given RunDatas against the
% dependent variable {varied_variable_name}. Optional arguments are passed
% to setupPlot, which automatically puts axes and a legend on the plot,
% resizes the axes, etc.
% 


%%%%%Note %%%%%%%%%%
%unlike the rest of the functions I made this one work so that just RunVars
%is an input to avoid having to do unpackRunVars



arguments
    RunDatas
    RunVars
end
arguments
    options.LineWidth (1,1) double = 1.5
    %
    options.yLabel string = ""
    options.yUnits string = ""
    %
    options.xLabel string = RunVars.varied_var;
    options.xUnits string = ""
    %
    options.FontSize (1,1) double = 20
    options.LegendFontSize (1,1) double = 16
    options.TitleFontSize (1,1) double = 20
    %
    options.Interpreter (1,1) string = "latex" % alt: 'none', 'tex'
    %
    options.LegendLabels = [] % leave as is if you want auto-labels
    options.LegendTitle string = "" % leave as is if you want auto-title
    options.Position (1,4) double = [461, 327, 420, 463];
    %
    options.PlotTitle = "" % leave as is if you want auto-title
    %
    options.xLim (1,2) double = [0,0] % leave as [0, 0] to NOT set limits
    options.yLim (1,2) double = [0,0] % leave as [0, 0] to NOT set limits
    %
    options.PlotPadding = 0;
end
varied_variable_name = RunVars.varied_var;
legendvars = RunVars.heldvars_each;
varargin = {RunVars.heldvars_all};
% [varied_var, ...
%  heldvars_each, ...
%  heldvars_all, ...
%  legendvars_each, ...
%  legendvars_all] = unpackRunVars(RunVars);

    % Use avgRepeats on your RunDatas to extract repeat-averaged values of
    % whichever cicero variables (vars_to_be_averaged) you want to work
    % with. Here I wanted those values associated with each RunData
    % individually, so I looped over the RunDatas and repeat-averaged each
    % one.
    
    vars_to_be_averaged = {'summedODy','RawMaxPeak3Density'};
    for j = 1:length(RunDatas)
        [avg_atomdata{j}, varied_var_values{j}] = avgRepeats(...
            RunDatas{j}, varied_variable_name, vars_to_be_averaged);
    end

    % Work is in progress to make it easier to repeat-average subsets of
    % RunDatas while only repeat-averaging other individual RunDatas.
    %
    % The output, avg_atomdata will be a struct which will have fields of
    % the averaged values. I recommend you look at how this is structured
    % before writing the rest of the plot function.
    
    % You could also feed avgRepeats a cell array of RunDatas, as done
    % below. If you do, it will try to repeat-average all of them together.
    % Careful here -- I haven't put in error messages for if you feed it
    % RunDatas that shouldn't be repeat-averaged, and will yield unexpected
    % results. Better handling is in development.
    
%     vars_to_be_averaged = {'summedODy'};
%         [avg_atomdata, varied_var_values{1}] = avgRepeats(...
%             RunDatas, varied_variable_name, vars_to_be_averaged);
        
    % Obviously I would not do both of the above. They are applicable in
    % different cases.
    
    % Now that you have the repeat-averaged values for each RunData (or for
    % the averaged set, if you averaged all of them together), you can
    % compute and plot whichever quantities you want to plot.
    %
    % The output of plotFunctions should include a figure handle and a
    % filename to which the figure can be saved. Define the handle when you
    % make the figure. The filename will be generated later.
    %
    % I also define a colormap here to get good contrast between the
    % different traces (with default, more than 5 traces will start
    % repeating colors).
    
    first_fig = figure(1);
    cmap = colormap( jet( length(RunDatas) ) );
    
    % I also typically define here the dependent variable string that will
    % appear in my plot title. "vs. {varied_variable_name}" will be
    % appended. As an example, I'll use the specific case of plotting the
    % fractional widths based on the summedODy:
    
    
    
    % As an example of doing things with the repeat-averaged output, here I
    % use the averaged atomdata to compute the fractional widths of each
    % RunData. To get these, I used the first option above, and just
    % repeat-averaged each set within itself.
    
    cutoff = 0.2;
    frac = 0.8;
    lambdas = zeros(0);
    Ts = zeros(0);
    IPRvec = zeros(0);
    fracWidthsvec = zeros(0);
    for j = 1:length(RunDatas)
        
        % Here I compute each fracWidth from the repeat-averaged densities
        % for the iith entry in each RunData, which are stored in
        % avg_atomdata{j}(ii).summedODy
        [~,~,pixelsize,mag] = paramsfnc('ANDOR');
        xConvert = pixelsize/mag * 1e6; % convert from pixel to um
        
        X{j} = ( 1:size( avg_atomdata{j}(1).summedODy, 2 ) ) * xConvert;
        
        
        PrimaryLatticeDepthVar = 'VVA1064_Er'; %Units of Er of the primary lattice
        atomdata = RunDatas{j}.Atomdata;
        for ii = 1:size(avg_atomdata{j}, 2)
            %do delta and J calculations
            s1 = atomdata(ii).vars.(PrimaryLatticeDepthVar);
            
            
            if(isfield(atomdata(ii).vars,'ErPerVolt915'))
%                 disp('ErPerVolt915 Exists!')
                secondaryErPerVolt = atomdata(ii).vars.ErPerVolt915;  % Calibration from KD for the secondary lattice 
            else
%                 disp('ErPerVolt915 Doesn''t exist')
                %got from KD on 1/5
                secondaryErPerVolt = 22.34;
            end
            secondaryPDGain = 10; 
            if(isfield(atomdata(ii).vars,'Scope_CH2_V0'))
%                 disp('scope variable exists')
                secondaryPDPulseAmp = atomdata(ii).vars.('Scope_CH2_V0');
                secondaryPDGain = atomdata(ii).vars.PDGain915;  % Gain on PD
                s2 = secondaryPDPulseAmp*secondaryErPerVolt/secondaryPDGain;
            else
%                 disp('scope variable doesn''t exist')
                s2 = vva_to_voltage(atomdata(ii).vars.Lattice915VVA)*secondaryErPerVolt/secondaryPDGain;
%                 s2 = secondaryErPerVolt*vva_to_voltage(atomdata(ii).vars.Lattice915VVA);
            end
            la1 = 1064;
            la2 = 915;
            
            [J, Delta]  = J_Delta_Gaussian(s1,s2,la1,la2);
            
            hbar_Er1064 = 7.578e-5; %Units of Er*seconds
            hbar_Er1064_us = 75.78; %hbar in units of Er*microseconds
            
            tau_us = RunDatas{j}.ncVars.tau;
            tau = tau_us*J/hbar_Er1064_us;
            
            T_us = RunDatas{j}.ncVars.T;
            lambdas(length(lambdas)+1)  = Delta*tau/J;
            Ts(length(Ts)+1) = T_us*J/hbar_Er1064_us;
            %normalize ODy distribution
            norm_distr = (avg_atomdata{j}(ii).summedODy)./norm(avg_atomdata{j}(ii).summedODy);
            
            
            max_ratio{j}(ii) = mean(abs(avg_atomdata{j}(ii).summedODy),'all')/max(abs(avg_atomdata{j}(ii).summedODy),[],'all');
            [width, center] = fracWidth( X{j}, avg_atomdata{j}(ii).summedODy, frac);
            if max_ratio{j}(ii) > cutoff
                fracWidths{j}(ii) = NaN;
            else
                fracWidths{j}(ii) = width;
            end
            fracWidths{j}(ii) = width;
%             fracWidths{j}(ii) = width;
            
        end
        fracWidths{j} = smoothdata(fracWidths{j});
        fracWidthsvec = [fracWidthsvec fracWidths{j}];
    end
    %%% End Data Manipulation %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Then plot things, just looping over the values I computed above.
    
    figure_title_dependent_var = ['width at ' num2str(frac) ' maximum (summedODy, au)'];
    for j = 1:length(RunDatas)
        plot( varied_var_values{j}, fracWidths{j}, 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
        hold on;
    end
    hold off;
    
        sec_fig = figure(2);
    scatter3(lambdas,Ts,fracWidthsvec);
    xlabel('Lambda (unitless)');
    ylabel('T (unitless)');
    title('FWHM')
    xlim([0,2*max(Ts)]);
    ylim([0,max(Ts)]);
    
        % try data interpolation
    third_fig = figure(3);
    num_points = 50;
    lambda_interp = repmat(linspace(0,2*max(Ts),num_points),1,num_points);
    Ts_interp = repmat(linspace(0,max(Ts),num_points),num_points,1);
    Ts_interp = Ts_interp(:)';
    FWHM_interp = griddata(lambdas,Ts,fracWidthsvec,lambda_interp,Ts_interp);
    scatter3(lambda_interp,Ts_interp,FWHM_interp);
    xlabel('Lambda (unitless)');
    ylabel('T (unitless)');
    title('Interpolated IPR(ish) Data Scatter Plot');
    
        %add a contour plot
    fourth_fig = figure(4);
    num_points = 100;
    lambda_vec = linspace(0,2*max(Ts),num_points);
    Ts_vec = linspace(0,max(Ts),num_points)';
    [lambda_grid,Ts_grid,FWHM_interp] = griddata(lambdas,Ts,fracWidthsvec,lambda_vec,Ts_vec);
    hold on;
    contourf(lambda_grid,Ts_grid,FWHM_interp,10);
    plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-')
    hold off;
%     xlim([0,0.02])
    xlabel('Lambda (unitless)');
    ylabel('T (unitless)');
    title('Interpolated IPR(ish) Contour');
    

    %and a surf plot
    fifth_fig = figure(5);
    num_points = 100;
    lambda_vec = linspace(0,2*max(Ts),num_points);
    Ts_vec = linspace(0,max(Ts),num_points)';
    [lambda_grid,Ts_grid,FWHM_interp] = griddata(lambdas,Ts,fracWidthsvec,lambda_vec,Ts_vec);
    surf(lambda_grid,Ts_grid,FWHM_interp);
%     xlim([0,0.02])
    xlabel('Lambda (unitless)');
    ylabel('T (unitless)');
    title('IPR (ish)')
    
    %and a pcolor plot
%     sixth_fig = figure(6);
%     F = factor(numel(lambdas));
%     pcolor(reshape(lambdas,F(1),numel(lambdas)/F(1)),reshape(Ts,F(1),numel(lambdas)/F(1)),reshape(fracWidthsvec,F(1),numel(lambdas)/F(1)));
    %the pcolor plot was shit; I'll have to figure something out
    
    options.yLabel = figure_title_dependent_var;
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            first_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
    function depth = vva_to_voltage(vva)
        %take out the non-linearity
        V0s = [0.016000,0.016000,0.0160000,0.0240000,0.0325363,0.053418,0.069453,0.088672,0.13093,0.17131,0.209423626,0.24634811,0.28175,0.2979424,0.3280,0.365530,0.38883,0.407439,0.43064,0.4452181,0.46755,0.49028,0.5083,0.516321,0.5290575,0.530246];
        vvas = [0,1,1.5000000,1.6000,1.700,1.800,1.90000,2,2.2000,2.4000,2.60000,2.8000,3,3.100000,3.30000,3.600000,3.8000,4,4.2000,4.400000,4.700000,5,5.50000,6,7,8];
        depth = interp1(vvas,V0s,vva);
    end

end
