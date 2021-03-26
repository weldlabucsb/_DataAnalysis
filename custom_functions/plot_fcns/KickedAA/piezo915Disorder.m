function [fig_handle, fig_filename] = piezo915Disorder(RunDatas,RunVars,options)
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

    % Use avgRepeats on your RunDatas to extract repeat-averaged values of
    % whichever cicero variables (vars_to_be_averaged) you want to work
    % with. Here I wanted those values associated with each RunData
    % individually, so I looped over the RunDatas and repeat-averaged each
    % one.
    
    vars_to_be_averaged = {'summedODy','RawPeak3Density','cloudSD_y','atomNumber','RawMaxPeak3Density'};
    for j = 1:length(RunDatas)
        [avg_atomdata{j}, varied_var_values{j}] = avgRepeats(...
            RunDatas{j}, varied_variable_name, vars_to_be_averaged);
    end

    close all;
    cmap = colormap( jet( length(RunDatas)+4 ) );

    
   
    cutoff = 0.1;
    frac = 0.75;
    lambdas = zeros(0);
    Ts = zeros(0);
    Widthsvec = zeros(0);
    fracWidthsvec = zeros(0);
    atomNumsVec = zeros(0);
    densityVec = zeros(0);
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
            
            %for 1/16 Data
%             secondaryErPerVolt = 22.313;
            
            %for 2/27 Data
            secondaryErPerVolt = 12.54;
            
            %for 3/23 Data
            secondaryErPerVolt = 12.94;
            

            secondaryPDGain = 1; 

            s2 = vva_to_voltage(atomdata(ii).vars.Lattice915VVA)*secondaryErPerVolt/secondaryPDGain;
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
            Depths915{j}(ii) = s2;
            max_ratio{j}(ii) = mean(abs(avg_atomdata{j}(ii).summedODy),'all')/max(abs(avg_atomdata{j}(ii).summedODy),[],'all');
            [width, center] = fracWidth( X{j}, avg_atomdata{j}(ii).summedODy, frac,'PlotWidth',0);
%             if max_ratio{j}(ii) > cutoff
%                 fracWidths{j}(ii) = NaN;
%             else
%                 fracWidths{j}(ii) = avg_atomdata{j}(ii).cloudSD_y;
%             end
            
            fracWidths{j}(ii) = width;
            Widths{j}(ii) = avg_atomdata{j}(ii).cloudSD_y;
            atomNums{j}(ii) = avg_atomdata{j}(ii).atomNumber;
            peakDensities{j}(ii) = avg_atomdata{j}(ii).RawMaxPeak3Density; %#ok<*AGROW>
            lambdaCell{j}(ii) = Delta*tau/J;
            TCell{j}(ii) = T_us*J/hbar_Er1064_us;
            maxOD{j}(ii) = max(smoothdata(avg_atomdata{j}(ii).summedODy,'movmean',20));

            %%%for cloudSY_y
            if (Widths{j}(ii)  > 6E-5)
                Widths{j}(ii) = NaN;
            end
            %%%for fracWidth
            if (fracWidths{j}(ii)  > 40)
                fracWidths{j}(ii) = NaN;
            end

              
%               fracWidths{j}(ii) = avg_atomdata{j}(ii).cloudSD_y;
              
              %%%Various conditions to eliminate bad runs
              
%               if (fracWidths{j}(ii) > 6E-5)
%                   fracWidths{j}(ii) = NaN;
%               end

%                 if(avg_atomdata{j}(ii).atomNumber < 1E4)
%                     fracWidths{j}(ii) = NaN;
%                 end
              
            
        end
        Widths{j} = smoothdata(Widths{j},'movmean',2);
        Widthsvec = [Widthsvec Widths{j}];
        
        fracWidths{j} = smoothdata(fracWidths{j},'movmean',3);
        fracWidthsvec = [fracWidthsvec fracWidths{j}];
        
        atomNums{j} = smoothdata(atomNums{j},'movmean',3);
        atomNumsVec = [atomNumsVec atomNums{j}];
        
        peakDensities{j} = smoothdata(peakDensities{j},'movmean',4);
        densityVec = [densityVec peakDensities{j}];
    end
    %%% End Data Manipulation %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Then plot things, just looping over the values I computed above.
    
    first_fig = figure(1);
    figure_title_dependent_var = ['cloudSD_y'];
%     figure_title_dependent_var = ['cloudSD_y'];
    for j = 1:length(RunDatas)
        plot( Depths915{j}, Widths{j}, 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
        hold on;
    end
    hold off;
    
    second_fig = figure(2);
    second_fig_dependent_var = ['width at ' num2str(frac) ' maximum (summedODy, au)'];
    %     figure_title_dependent_var = ['cloudSD_y'];
    for j = 1:length(RunDatas)
        plot( Depths915{j}, fracWidths{j}, 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
        hold on;
    end
    hold off;
    
        third_fig = figure(3);
    %     figure_title_dependent_var = ['cloudSD_y'];
    for j = 1:length(RunDatas)
        plot( Depths915{j}, atomNums{j}, 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
        hold on;
    end
    hold off;
    
            fourth_fig = figure(4);
    %     figure_title_dependent_var = ['cloudSD_y'];
            hold on;
    for j = 1:length(RunDatas)
        plot( lambdaCell{j}./TCell{j}, peakDensities{j}, 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
    end
            xline(2, 'r--',...
            'LineWidth', options.LineWidth);
    hold off;
    
                fifth_fig = figure(5);
    %     figure_title_dependent_var = ['cloudSD_y'];
            hold on;
    for j = 1:length(RunDatas)
        plot( lambdaCell{j}./TCell{j}, maxOD{j}, 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
    end
            xline(2, 'r--',...
            'LineWidth', options.LineWidth);
    hold off;
    
    save('D:\QCQKR\MATfiles\piezo915disorder','lambdaCell','TCell','peakDensities');
    
    options.yLabel = figure_title_dependent_var;
    options.xLabel = '915 Depth [E_R]';
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            first_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
    options.yLabel = second_fig_dependent_var;
    options.xLabel = '915 Depth [E_R]';
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            second_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
            options.yLabel = 'Atom Number';
    options.xLabel = '915 Depth [E_R]';
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            third_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
    options.yLabel = 'Raw Peak 3D Density';
    options.xLabel = '$\lambda / T$';
    
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            fourth_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
            options.yLabel = 'Raw Max OD';
    options.xLabel = '$\lambda / T$';
    
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            fifth_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
    function depth = vva_to_voltage(vva)
        %take out the non-linearity
        %for the 1/16 data
% %         V0s = [0.016000,0.016000,0.0160000,0.0240000,0.0325363,0.053418,0.069453,0.088672,0.13093,0.17131,0.209423626,0.24634811,0.28175,0.2979424,0.3280,0.365530,0.38883,0.407439,0.43064,0.4452181,0.46755,0.49028,0.5083,0.516321,0.5290575,0.530246];
% %         vvas = [0,1,1.5000000,1.6000,1.700,1.800,1.90000,2,2.2000,2.4000,2.60000,2.8000,3,3.100000,3.30000,3.600000,3.8000,4,4.2000,4.400000,4.700000,5,5.50000,6,7,8];
        
        
        %for the 2/27 data
        V0s = [0.0297611340889169,0.0320000000016725,0.0360000000000222,0.0620546063258612,0.0719909967293660,0.100286258828503,0.132132920348285,0.160270640980708,0.194334313681227,0.216658564267728,0.230893463124005,0.254476729560220,0.267785474698420,0.284191264615461,0.300403320122237,0.316392760370631,0.335449780883353,0.341275399292686,0.355480424302642,0.370968685011421,0.386239458185895,0.393433865352977,0.408399987686944];
        vvas = [1,1.80000000000000,1.90000000000000,2,2.10000000000000,2.20000000000000,2.40000000000000,2.60000000000000,2.80000000000000,3,3.10000000000000,3.30000000000000,3.40000000000000,3.60000000000000,3.80000000000000,4,4.20000000000000,4.40000000000000,4.70000000000000,5,5.50000000000000,6,7.50000000000000];
        
        
        depth = interp1(vvas,V0s,vva);
    end

end
