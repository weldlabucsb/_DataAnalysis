function [fig_handle, fig_filename] = phase_diagram_check(RunDatas,RunVars,options)
% PLOTFUNCTIONTEMPLATE makes a plot from the given RunDatas against the
% dependent variable {varied_variable_name}. Optional arguments are passed
% to setupPlot, which automatically puts axes and a legend on the plot,
% resizes the axes, etc.
% 

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
    
    vars_to_be_averaged = {'summedODy','RawMaxPeak3Density','cloudSD_y','atomNumber','cloudCenter_y','cloudCenter_x'};
    for j = 1:length(RunDatas)
        [avg_atomdata{j}, varied_var_values{j}] = avgRepeats(...
            RunDatas{j}, varied_variable_name, vars_to_be_averaged);
    end

    close all;
    first_fig = figure(1);
    cmap = colormap( jet( length(RunDatas) ) );

    %%import the relevant KD parameters
    [V0s,vvas,secondaryErPerVolt] = KDimport();
    secondaryPDGain = 1; 
    
    
    cutoff = 0.1;
    frac = 0.75;
    lambdas = zeros(0);
    Ts = zeros(0);
    IPRvec = zeros(0);
    fracWidthsvec = zeros(0);
    Widthsvec = zeros(0);
    atomNumsVec = zeros(0);
    xCenterVec = zeros(0);
    yCenterVec = zeros(0);
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
            
            

            maxs2 = vva_to_voltage(V0s,vvas,atomdata(ii).vars.Lattice915VVA)*secondaryErPerVolt/secondaryPDGain;
            la1 = 1064;
            la2 = 915;
            
            %%need to calculate Delta as a function of time
            
            [J, Delta]  = J_Delta_PiecewiseFit(s1,maxs2);
            
            tic 
            if(1)
                [lambdaInt] = calc_lambda_gaussian(s1,maxs2,300);
                disp('Be careful, using default tau');
            else
                [lambdaInt] = calc_lambda_gaussian(s1,maxs2,RunDatas{j}.vars.PulseWidthus);
            end
            toc
            
            hbar_Er1064 = 7.578e-5; %Units of Er*seconds
            hbar_Er1064_us = 75.78; %hbar in units of Er*microseconds
            
            
%             tau_us = RunDatas{j}.ncVars.tau;
%             tau = tau_us*J/hbar_Er1064_us;
            if(1)
                T_us = RunDatas{j}.vars.KickPeriodms*1E3;
            else
                T_us = RunDatas{j}.vars.KickPeriodus;
            end
%             lambdas(length(lambdas)+1)  = Delta*tau/J;
            lambdas(length(lambdas)+1)  = lambdaInt/(hbar_Er1064_us);
            Ts(length(Ts)+1) = T_us*J/hbar_Er1064_us;
            Depths915{j}(ii) = maxs2;
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
            
            xCenterPos{j}(ii) = avg_atomdata{j}(ii).cloudCenter_x;
            yCenterPos{j}(ii) = avg_atomdata{j}(ii).cloudCenter_y;
            
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
        
        atomNumsVec = [atomNumsVec atomNums{j}];
        
        xCenterVec = [xCenterVec xCenterPos{j}];
        
        yCenterVec = [yCenterVec yCenterPos{j}];
        
    end
    %%% End Data Manipulation %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Then plot things, just looping over the values I computed above.
    figure(1);
    subplot(2,2,1);
    wupperlim = 2E-4;
    wlowerlim = 0;
    Widthsvec(or(Widthsvec>wupperlim,Widthsvec<wlowerlim)) = NaN;
    
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

    subplot(2,2,2);
    scatter3(lambdas,Ts,atomNumsVec);
    xlabel('Lambda');
    ylabel('T''');
    title('AtomNumber');
    hold on;
    plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-','linewidth',2);
    hold off;
    
    subplot(2,2,3);
    xupperlim = 8E-4;
    xlowerlim = 6E-4;
    xCenterVec(or(xCenterVec>xupperlim,xCenterVec<xlowerlim)) = NaN;
    scatter3(lambdas,Ts,xCenterVec);
    xlabel('Lambda');
    ylabel('T''');
    title('Cloud Center X');
%     hold on;
%     plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-','linewidth',2);
%     hold off;
    

    subplot(2,2,4);
    yupperlim = 6.75E-4;
    ylowerlim = 6.6E-4;
    yCenterVec(or(yCenterVec>yupperlim,yCenterVec<ylowerlim)) = NaN;
    scatter3(lambdas,Ts,yCenterVec);
    xlabel('Lambda');
    ylabel('T''');
    title('Cloud Center Y');
%     hold on;
%     plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-','linewidth',2);
%     hold off;
    
    
    
    
    
    
        
    function depth = vva_to_voltage(V0s,vvas,vva)

        depth = interp1(vvas,V0s,vva);
        
        %clear V0s; clear vvas; V0s = [atomdata(:).V0];
        %for ii = 1:length(atomdata) vvas(ii) = atomdata(ii).vars.Lattice915VVA; end
    end

end
