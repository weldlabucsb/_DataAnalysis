function [fig_handle, fig_filename] = freqDisorder2dwidthpcolor(RunDatas,RunVars,options)
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
    
    vars_to_be_averaged = {'summedODy','RawMaxPeak3Density','cloudSD_y','atomNumber'};
    for j = 1:length(RunDatas)
        [avg_atomdata{j}, varied_var_values{j}] = avgRepeats(...
            RunDatas{j}, varied_variable_name, vars_to_be_averaged);
    end

    close all;
    first_fig = figure(1);
    cmap = colormap( jet( length(RunDatas) ) );

    
   
    cutoff = 0.1;
    frac = 0.75;
    lambdas = zeros(0);
    Ts = zeros(0);
    IPRvec = zeros(0);
    fracWidthsvec = zeros(0);
    Widthsvec = zeros(0);
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
            
            
%             if(isfield(atomdata(ii).vars,'ErPerVolt915'))
% %                 disp('ErPerVolt915 Exists!')
%                 secondaryErPerVolt = atomdata(ii).vars.ErPerVolt915;  % Calibration from KD for the secondary lattice 
%             else
% %                 disp('ErPerVolt915 Doesn''t exist')
%                 %got from KD on 1/5
%                 secondaryErPerVolt = 22.34;
%             end


            %for 1/16 Data
%             secondaryErPerVolt = 22.313;
            
            %for 2/27 Data
            secondaryErPerVolt = 12.54;

            secondaryPDGain = 1; 
            
            %%%DONT USE (unless fit is good)
% % % % % %             if(isfield(atomdata(ii).vars,'Scope_CH2_V0'))
% % % % % % %                 disp('scope variable exists')
% % % % % %                 secondaryPDPulseAmp = atomdata(ii).vars.('Scope_CH2_V0');
% % % % % %                 s2 = secondaryPDPulseAmp*secondaryErPerVolt/secondaryPDGain;
% % % % % %             else
% % % % % %                 s2 = vva_to_voltage(atomdata(ii).vars.Lattice915VVA)*secondaryErPerVolt/secondaryPDGain;
% % % % % % %                 s2 = secondaryErPerVolt*vva_to_voltage(atomdata(ii).vars.Lattice915VVA);
% % % % % %             end

            s2 = vva_to_voltage(atomdata(ii).vars.Lattice915VVA)*secondaryErPerVolt/secondaryPDGain;
            la1 = 1064;
            la2 = 915;
            
            [J, Delta]  = J_Delta_PiecewiseFit(s1,s2);
            
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
            
            if (Widths{j}(ii)  > 6E-5)
                Widths{j}(ii) = NaN;
            end
            
            
            if (fracWidths{j}(ii)  > 35)
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
        
        fracWidths{j} = smoothdata(fracWidths{j},'movmean',2);
        fracWidthsvec = [fracWidthsvec fracWidths{j}];
    end
    %%% End Data Manipulation %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Then plot things, just looping over the values I computed above.
    
    figure_title_dependent_var = ['width at ' num2str(frac) ' maximum (summedODy, au)'];
%     figure_title_dependent_var = ['cloudSD_y'];
    for j = 1:length(RunDatas)
        plot( Depths915{j}, fracWidths{j}, 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');
        hold on;
    end
    hold off;
    
        sec_fig = figure(2);
    scatter3(lambdas,Ts,Widthsvec);
    xlabel('Lambda');
    ylabel('T''');
    title('cloudSD_y');
%     title(['width at ' num2str(frac) ' maximum (summedODy, au)']);
    hold on;
    plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-','linewidth',2);
    hold off;
%     xlim([0,2*max(Ts)]);
%     ylim([0,max(Ts)]);
    
    sixth_fig = figure(6);
%     pColorCenteredGrid(gca,lambdas,Ts,fracWidthsvec);
    pColorCenteredNonGrid(gca,lambdas,Ts,Widthsvec,1E-6,1E-6);
    
    zlim([0 5E-5]);
    hold on;
    plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-','linewidth',2);
    hold off;
%     xlim([0 0.02]);
        xlabel('Lambda');
    ylabel('T''');
    title('cloudSD_y');
%     title(['width at ' num2str(frac) ' maximum (summedODy, au)']);
    colorbar;
    
    %try different colormap 
            sev_fig = figure(7);
    mycolormap = customcolormap(linspace(0,1,11), {'#68011d','#b5172f','#d75f4e','#f7a580','#fedbc9','#f5f9f3','#d5e2f0','#93c5dc','#4295c1','#2265ad','#062e61'});
    colormap(mycolormap);
%     axis off;

%     pColorCenteredGrid(gca,lambdas,Ts,fracWidthsvec);
%     zlim([0 5E-5]);
    pColorCenteredNonGrid(gca,lambdas,Ts,Widthsvec,1E-6,1E-6);
    caxis([0 5E-5]);
% caxis([0 1E-5]);

    hold on;
    plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-','linewidth',2);
    hold off;
%     xlim([0 0.03]);
        
    title('cloudSD_y');
%     title(['width at ' num2str(frac) ' maximum (summedODy, au)']);
    colorbar;
    ylabel('T''');
    xlabel('Lambda');
    
    
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
        
    function depth = vva_to_voltage(vva)
        %take out the non-linearity
        %for the 1/16 data
% %         V0s = [0.016000,0.016000,0.0160000,0.0240000,0.0325363,0.053418,0.069453,0.088672,0.13093,0.17131,0.209423626,0.24634811,0.28175,0.2979424,0.3280,0.365530,0.38883,0.407439,0.43064,0.4452181,0.46755,0.49028,0.5083,0.516321,0.5290575,0.530246];
% %         vvas = [0,1,1.5000000,1.6000,1.700,1.800,1.90000,2,2.2000,2.4000,2.60000,2.8000,3,3.100000,3.30000,3.600000,3.8000,4,4.2000,4.400000,4.700000,5,5.50000,6,7,8];
        
        
        %for the 2/27 data
        V0s = [0.0297611340889169,0.0320000000016725,0.0360000000000222,0.0620546063258612,0.0719909967293660,0.100286258828503,0.132132920348285,0.160270640980708,0.194334313681227,0.216658564267728,0.230893463124005,0.254476729560220,0.267785474698420,0.284191264615461,0.300403320122237,0.316392760370631,0.335449780883353,0.341275399292686,0.355480424302642,0.370968685011421,0.386239458185895,0.393433865352977,0.408399987686944];
        vvas = [1,1.80000000000000,1.90000000000000,2,2.10000000000000,2.20000000000000,2.40000000000000,2.60000000000000,2.80000000000000,3,3.10000000000000,3.30000000000000,3.40000000000000,3.60000000000000,3.80000000000000,4,4.20000000000000,4.40000000000000,4.70000000000000,5,5.50000000000000,6,7.50000000000000];
        
                %for 3/23 data
%         V0s = [0,0.0736783508103853,0.0919325233215497,0.140775622496791,0.177681318284420,0.213707250228924,0.244105225971579,0.256827061740513,0.278925131974928,0.289462482914506,0.315246479230482,0.332958057066155,0.346744790852344,0.332958057066155,0.381614474966698,0.402993079662267,0.408784741151747,0.427199505248519,0.437485713621218,0.452582892831114];
%         vvas = [1,2,2.10000000000000,2.40000000000000,2.60000000000000,2.80000000000000,3,3.10000000000000,3.30000000000000,3.40000000000000,3.60000000000000,3.80000000000000,4,4.20000000000000,4.40000000000000,4.70000000000000,5,5.50000000000000,6,7.50000000000000];
        
        
        depth = interp1(vvas,V0s,vva);        
        %how to get the vva and V0 values
        %1. load the atomdata of the KD run. Doit must have been run
        %V0s = [atomdata(:).V0];
        %for ii = 1:length(atomdata) vvas(ii) = atomdata(ii).vars.Lattice915VVA; end
    end

end
