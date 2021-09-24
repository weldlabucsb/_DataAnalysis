clearvars -except Data

analysis_dir = ...
    "G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\KickedAA_Paper_Figures\kickedaa_decay_rates";
cd(analysis_dir);

if ~exist('Data','var')
    cd("data")
    disp("Loading data...");
    load(uigetfile("*.mat"));
    disp("Data loaded!");
    cd ..;
end

% if ~exist('Data','var')
%     disp("Loading data...");
%     load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\KickedAA_Paper_Figures\kickedaa_decay_rates\data\decayRateData_3-9.mat");
%     disp("Data loaded!");
% end

runDatas = Data.RunDatas;

outputDir = fullfile(analysis_dir,"figures/pulse-antipulse");


%%

DatesList = strcat(...
    num2str(Data.RunProperties.Year),"-",...
    num2str(Data.RunProperties.Month),"-",...
    num2str(strjoin(string(Data.RunProperties.Day),", ")));

fitFigDir = fullfile(outputDir,strcat("fits - ",DatesList));
fitFigDir = strrep(strrep(fitFigDir,", ",","),": ",", -");

%%

% plotTimeSeries = true;
% plotDecayFits = true;

plotTimeSeries = 0;
plotDecayFits = 0;

invertT = 0;
invertRate = 0;
errbars = 1;

shadErrBars = false;
shadColor = [0 0 1];

smoothDataPreFit = false;
SmoothWindow = 0;

%%

varied_var = 'LatticeHold';
dependent_var = 'gaussAtomNumber_y';

% vars we want to keep in the repeat-averaging
fns = {'summedODy','cloudSD_y','gaussAtomNumber_y'};

%% options for timeseries plots
options.FontSize  = 20;
options.LegendFontSize = 16;
options.TitleFontSize = 20;
options.Position = [-1078, 784, 1078, 854];
options.SkipLegend = true; 
options.yLabel = "Atom Number (Gauss Y)";
options.yUnits = "(a.u.)";
options.xLabel = "Lattice Hold Time";
options.xUnits = "(ms)";
legendvars = [];
heldVars = {{"T","tau","Lattice915VVA"}}; % held vars

%% Options for main fig
labelFontSize = 30;
titleFontSize = 32;
legendFontSize = 24;
dotSize = 10;
Tcutoff = 250; % max T to plot the decay rate for in us
lineWidth = 2;

decayRateConvert = 1e3;
interpreter = 'tex';

%%

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
[~,~,pixelsize,mag] = paramsfnc('ANDOR');
xConvert = pixelsize/mag * 1e6;

% allTheTs = cellfun( @(x) x.ncVars, runDatas);

%% Avg the rest of the repeats

clear avgRDs
for ii = 1:length(runDatas)
   avgRDs{ii} = avgRepeats(runDatas(ii),varied_var,fns);
   for j = 1:length(avgRDs{ii})
       avgRDs{ii}(j).T = runDatas{ii}.ncVars.T;
       avgRDs{ii}(j).tau = runDatas{ii}.ncVars.tau;
   end
end

%% plot and fit

days = Data.RunProperties.Day;
labels = [];
colors = [];
cN = 0;

cmap = colormap(parula(cN));

%%

thisDay = runDatas{1}.Day;
nRDs = length(avgRDs);
k = 1;
for ii = 1:nRDs
% for ii = 40:nRDs
    
    dens{ii} = arrayfun(@(x) x.summedODy, avgRDs{ii}, 'UniformOutput', false);
    atomNumber{ii} = arrayfun(@(x) x.(dependent_var), avgRDs{ii});
    holdtimes{ii} = arrayfun(@(x) x.(varied_var), avgRDs{ii});
    x{ii} = ( 1:length(dens{ii}) ) * xConvert;
    
    if smoothDataPreFit
        atomNumber{ii} = movmean( atomNumber{ii}, SmoothWindow );
    end
    
    lastDay = thisDay;
    thisDay = runDatas{ii}.Day;
    
    thisL = length(avgRDs{ii});
    
    if thisDay == 24
       excludedIdx = [1:3, (thisL - 2):thisL]; 
    end
    
    if lastDay ~= thisDay
       k = k + 1; 
    end
        
    [thisFit, gof{ii}] = kickedAA_decayFit(holdtimes{ii}, atomNumber{ii},...
        'ExcludedIndices', excludedIdx);
    fit{ii} = thisFit;
    
    thisConfInt = confint(thisFit);
    thisConfInt = thisConfInt(:,2);
    yneg{k}(ii) = abs(thisFit.b - thisConfInt(1));
    ypos{k}(ii) = abs(thisConfInt(2) - thisFit.b);
    
    decay_rate{k}(ii) = - thisFit.b;
    tauValues{k}(ii) = runDatas{ii}.ncVars.tau;
    
    disp(strcat("Fit ", num2str(ii), "/", num2str(nRDs), " complete."));
    
    if plotTimeSeries
        figH = figure(1);
        
        plot(holdtimes{ii}, atomNumber{ii}, 'o', 'Color', 'k');
        [ptitle{ii}, fig_filnam] = ...
            setupPlotWrap( ...
                figH, ...
                options, ...
                runDatas{ii}, ...
                dependent_var, ...
                varied_var, ...
                legendvars, ...
                heldVars);
        
        if plotDecayFits
            hold on;

            plot(holdtimes{ii}, thisFit(holdtimes{ii}), '-k');
            
            plot(holdtimes{ii}(excludedIdx), atomNumber{ii}(excludedIdx), 'rX', ...
                'HandleVisibility', 'off',...
                'LineWidth',2,...
                'MarkerSize',14)
            
            exponentLabel = {"Fit: $N \propto \exp(- r \hspace{1mm} t)$";...
                strcat("$r = ", num2str(-10^4*decay_rate{k}(ii),'%1.2f'),...
                " \times 10^{-4} \hspace{1mm} (\mathrm{ms}^{-1})$")};
            
            annotation('textbox',[0.65 0.6 0.2 0.2],'String',exponentLabel,...
                'FitBoxToText','on','Interpreter','latex',...
                'HorizontalAlignment','center',...
                'FontSize',16)
            hold off;
        end
    end
    
    if exist('figH')
        saveFigure(figH, fig_filnam, fitFigDir, 'SaveFigFile', 1);
        close(figH);
    end
    
end



%% order data

if invertT
    for ii = 1:length(decay_rate)
        tauValues{ii} = 1 ./ tauValues{ii};
        tauValues{ii} = tauValues{ii} * 1e3; % 1/us to kHz 
    end
end

for ii = 1:length(decay_rate)
    [tauValues{ii},idx] = sort(tauValues{ii});
    decay_rate{ii} = decay_rate{ii}(idx);
    yneg{ii} = yneg{ii}(idx);
    ypos{ii} = ypos{ii}(idx);
end

%% Average the points (and handle errorbars) where T is the same

% dup_Ts = [50, 90];
% 
% for ii = 1:length(dup_Ts)
%     idx = find(tauValues{1} == dup_Ts(ii));
%     tauValues{1}(idx( 2:end )) = [];
%     
%     yneg{1}(idx(1)) = rssq( yneg{1}(idx) );
%     yneg{1}( idx( 2:end ) ) = [];
%     
%     ypos{1}(idx(1)) = rssq( ypos{1}(idx) );
%     ypos{1}( idx( 2:end ) ) = [];
%     
%     decay_rate{1}( idx(1) ) = mean( decay_rate{1}(idx) );
%     decay_rate{1}( idx(2:end) ) = [];
% end

%% plot fit results

decayRate_figH = figure();

for ii = 1:length(decay_rate)
% for ii = [3,4]  

    if ~errbars
        p = plot( tauValues{ii}, decay_rate{ii} * decayRateConvert, 'o',...
            'Color', 'k');
        p.LineWidth = lineWidth;
    else
        p = errorbar(tauValues{ii}, decay_rate{ii} * decayRateConvert,...
            yneg{ii} * decayRateConvert, ypos{ii} * decayRateConvert, ...
            'o', 'Color', 'k');
        p.LineWidth = lineWidth;
    end
    
    
    if shadErrBars

        errvec{ii} = [ yneg{ii}; ypos{ii} ];

        %     p = shadedErrorBar(tauValues{ii}, decay_rate{ii}, errvec{ii}, ...
        %         'lineprops', 'ok');
        p = shadedErrorBar(tauValues{ii}, decay_rate{ii}, errvec{ii}, ...
            'lineprops', {'o','Color',shadColor}, ...
            'patchSaturation', 0.3);
    end
     
    p.MarkerSize = dotSize;
    hold on;
end

set(decayRate_figH, 'Position', [2561, 224, 1920, 963]);

set(gca, 'FontSize', 20);

% lgnd = legend(strcat("3/",labels),...
%     'Interpreter',interpreter,...
%     'FontSize',legendFontSize,...
%     'Location','northeast');

% if invertT
%     indepvarname = "Inverse Kick Period";
%     indep_tagend = " $T^{-1}$";
% else
%     indepvarname = "Kick Period";
%     indep_tagend = " T";
% end

% if invertRate
%     depvarname = "Decay Time Constant";
%     dep_tagend = " \tau (s)";
% else
%     depvarname = "Decay Rate";
%     dep_tagend = " (s^{-1})";
% end

if invertT
    xlabel("Inverse Kick Period T^{-1} (kHz)",...
        'FontSize',labelFontSize,...
        'interpreter',interpreter);
%     xlim([0,50.1])
else
    xlabel("Kick Width \tau (us)",...
        'FontSize',labelFontSize,...
        'interpreter',interpreter);
    xlim([0,13.5]);
end

ylabel("Decay Rate (s^{-1})",...
    'FontSize',labelFontSize,...
    'interpreter',interpreter);

if invertT
    mainFigTitle2 = {"Decay Rate vs. Inverse Kick Width";DatesList};
    mainFigTitle = "Decay Rate vs. Inverse Kick Width";
else
    mainFigTitle2 = {"Decay Rate vs. Kick Width";DatesList};
    mainFigTitle = "Decay Rate vs. Kick Width";
end

% mainFigTitle2 = { strcat(depvarname," vs. ",indepvarname);DatesList };
% mainFigTitle = strcat(depvarname," vs. ",indepvarname);

title(mainFigTitle,...
    'Interpreter',interpreter,...
    'FontSize',titleFontSize);

xtickformat('%1.0f')
ytickformat('%1.1f')

figFilNam = strcat(strrep(strjoin(string(mainFigTitle2)),'$',''),".png");
figFilNam = strrep(strrep(figFilNam,", ",","),": ","-");

saveFigure(decayRate_figH, figFilNam, outputDir, 'SaveFigFile', 1, 'FileType', '.png');

%%

function out = latexToTex(in)
    out = strrep(in,"$","");
end