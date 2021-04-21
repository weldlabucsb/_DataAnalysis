function [plot1, plot2, plot3, fitdata, fit_rects, latticeParams] = dualGaussPlot(RunData,RunVars,options)
%% DUALGAUSSPLOT(RunData, RunVars, options) [one plot per run]
% Plots a two-gaussian fit to the localized and delocalized fractions of an expansion distribution.
% Returns an extra output, a struct of the fits and the widths of each

arguments
    RunData
    RunVars
end
arguments
    options.PlottedDensity = "summedODy"
    %
    options.yLabel string = "Density"
    options.yUnits string = "(a.u.)"
    %
    options.xLabel string = "Position"
    options.xUnits string = "(um)"
    %
    options.FontSize (1,1) double = 20
    options.LegendFontSize (1,1) double = 16
    options.TitleFontSize (1,1) double = 20
    %
    options.Interpreter (1,1) string = "latex"
    %
    options.LegendLabels = []
    options.LegendTitle string = ""
    options.Position (1,4) double = [2, 42, 1278, 1314];
    %
    options.PlotTitle = ""
    %
    options.xLim (1,2) double = [0,800]
    options.yLim (1,2) double
    %
    options.PlotPadding = 15;
    %
    options.SmoothWindow = 5;
    %
    options.ManualFitting (1,1) logical = 1
    %
    options.FitRects = {}
    %
    options.SubFigureLineWidth = 3;
end

%%
    
    hbar = 1.054571817e-34; % J * seconds
    amu = 1.66053906660e-27; % AMU in kg
    
    m = 84 * amu;
    
    k1064 = 2 * pi / ( 1064 * 1e-9 );
    ErToJoules = hbar^2 * k1064^2 / ( 2 * m );
    
%%
    
    s1 = RunData{1}.vars.VVA1064_Er;
    tau = RunData{1}.ncVars.tau * 1e-6;

%%

RunDatas = cellWrap(RunData);
frects = options.FitRects;

%%

varied_variable_name = RunVars.varied_var;
legendvars = RunVars.varied_var;
varargin = {RunVars.heldvars_each};

%%

plottedDensity = options.PlottedDensity;

if plottedDensity == "summedODy"
    SD = 'cloudSD_y';
elseif plottedDensity == "summedODx"
    SD = 'cloudSD_x';
end

%% Camera Params

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
[~,~,pixelsize,mag] = paramsfnc('ANDOR');
xConvert = pixelsize/mag * 1e6; % converts the x-axis to um.

%% Avg Atomdata entries for same varied_variable_value

    [ad, varied_var_values] = avgRepeats(...
            RunData, varied_variable_name, options.PlottedDensity);
        
    N = length(ad);
    
    for ii = 1:N
       density(ii,:) = [ad(ii).(options.PlottedDensity)]; 
    end

%%

    fig_handle1 = figure();

    figure_title_dependent_var = options.PlottedDensity;

    cmap = colormap( jet( size(ad, 2) ) );
    
    dimx = 4;
    dimy = 5;
    
%     dim = ceil( sqrt( N ) );
%     
%     if dim * (dim-1) >= N
%         dimx = dim;
%         dimy = dim - 1;
%     else
%         dimx = dim;
%         dimy = dim;
%     end

    options.SubplotTitle = 1;
    options.SkipLegend = 1;
    options.SkipLabels = 1;

%%
    x = ( 1:length(density(1,:)) ) * xConvert;
    
%%

    for ii = 1:N
        
        subplot( dimy, dimx, ii  );
        
        y = movmean( density(ii,:), options.SmoothWindow );
        
        plot(x, y,'LineWidth',options.SubFigureLineWidth);
        
%         try
            if options.ManualFitting
                
                if isempty(options.FitRects)
                    [fitdata(ii).netFit, fitdata(ii).fit1, fitdata(ii).fit2, fit_rects{ii}] = ...
                        dualGaussManualFit( x, y, 'OriginalFigureHandle', fig_handle1, ...
                        'LineWidth', options.SubFigureLineWidth);
                else
                    [fitdata(ii).netFit, fitdata(ii).fit1, fitdata(ii).fit2, fit_rects{ii}] = ...
                        dualGaussManualFit( x, y, 'OriginalFigureHandle', fig_handle1,...
                        'FitRect', frects{ii}, ...
                        'LineWidth', options.SubFigureLineWidth);
                end
                
                yfit = fitdata(ii).fit1;
                fitdata(ii).width1 = yfit.sigma1;
                fitdata(ii).atomnumber1 = trapz(x, yfit(x) - yfit.c1);
                fitdata(ii).center1 = yfit.x1;


                yfit = fitdata(ii).fit2;
                fitdata(ii).width2 = yfit.sigma2;
                fitdata(ii).atomnumber2 = trapz(x, yfit(x));
                fitdata(ii).center2 = yfit.x2;
                
            else
                
                [fitdata(ii).netFit, fitdata(ii).fit1, fitdata(ii).fit2] = ...
                    dualGaussAutoFit(x,y);
                
                yfit = fitdata(ii).netFit;
                
                fitdata(ii).width1 = yfit.sigma1; 
                fitdata(ii).width2 = yfit.sigma2; 
                
                fitdata(ii).center1 = yfit.x1; 
                fitdata(ii).center2 = yfit.x2; 
                
                % here is where the atom numbers are computed (areas)
                fitdata(ii).atomnumber1 = trapz(x, fitdata(ii).fit1);
                fitdata(ii).atomnumber2 = trapz(x, fitdata(ii).fit2);
                
            end
            
            widths1 = [fitdata.width1];
            widths2 = [fitdata.width2];
            
            centers1 = [fitdata.center1];
            centers2 = [fitdata.center2];
            
            atomNumbers1 = [fitdata.atomnumber1];
            atomNumbers2 = [fitdata.atomnumber2];
            
            net_atomnums = atomNumbers1 + atomNumbers2;
%             atomNumbers1 = atomNumbers1 ./ net_atomnums;
%             atomNumbers2 = atomNumbers2 ./ net_atomnums;
            
%         catch
%             disp(strcat(...
%                 "Fit failed on entry ", num2str(ii), "/", num2str(N) ...
%             ));
%         end
        
%         title(['915VVA = ' num2str(varied_var_values(ii))],'Interpreter','tex')
        depth915Er(ii) = VVAto915Er(varied_var_values(ii));
        
        [J(ii), Delta(ii)] = J_Delta_PiecewiseFit(s1,depth915Er(ii));
        
        % convert since Delta in 1064 Ers
        lambda(ii) = Delta(ii) * ErToJoules * tau / hbar;
        
        title(strcat("\lambda = ",num2str(lambda(ii),'%.3f')),'interpreter','tex','FontSize',10)
        
        set(gca,'YTickLabel',[]);
        set(gca,'XTickLabel',[]);
        xlabel('Position','Interpreter','tex');
        
        xlim(options.xLim);
        
        latticeParams(ii).J = J(ii);
        latticeParams(ii).Delta = Delta(ii);
        latticeParams(ii).lambda = lambda(ii);
        latticeParams(ii).depth915Er = depth915Er(ii);
        latticeParams(ii).Lattice915VVA = varied_var_values(ii);
        
    end

%%

[plot_title1, fig_filename1] = setupPlotWrap( ...
    fig_handle1, ...
    options, ...
    RunDatas, ...
    figure_title_dependent_var, ...
    varied_variable_name, ...
    legendvars, ...
    varargin);

plot1.fig_handle = fig_handle1;
plot1.plot_title = plot_title1;
plot1.fig_filename = fig_filename1;
        
%% Width Evolution Plot

fig_handle2 = figure();

plot( lambda, widths1, '.-', ...
    'LineWidth', 1.5)
hold on;
plot( lambda, widths2, '.-', ...
    'LineWidth', 1.5);
hold off;
% title( plotTitle( RunData, 'Fitted Component Widths', varied_variable_name, varargin ) );

options2 = options;
options2.SkipLegend = 1;
options2.xLim = [varied_var_values(1) varied_var_values(end)];
options2.LegendFontSize = 16;
options2.PlotPadding = 0;
options2.yLabel = "Fitted Component Widths (um)";
options2.xLabel = varied_variable_name;
options2.SubplotTitle = 0;

[plot_title2, fig_filename2] = setupPlotWrap( ...
    fig_handle2, ...
    options2, ...
    RunDatas, ...
    "Fitted Component Widths",...
    varied_variable_name,...
    legendvars,...
    varargin);

legend(["Population 1","Population 2"]);

plot2.fig_handle = fig_handle2;
plot2.plot_title = plot_title2;
plot2.fig_filename = fig_filename2;

%% Atom Number Evolution Plot

fig_handle3 = figure();

% manually omit the nasty data points where the fits are awful

% temp = atomNumbers1;
% atomNumbers1(2:3) = atomNumbers2(2:3);
% atomNumbers2(2:3) = temp(2:3);

% atomNumbers1(2:3) = [];
% atomNumbers2(2:3) = [];
% net_atomnums(2:3) = [];
% lambda(2:3) = [];
% varied_var_values(2:3) = [];

% Here I decide how to normalize each atom number datapoint

%%% This section is for normalizing all the points to a single value %%%

% reference_atomNum = max(net_atomnums);
reference_atomNum = net_atomnums(1);
% reference_atomNum = 1;

plot( lambda, atomNumbers2 / reference_atomNum, '.-', ...
    'LineWidth', 1.5);
% hold on;
% plot( lambda, atomNumbers1 / reference_atomNum, '.-', ...
%     'LineWidth', 1.5)
% plot( lambda, net_atomnums / reference_atomNum, '.-', ...
%     'LineWidth', 1.5);


%%% This section is for normalizing each datapoint to the sum at that datapoint %%%
% plot( lambda, atomNumbers2 ./ net_atomnums, '.-', ...
%     'LineWidth', 1.5);
% hold on;
% plot( lambda, atomNumbers1 ./ net_atomnums, '.-', ...
%     'LineWidth', 1.5);


hold off;
% title( plotTitle( RunData, 'Fitted Component Widths', varied_variable_name, varargin ) );

options2.yLabel = "Fractional Population (a.u.)";

[plot_title3, fig_filename3] = setupPlotWrap( ...
    fig_handle3, ...
    options2, ...
    RunDatas, ...
    "Fractional Atom Number",...
    varied_variable_name,...
    legendvars,...
    varargin);

legend(["Population 1","Population 2","Total Population"]);

plot3.fig_handle = fig_handle3;
plot3.plot_title = plot_title3;
plot3.fig_filename = fig_filename3;

%%

% fig_handle4 = figure();
% 
% plot( varied_var_values, centers1, '.-', ...
%     'LineWidth', 1.5)
% hold on;
% plot( varied_var_values, centers2, '.-', ...
%     'LineWidth', 1.5);
% hold off;
% % title( plotTitle( RunData, 'Fitted Component Widths', varied_variable_name, varargin ) );
% 
% options2.yLabel = "Center Position (um)";
% 
% [plot_title4, fig_filename4] = setupPlotWrap( ...
%     fig_handle4, ...
%     options2, ...
%     RunDatas, ...
%     "Center Position",...
%     varied_variable_name,...
%     legendvars,...
%     varargin);
% 
% legend(["Population 1","Population 2"]);

end