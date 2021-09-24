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
%     load( fullfile(analysis_dir,'data\decayRateData_3-9_3-12.mat') );
%     disp("Data loaded!");
% end

runDatas = Data.RunDatas;

outputDir = fullfile(analysis_dir,"figures");


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
labelFontSize = 9;
titleFontSize = 9;
legendFontSize = 9;
dotSize = [7,5];
Tcutoff = 255; % max T to plot the decay rate for in us
lineWidth = 1;

decayRateConvert = 1e3;
interpreter = 'tex';

%%

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
[~,~,pixelsize,mag] = paramsfnc('ANDOR');
xConvert = pixelsize/mag * 1e6;

%% avg repeats for same T

% find which subsets have the same T

allTheTs = cellfun( @(x) x.ncVars, runDatas);

%%

% only occurs for T = 90, T = 50

% specify pairs which have the same T

% % idx = { [1,3], [13,21] };
% % 
% % % make subsets of the rundatas to be averaged
% % for ii = 1:length(idx)
% %     this_set = idx{ii};
% %     for j = 1:length(this_set)
% %         runDatasToBeAvgd{ii,j} = runDatas{this_set(j)};
% %     end
% % end

% avg repeats for subsets with same T

% % for ii = 1:size(runDatasToBeAvgd,1)
% %     tempAvgs{ii} = avgRepeats( {runDatasToBeAvgd{ii,:}} ,varied_var, fns);
% % %     avgdRunDatas.T = runDatasToBeAvgd{ii,1}.ncVars.T; % this is lazy since avgRepeats doesn't work w ncVars
% % %     avgdRunDatas.tau = runDatasToBeAvgd{ii,1}.ncVars.tau; % this is lazy since avgRepeats doesn't work w ncVars
% % end

% remove the sets we just combined into avgdRunDatas

% % for ii = 1:length(idx)
% %     this_set = idx{ii};
% %     for j = 1:length(this_set)
% %         runDatas(this_set(j)) = [];
% %     end
% % end

%% Avg the rest of the repeats

clear avgRDs
for ii = 1:length(runDatas)
   avgRDs{ii} = avgRepeats(runDatas(ii),varied_var,fns);
   for j = 1:length(avgRDs{ii})
       avgRDs{ii}(j).T = runDatas{ii}.ncVars.T;
       avgRDs{ii}(j).tau = runDatas{ii}.ncVars.tau;
   end
end

% now chuck in the ones we treated in the previous section

% % for ii = 1:length(tempAvgs)
% %     avgRDs{end+ii} = tempAvgs{ii};
% %     if isempty(avgRDs{end})
% %        keyboard;
% %     end
% % end

%%

% add one RunData from each (of the removed) set(s) onto the end for pulling the run parameters
% % for ii = 1:length(idx)
% %     runDatas{end+ii} = Data.RunDatas{ idx{ii}(1) };
% % end

% remove the mystery empty cells (these disappear when I remove the
% averaging of the rundatas together

% % etherremoveIdx = [];
% % for ii = 1:length(runDatas)
% %     if isempty(runDatas{ii})
% %         removeIdx = [removeIdx ii];
% %     end
% % end
% % for ii = 1:length(removeIdx)
% %    runDatas( removeIdx(ii) ) = []; 
% %    removeIdx = removeIdx - 1;
% % end

%% idk where the empty cell is coming from but lets remove it

% % removeIdx = [];
% % for ii = 1:length(avgRDs)
% %     if isempty(avgRDs{ii})
% %         removeIdx = [removeIdx ii];
% %     end
% % end
% % for ii = 1:length(removeIdx)
% %    avgRDs( removeIdx(ii) ) = []; 
% %    removeIdx = removeIdx - 1;
% % end

%% plot and fit

days = Data.RunProperties.Day;
labels = [];
colors = [];
cN = 0;
if any(days == 4)
    labels = [labels, "10"];
    cN = cN + 1;
end
if any(days == 6)
    labels = [labels, ""];
    cN = cN + 1;
end
if any(days == 9)
    labels = [labels, "10"];
    cN = cN + 1;
end
if any(days == 12)
    labels = [labels, "15"];
    cN = cN + 1;
end

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
    if thisDay == 4
        excludedIdx = [1:6, (thisL - 2):thisL ];
    elseif thisDay == 6
        excludedIdx = [1:6, (thisL - 2):thisL ];
    elseif thisDay == 9
        excludedIdx = [1:4, (thisL - 2):thisL ];
    elseif thisDay == 12
        excludedIdx = [1:6, (thisL - 2):thisL ];
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
    Tvalues{k}(ii) = runDatas{ii}.ncVars.T;
    
    disp(strcat("Fit ", num2str(ii), "/", num2str(nRDs), " complete."));
    
    if plotTimeSeries
        figH = figure(1);
        
        plot(holdtimes{ii}, atomNumber{ii}, 'o', 'Color', 'k');
        hold on;
        
        if plotDecayFits
            

            plot(holdtimes{ii}, thisFit(holdtimes{ii}), '-k');
            
            plot(holdtimes{ii}(excludedIdx), atomNumber{ii}(excludedIdx), 'rX', ...
                'HandleVisibility', 'off',...
                'LineWidth',2,...
                'MarkerSize',14)
            
            [ptitle{ii}, fig_filnam] = ...
            setupPlotWrap( ...
                figH, ...
                options, ...
                runDatas{ii}, ...
                dependent_var, ...
                varied_var, ...
                legendvars, ...
                heldVars);
            
%             if invertRate
%                 exponentLabel = {"Fit: $N \propto \exp(- t / \tau )$";...
%                     strcat("$r = ", num2str(-10^4*decay_rate{k}(ii),'%1.2f'),...
%                     " \times 10^{-4} \hspace{1mm} (\mathrm{ms}^{-1})$")};
%             else
%                 exponentLabel = {"Fit: $N \propto \exp(- r \hspace{1mm} t)$";...
%                     strcat("$r = ", num2str(-10^4*decay_rate{k}(ii),'%1.2f'),...
%                     " \times 10^{-4} \hspace{1mm} (\mathrm{ms}^{-1})$")};
%             end
            
%             annotation('textbox',[0.65 0.6 0.2 0.2],'String',exponentLabel,...
%                 'FitBoxToText','on','Interpreter',interpreter,...
%                 'HorizontalAlignment','center',...
%                 'FontSize',16)
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
        Tvalues{ii} = 1 ./ Tvalues{ii};
        Tvalues{ii} = Tvalues{ii} * 1e3; % 1/us to kHz 
    end
end

for ii = 1:length(decay_rate)
    [Tvalues{ii},idx] = sort(Tvalues{ii});
    decay_rate{ii} = decay_rate{ii}(idx);
    yneg{ii} = yneg{ii}(idx);
    ypos{ii} = ypos{ii}(idx);
end

%% Average the points (and handle errorbars) where T is the same

dup_Ts = [50, 90];

if ~invertT
    for ii = 1:length(dup_Ts)
        idx = find(Tvalues{1} == dup_Ts(ii));
        Tvalues{1}(idx( 2:end )) = [];

        yneg{1}(idx(1)) = rssq( yneg{1}(idx) );
        yneg{1}( idx( 2:end ) ) = [];

        ypos{1}(idx(1)) = rssq( ypos{1}(idx) );
        ypos{1}( idx( 2:end ) ) = [];

        decay_rate{1}( idx(1) ) = mean( decay_rate{1}(idx) );
        decay_rate{1}( idx(2:end) ) = [];
    end
end

%% plot fit results

decayRate_figH = figure(500); 
ax = axes(decayRate_figH,'visible','off');

shapes = ['s','o','v'];
colors = colormap(lines(length(labels)));

tiledlayout(length(labels),1, 'Padding', 'none', 'TileSpacing', 'compact');

fmat = ["%1.0f";"%1.0f"];

s1 = [10,15];
% legs = ["1st excited","2nd excited","3rd excited","4th excited","5th excited","6th excited","7th excited"];
legs = ["|g\rangle \rightarrow |1\rangle",...
    "|g\rangle \rightarrow |2\rangle",...
    "|g\rangle \rightarrow |3\rangle",...
    "|g\rangle \rightarrow |4\rangle",...
    "|g\rangle \rightarrow |1\rangle (2\gamma)",...
    "|g\rangle \rightarrow |2\rangle (2\gamma)"];

for ii = 1:length(decay_rate)
    
%     subplot(3,1,ii);
    nexttile;
% for ii = [3,4]  
    if ~invertT
        xlim([10,245]);
    else
        xlim([0,59]);
    end
    ylim([-0.2,4.2])

    if invertT
        [~,bands] = bandcalc(s1(ii));
    else
        [bands,~,higherbands] = bandcalc(s1(ii));
    end
%     band_us = cellfun(@(c) c * 2, band_us, 'UniformOutput', 0);
    
    yLim = ylim;
    clear rpos
    for j = 2:length(bands)
        x = min(bands{j});
        y = min(yLim);
        w = abs(bands{j}(2) - bands{j}(1));
        h = abs(yLim(2) - yLim(1));
        rpos{j} = [x, y, w, h];
    end
    
    x = min(bands{2}) * 2;
    y = min(yLim);
    w = abs(bands{2}(2)*2 - bands{2}(1)*2);
    h = abs(yLim(2) - yLim(1));
    rpos{end+1} = [x, y, w, h];
    
    x = min(bands{3}) * 2;
    y = min(yLim);
    w = abs(bands{3}(2)*2 - bands{3}(1)*2);
    h = abs(yLim(2) - yLim(1));
    rpos{end+1} = [x, y, w, h];
    
%     x = min(bands{4}) * 2;
%     y = min(yLim);
%     w = abs(bands{4}(2)*2 - bands{4}(1)*2);
%     h = abs(yLim(2) - yLim(1));
%     rpos{end+1} = [x, y, w, h];
    
    
%     for j = 3:length(higherbands)
%     for j = 3:3
%         x = min(higherbands{j});
%         y = min(yLim);
%         w = abs(higherbands{j}(2) - higherbands{j}(1));
%         h = abs(yLim(2) - yLim(1));
%         rpos{end+1} = [x, y, w, h];
%     end
    
%     rcolors = flip(colormap(viridis( length(bands) + 2 )));
%     rcolors = flip(colormap(viridis( length(bands) + length(higherbands) + 2 )));
%     rcolors = colormap(gray(length(bands)+length(higherbands)));
    rcolors = flip(colormap( lines(21) ));
    rcolors(:,4) = 0.7;

%     styles = ["--","-.","-",":"];
    for j = 2:length(rpos)
%         rectangle('Position',rpos{j},...
%             'FaceColor',rcolors(j,:),...
%             'LineStyle',styles(j-1),...
%             'LineWidth',1.5,...
%             'EdgeColor',rcolors(j,:)*0.9);
%             fakeline = line(NaN,NaN,'LineWidth',0.00001,'LineStyle',styles(j-1),'Color',rcolors(j,:)*0.9);
        rectangle('Position',rpos{j},...
            'FaceColor',rcolors(j,:),...
            'EdgeColor','none');
        fakeline = line(NaN,NaN,'LineWidth',4,'Color',rcolors(j,:));
        hold on
    end

    if ~errbars
        p = scatter( Tvalues{ii}, decay_rate{ii} * decayRateConvert, dotSize(ii)*3,colors(ii,:),shapes(ii));
%         p.MarkerStyle = 
    else
        p = errorbar(Tvalues{ii}, decay_rate{ii} * decayRateConvert,...
            yneg{ii} * decayRateConvert, ypos{ii} * decayRateConvert, ...
            shapes(ii), 'Color', colors(ii,:),...
            'CapSize',0,...
            'MarkerFaceColor',colors(ii,:));
        p.LineWidth = lineWidth;
        p.MarkerSize = dotSize(ii);
    end
    
    
    if shadErrBars

        errvec{ii} = [ yneg{ii}; ypos{ii} ];

        %     p = shadedErrorBar(Tvalues{ii}, decay_rate{ii}, errvec{ii}, ...
        %         'lineprops', 'ok');
        p = shadedErrorBar(Tvalues{ii}, decay_rate{ii}, errvec{ii}, ...
            'lineprops', {'o','Color',shadColor}, ...
            'patchSaturation', 0.3);
    end
    set(p,'HandleVisibility','off');
%     p.MarkerStyle = shapes(ii);
    
    hold on;
    xtickformat('%1.0f')
    ytickformat(fmat(ii))
   
%     lgnd = legend( strcat("Primary Lattice Depth: ",labels(ii), " E_r"), ...
%     'Interpreter',interpreter,...
%     'FontSize',legendFontSize,...
%     'Location','northeast');
%     title(lgnd,"Primary Lattice Depth:")
    
    if ii == 2
        [lgnd,] = legend( legs, 'FontSize', 9);


        set(lgnd,'Position',[0.647262651599783   0.252729709448977   0.251559247222115   0.290064094540401])

    end

    set(gca, 'FontSize', 9);
    
    if ii == 1
       set(gca,'XTickLabel',[]);
    else
%       xlabel(gca,"Kick Period (us)")  
    end
    
    ax = gca;
    ax.FontSize = 20;
    
    set(ax,'TickDir','out');
    set(gca,'FontSize', 9)
    set(gca,'FontName','Times New Roman')
        
    
end

set(decayRate_figH, 'Position', [-577, 889, 481, 312]);

if invertT
    mainFigTitle2 = {"Decay Rate vs. Inverse Kick Period $T^{-1}$";DatesList};
    mainFigTitle = "Decay Rate vs. Inverse Kick Period";
else
    mainFigTitle2 = {"Decay Rate vs. Kick Period $T$";DatesList};
    mainFigTitle = "Decay Rate vs. Kick Period";
end

figFilNam = strcat(strrep(strjoin(string(mainFigTitle2)),'$',''),".png");
figFilNam = strrep(strrep(figFilNam,", ",","),": ","-");

% set(gca,'Color','none')
% saveFigure(decayRate_figH, figFilNam, fullfile(outputDir, "decayrate"), 'SaveFigFile', 1, 'FileType', '.png');
% figFilNam = strrep(figFilNam,'.png','.pdf');
% exportgraphics(decayRate_figH,fullfile(outputDir, "decayrate", figFilNam),'BackgroundColor','none','ContentType','vector');

%%

function out = latexToTex(in)
    out = strrep(in,"$","");
end