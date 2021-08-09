function [fig_handle, fig_filename] = widthExpansionGaussian(RunDatas,RunVars,options)
% PLOTFUNCTIONTEMPLATE makes a plot from the given RunDatas against the
% dependent variable {varied_variable_name}. Optional arguments are passed
% to setupPlot, which automatically puts axes and a legend on the plot,
% resizes the axes, etc.


arguments
    %RunDatas is the main structure that contains information about all the
    %runs you want to analyze
    RunDatas
    %RunVars is an optional argument. The default values are below, and
    %shouldn't need to be changed. The function can be called without it
%     RunVars
    RunVars = struct('varied_var',{{'LatticeHold'}},...
        'heldvars_each',{{'Lattice915VVA','KickPeriodms'}},...
        'heldvars_all',{{'VVA1064_Er'}});
end
arguments
    %options 
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
% varied_variable_name = {'Lattice915VVA'};
legendvars = RunVars.heldvars_each;
% legendvars = {'Lattice915VVA'};
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
    
    cmap = colormap( jet( length(avg_atomdata) ) );

    
   
    %%import the relevant KD parameters
    [V0s,vvas,secondaryErPerVolt] = KDimport('V:\StrontiumData\2021\2021.06\06.18\16 - 915 kd with correct scope setting\','atomdata.mat');
    secondaryPDGain = 1; 
    
    
    cutoff = 0.1;
    frac = 0.75;
%     lambdas = zeros(0);
    Ts = zeros(0);
%     IPRvec = zeros(0);
    widthsMatrix = zeros(size(avg_atomdata{j}, 2),length(RunDatas));
    lattHoldMatrix = zeros(size(avg_atomdata{j}, 2),length(RunDatas));
    lambdaMatrix = zeros(size(avg_atomdata{j}, 2),length(RunDatas));
    TsMatrix = zeros(size(avg_atomdata{j}, 2),length(RunDatas));
    diffusion_fits = zeros(length(RunDatas),2);
    for j = 1:length(RunDatas)
        
        
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
            
            [lambdaInt] = calc_lambda_gaussian(s1,maxs2,300);
            disp('Be careful, using default tau');
            
            hbar_Er1064_us = 75.78; %hbar in units of Er*microseconds
            
                T_us = RunDatas{j}.vars.KickPeriodms*1E3;
            
            
            
%             lambdas(length(lambdas)+1)  = lambdaInt/(hbar_Er1064_us);
            TsMatrix(ii,j) = T_us*J/hbar_Er1064_us;

            widthsMatrix(ii,j) = avg_atomdata{j}(ii).cloudSD_y;            
            if (widthsMatrix(ii,j)  > 6E-5)
                widthsMatrix(ii,j) = NaN;
            end
            
            lattHoldMatrix(ii,j) = avg_atomdata{j}(ii).LatticeHold;
%             lat915Matrix(j,ii) = s2;
            lambdaMatrix(ii,j) = lambdaInt/(hbar_Er1064_us);
                      
        end
          
    end
    
    %take the average initial width
    avg_initial_width = mean(widthsMatrix(1,:));
%     diffusion_exponent = zeros(length(RunDatas),1);
    first_to_use = 3;
    for j = 1:length(RunDatas)
                  %smoothdata a bit
%           widthsMatrix(:,j) = smoothdata(widthsMatrix(:,j),'movmean',2);
          
          %fit to linearize with log log and then fit
          diffusion_fits(j,:) = polyfit(log(lattHoldMatrix(first_to_use:end,j)),log(widthsMatrix(first_to_use:end,j)),1);

            %try linear regression with constant starting width
%             diffusion_exponent(j) = log(lattHoldMatrix(first_to_use:end,j))\log(widthsMatrix(first_to_use:end,j)./avg_initial_width);
    end
    %%% End Data Manipulation %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%now try the fitting analysis
    
    % Then plot things, just looping over the values I computed above.
    
    
    
    first_fig = figure(1);
%     figure_title_dependent_var = ['width at ' num2str(frac) ' maximum (summedODy, au)'];
    figure_title_dependent_var = ['cloudSD_y'];
            hold on;
    for j = 1:size(widthsMatrix,2)
%         if (
        plot(lattHoldMatrix(:,j), widthsMatrix(:,j),  'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
%         set(gca,'yscale','log');

    end
        for j = 1:size(widthsMatrix,2)
                plot(lattHoldMatrix(first_to_use:end,j), exp(diffusion_fits(j,2)).*(lattHoldMatrix(first_to_use:end,j).^(diffusion_fits(j,1))),  '--',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
        end
    hold off;
    
    sec_fig = figure(2);
%     figure_title_dependent_var = ['width at ' num2str(frac) ' maximum (summedODy, au)'];
    figure_title_dependent_var = ['cloudSD_y'];
    for j = 1:size(widthsMatrix,2)
        plot(lattHoldMatrix(:,j), widthsMatrix(:,j),  'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
        set(gca,'yscale','log');
        set(gca,'xscale','log');
        hold on;
    end
    hold off;
    

    third_fig = figure(3);
%     figure_title_dependent_var = ['width at ' num2str(frac) ' maximum (summedODy, au)'];
    figure_title_dependent_var = ['cloudSD_y'];
    hold on;
    for j = 1:size(widthsMatrix,2)
        plot(lattHoldMatrix(:,j), widthsMatrix(:,j),  'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));

        set(gca,'yscale','log');
        set(gca,'xscale','log');
        
    end
    for j = 1:size(widthsMatrix,2)
                plot(lattHoldMatrix(first_to_use:end,j), exp(diffusion_fits(j,2)).*(lattHoldMatrix(first_to_use:end,j).^(diffusion_fits(j,1))),  '--',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
    end
    hold off; 
    
    if(0)
            point_types = repmat({'o','^','s','d','p'},1,3);
            paper_fig = figure(27);
%             cmap = colormap( hot( size(avg_atomdata{1}, 2)+8 ) );
            cmap = colormap(cool(size(avg_atomdata{1},2)));
            mycolormap = customcolormap(linspace(0,1,11), {'#68011d','#b5172f','#d75f4e','#f7a580','#fedbc9','#f5f9f3','#d5e2f0','#93c5dc','#4295c1','#2265ad','#062e61'});
            cmap = colormap(mycolormap);
            start_point = 3;
            caxis([min(diffusion_fits(:,1)), max(diffusion_fits(:,1))]);
        %     figure_title_dependent_var = ['width at ' num2str(frac) ' maximum (summedODy, au)'];
            figure_title_dependent_var = ['cloudSD_y'];
            box on;
            hold on;
            for j = [1 2:2:size(avg_atomdata{1}, 2)]
                climits = caxis;
                rgb = interp1(linspace(climits(1), climits(2), size(cmap, 1)), ...
                      cmap, ...
                      diffusion_fits(j,1));
                currPlot = scatter(lattHoldMatrix(start_point:end,j)./1E3, 1E6.*widthsMatrix(start_point:end,j),  point_types{j},...
                    'LineWidth', options.LineWidth,...
                    'markerEdgeColor',rgb,'markerFaceColor',rgb,'markerfacealpha',0.4);
                
                set(gca,'yscale','log');
                set(gca,'xscale','log');
%                 xlabel('\lambda');
%                 alpha 0.3;
%                 set(currPlot,'markerfacecolor',[rgb 0.8]);

            end
            for j = [1 2:2:size(avg_atomdata{1},2)]
                climits = caxis;
                rgb = interp1(linspace(climits(1), climits(2), size(cmap, 1)), ...
                      cmap, ...
                      diffusion_fits(j,1));
                        plot(lattHoldMatrix(first_to_use:end,j)./1E3, 1E6.*exp(diffusion_fits(j,2)).*(lattHoldMatrix(first_to_use:end,j).^(diffusion_fits(j,1))),  '--',...
                    'LineWidth', 2,...
                    'Color',rgb);
            end
            hold off; 
%             set(gcf,'interpreter','latex');
            set(gca,'fontsize',12);
            xlabel('Lattice Hold (s)');
            ylabel('BEC Width ({\mu}m)');
    end
    
    fourth_fig = figure(4);
    hold on;
    yyaxis left;
    plot(lambdaMatrix(1,:)./TsMatrix(1,:),diffusion_fits(:,1), 'o-',...
            'LineWidth', options.LineWidth);
        ylim([0,0.8]);
        ylabel('Diffusion Exponent')
        yyaxis right;
    plot(lambdaMatrix(6,:)./TsMatrix(6,:),widthsMatrix(7,:).*1E6, 'o-',...
            'LineWidth', options.LineWidth);
        ylabel('Cloud SDy, \mu m');
        ylim([0 40]);
        xline(2, 'r--',...
            'LineWidth', options.LineWidth);
        xlabel('\lambda/T','interpreter','Tex')
        hold off;
        legend({'Diffusion','SDy','$\lambda = 2T$'},'interpreter','latex');
    
    tic
    plotSacPhaseDiagram(1064/915,0,200,25,12);
    toc
    hold on;
    scatter(lambdaMatrix(1,:),TsMatrix(1,:));
    p = polyfit(lambdaMatrix(1,:),TsMatrix(1,:),1);
    
    plot(lambdaMatrix(1,:),polyval(p,lambdaMatrix(1,:)));
    lineDomain = linspace(min(lambdaMatrix(1,:)),max(lambdaMatrix(1,:)),100);
    plot(lineDomain,lineDomain./2);
    legend({'Samples','Fit','Transition'});
    hold off;
    
    next_fig = figure(124);
    hold on;
    yyaxis left;
    plot((lambdaMatrix(1,:)-6.017).*(1+p(1)^2)^(1/2),diffusion_fits(:,1), 'o-',...
            'LineWidth', options.LineWidth);
        ylim([0,0.8]);
        ylabel('Diffusion Exponent')
        yyaxis right;
    plot((lambdaMatrix(1,:)-6.017).*(1+p(1)^2)^(1/2),widthsMatrix(7,:).*1E6, 'o-',...
            'LineWidth', options.LineWidth);
        ylabel('Cloud SDy, \mu m');
        ylim([0 40]);
        xline(0, 'r--',...
            'LineWidth', options.LineWidth);
        xlabel('Distance from Transition','interpreter','Tex')
        hold off;
        legend({'Diffusion','SDy','$\lambda = 2T$'},'interpreter','latex');
    
        
        
        [thisP1] = theoryExpLine(1064/915,0,1800,lambdaMatrix(1,:),TsMatrix(1,:));
        [thisP2] = theoryExpLine(1064/915,pi/3,1800,lambdaMatrix(1,:),TsMatrix(1,:));
        [thisP3] = theoryExpLine(1064/915,2*pi/3,1800,lambdaMatrix(1,:),TsMatrix(1,:));
        thisP = (thisP1+thisP2+thisP3)./3;
        moar_fig = figure(125);
        hold on;
    plot((lambdaMatrix(1,:)-6.017).*(1+p(1)^2)^(1/2),diffusion_fits(:,1), 'o-',...
            'LineWidth', options.LineWidth);
        ylim([0,0.8]);
        ylabel('Diffusion Exponent');
    
    plot((lambdaMatrix(1,:)-6.017).*(1+p(1)^2)^(1/2),smooth(thisP(1,:),2));
        xline(0, 'r--',...
            'LineWidth', options.LineWidth);
        xlabel('Distance from Transition','interpreter','Tex')
        hold off;
        legend({'Diffusion','IPR^{-1}','$\lambda = 2T$'},'interpreter','latex');
%     
    
    
    options.yLabel = figure_title_dependent_var;
    options.xLabel = 'LatticeHold';
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            first_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
  
        
    options.yLabel = figure_title_dependent_var;
    options.xLabel = 'LatticeHold';
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            sec_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
        
    options.yLabel = figure_title_dependent_var;
    options.xLabel = 'LatticeHold';
    [plot_title, fig_filename] = ...
        setupPlotWrap( ...
            third_fig, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
        
%     options.yLabel = 'Diffusion Parameter';
%     options.xLabel = 'Lambda';
%     options.LegendTitle = " ";
% %     options.LegendLabels = {'Data','$\lambda = 2 T$'};
%     options.LegendLabels = {'$\lambda = 2 T$'};
%     [plot_title, fig_filename] = ...
%         setupPlotWrap( ...
%             fourth_fig, ...
%             options, ...
%             RunDatas, ...
%             figure_title_dependent_var, ...
%             varied_variable_name, ...
%             legendvars, ...
%             varargin);
        
    function depth = vva_to_voltage(V0s,vvas,vva)

        depth = interp1(vvas,V0s,vva);
        
        %clear V0s; clear vvas; V0s = [atomdata(:).V0];
        %for ii = 1:length(atomdata) vvas(ii) = atomdata(ii).vars.Lattice915VVA; end
    end

function[] = plotSacPhaseDiagram(beta,phi,sites,points,maxLambda)
    posGrid = linspace(0,maxLambda,points);
    [lambda,T] = meshgrid(posGrid,posGrid./2);

    IPRs = zeros(size(lambda));%to store the IPRs at various points
    tic
    parfor jj = 1:numel(lambda)
        %lattice and disorder operators
        H0 = full(gallery('tridiag',sites,-1,0,-1));
        H0(1,end) = -1; H0(end,1) = -1;
        pot = diag(cos(2.*pi.*beta.*(1:sites)+phi));
        %stob time evol operator
        timeEvOp = expm(-1i.*H0.*T(jj))*expm(-1i.*lambda(jj).*pot);

        [V,D] = eig(timeEvOp);
        [~,ind] = sort(diag(D));
        V = V(:,ind);

        IPRvec = sum(abs(V).^4,1);
        IPRs(jj) = mean(IPRvec.^(-1))/sites;
%         IPRs(ii) = mean(IPRvec);

    end
    toc
    figure(234);
    s = pcolor(lambda,T,IPRs);
    s.FaceColor = 'interp';
    s.EdgeAlpha = 0;
    ax = gca;
    xlabel('\lambda');
    ylabel('T');
    title('IPR of EVecs of U,');
    ax.FontSize = 14;
    colorbar;
    mycolormap = customcolormap(linspace(0,1,11), {'#68011d','#b5172f','#d75f4e','#f7a580','#fedbc9','#f5f9f3','#d5e2f0','#93c5dc','#4295c1','#2265ad','#062e61'});
    colormap(mycolormap);
end

function[IPRs] = plotLocalizationLine(beta,phi,sites,lambda,T)

    IPRs = zeros(size(lambda));%to store the IPRs at various points
    tic
    for jj = 1:numel(lambda)
        %lattice and disorder operators
        H0 = full(gallery('tridiag',sites,-1,0,-1));
        H0(1,end) = -1; H0(end,1) = -1;
        pot = diag(cos(2.*pi.*beta.*(1:sites)+phi));
        %stob time evol operator
        timeEvOp = expm(-1i.*H0.*T(jj))*expm(-1i.*lambda(jj).*pot);

        [V,D] = eig(timeEvOp);
        [~,ind] = sort(diag(D));
        V = V(:,ind);

        IPRvec = sum(abs(V).^4,1);
        IPRs(jj) = mean(IPRvec.^(-1))/sites;

    end
end

function[thisP] = theoryExpLine(beta,phi,sites,lambdas,Ts)
kickNo = 300;
kicksToSave = 100;
step = round(kickNo/kicksToSave);
% psiMat = zeros(sites,kicksToSave,xVarVals);
widthMat = zeros(kicksToSave,numel(lambdas));

    %initialize wavefunc
    %single site occupation
%     init = zeros(sites,1);
%     init(round(sites/2)) = 1;
    
%gaussian
    sigma = 8;
    init = exp(-((1:sites)'-sites/2).^2./(2*sigma^2));
    init = init./norm(init,2);

    
    
for ii = 1:numel(lambdas)

    %set lambda
    lambda = lambdas(ii);
    T = Ts(ii);
    psi = init;
    
        H0 = full(gallery('tridiag',sites,-1,0,-1));
    pot = diag(cos(2.*pi.*beta.*(1:sites)+phi));
%         stob time evol operator
    timeEvOp = expm(-1i.*H0.*T)*expm(-1i.*lambda.*pot);
    multTimeStep = timeEvOp^step;
    
    widthVec = zeros(kicksToSave,1);
    for jj = 1:kicksToSave
        psi = multTimeStep*psi;
        preWidth = (((1:sites) - sites/2)'.^2 ).*(abs(psi).^2);
        widthVec(jj) = sqrt(sum(preWidth));
        
    end
    
    widthMat(:,ii) = widthVec;
end
xVec = ((0:step:kickNo-1)+step)';

figure(654);
% pt1 = subplot(1,2,1);
thisP = zeros(2,size(widthMat,2));
for ii = 1:size(widthMat,2)
    plot(xVec,widthMat(:,ii),'linewidth',2);
    set(gca,'YScale','log');
    set(gca,'XScale','log');
    thisP(:,ii) = polyfit(log(xVec),log(widthMat(:,ii)),1);
    plot(xVec,exp(thisP(2,ii)).*(xVec.^(thisP(1,ii))));
    hold on;
end
hold off;
set(gca,'fontsize',14);
xlabel('Kick No');
ylabel('RMSD, \sigma');
title('Floquet Kicking');
end


end
