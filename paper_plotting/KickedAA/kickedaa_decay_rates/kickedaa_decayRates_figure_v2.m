clearvars -except Data

% data is from Runs on 3.9 - 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 54 55
%
% or download at https://drive.google.com/file/d/11Vj2v7TEuX_qPtBMQvHzvSabcQlWeAc9/view?usp=sharing

runDatas = Data.RunDatas;

%%

DatesList = strcat(...
    num2str(Data.RunProperties.Year),"-",...
    num2str(Data.RunProperties.Month),"-",...
    num2str(strjoin(string(Data.RunProperties.Day),", ")));

% fitFigDir = fullfile(outputDir,strcat("fits - ",DatesList));
% fitFigDir = strrep(strrep(fitFigDir,", ",","),": ",", -");

%%

% plotTimeSeries = true;
% plotDecayFits = true;

plotTimeSeries = 1;
plotDecayFits = 1;

invertT = 0;
invertRate = 0;
errbars = 1;

smoothDataPreFit = false;
SmoothWindow = 0;

%%

varied_var = 'LatticeHold';
dependent_var = 'cropGaussAtomNumber_y';

% vars we want to keep in the repeat-averaging
fns = {'summedODy','cloudSD_y','gaussAtomNumber_y','OD'};

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

% decayRateConvert = 1e3;
decayRateConvert = 1;
interpreter = 'tex';

%%

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
[~,~,pixelsize,mag] = paramsfnc('ANDOR');
xConvert = pixelsize/mag * 1e6;

%% avg repeats for same T

% find which subsets have the same T

allTheTs = cellfun( @(x) x.ncVars, runDatas);

%% Avg the rest of the repeats

clear avgRDs
for ii = 1:length(runDatas)
   avgRDs{ii} = avgRepeats(runDatas(ii),varied_var,fns);
   for j = 1:length(avgRDs{ii})
       avgRDs{ii}(j).T = runDatas{ii}.ncVars.T;
       avgRDs{ii}(j).tau = runDatas{ii}.ncVars.tau;
   end
end

avgRDs = ODcrop_x(avgRDs);

%% plot and fit

days = Data.RunProperties.Day;
labels = [];
colors = [];
cN = 0;
if any(days == 9)
    labels = [labels, "10"];
    cN = cN + 1;
end

cmap = colormap(parula(cN));

%%

thisDay = runDatas{1}.Day;
nRDs = length(avgRDs);
for ii = 1:nRDs
    
    dens{ii} = arrayfun(@(x) x.summedCropODy, avgRDs{ii}, 'UniformOutput', false);
    atomNumber{ii} = arrayfun(@(x) x.(dependent_var), avgRDs{ii});
    holdtimes{ii} = arrayfun(@(x) x.(varied_var), avgRDs{ii}) / 1000;
    x{ii} = ( 1:length(dens{ii}) ) * xConvert;
    
    if smoothDataPreFit
        atomNumber{ii} = movmean( atomNumber{ii}, SmoothWindow );
    end
    
    lastDay = thisDay;
    thisDay = runDatas{ii}.Day;
    
    thisL = length(avgRDs{ii});
    excludedIdx = [1:4, (thisL - 2):thisL ];
    
    if lastDay ~= thisDay
       k = k + 1; 
    end
        
    [thisFit, gof{ii}] = kickedAA_decayFit_v1(holdtimes{ii}, atomNumber{ii},...
        'ExcludedIndices', excludedIdx);
    fit{ii} = thisFit;
    
    thisConfInt = confint(thisFit);
    thisConfInt = thisConfInt(:,2);
    yneg(ii) = abs(thisFit.b - thisConfInt(1));
    ypos(ii) = abs(thisConfInt(2) - thisFit.b);
    
    decay_rate(ii) = - thisFit.b;
    Tvalues(ii) = runDatas{ii}.ncVars.T;
    
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
            hold off;
        end
    end
end


%% order data

if invertT
    for ii = 1:length(decay_rate)
        Tvalues{ii} = 1 ./ Tvalues{ii};
        Tvalues{ii} = Tvalues{ii} * 1e3; % 1/us to kHz 
    end
end

[Tvalues,idx] = sort(Tvalues);
decay_rate = decay_rate(idx);
yneg = yneg(idx);
ypos = ypos(idx);

%% Average the points (and handle errorbars) where T is the same

dup_Ts = [50, 90];

if ~invertT
    for ii = 1:length(dup_Ts)
        idx = find(Tvalues == dup_Ts(ii));
        Tvalues(idx( 2:end )) = [];

        yneg(idx(1)) = rssq( yneg(idx) );
        yneg( idx( 2:end ) ) = [];

        ypos(idx(1)) = rssq( ypos(idx) );
        ypos( idx( 2:end ) ) = [];

        decay_rate( idx(1) ) = mean( decay_rate(idx) );
        decay_rate( idx(2:end) ) = [];
    end
end

%% plot fit results

decayRate_figH = figure(500); 
ax = axes(decayRate_figH,'visible','off');

shapes = ['s','o','v'];
colors = colormap(lines(length(labels)));

tiledlayout(length(labels),1, 'Padding', 'none', 'TileSpacing', 'compact');

fmat = ["%1.0f";"%1.0f"];

s1 = 10;

% legs = ["|g\rangle \rightarrow |1\rangle",...
%     "|g\rangle \rightarrow |2\rangle",...
%     "|g\rangle \rightarrow |3\rangle",...
%     "|g\rangle \rightarrow |4\rangle",...
%     "|g\rangle \rightarrow |1\rangle (2\gamma)",...
%     "|g\rangle \rightarrow |2\rangle (2\gamma)"];

    nexttile;
    if ~invertT
        xlim([10,245]);
    else
        xlim([0,59]);
    end
    ylim([-0.2,4.2])
    
    yLim = ylim;

    if ~errbars
        p = scatter( Tvalues, decay_rate * decayRateConvert, dotSize(1)*3,colors(1,:),shapes(1));
    else
        p = errorbar(Tvalues, decay_rate * decayRateConvert,...
            yneg * decayRateConvert, ypos * decayRateConvert, ...
            shapes(1), 'Color', colors(1,:),...
            'CapSize',0,...
            'MarkerFaceColor',colors(1,:));
        p.LineWidth = lineWidth;
        p.MarkerSize = dotSize(1);
    end
    
    set(p,'HandleVisibility','off');
    
    hold on;
    xtickformat('%1.0f')
    ytickformat(fmat(ii))

    set(gca, 'FontSize', 9);
    
%     if ii == 1
%        set(gca,'XTickLabel',[]);
%     else
    
    ax = gca;
    ax.FontSize = 20;
    
    set(ax,'TickDir','out');
    set(gca,'FontSize', 9)
    set(gca,'FontName','Times New Roman')
    

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

%%

% save('decay_rate_fit_results.mat','Tvalues','decay_rate','figFilNam','fit','avgRDs','yneg','ypos','colors')

%%

function out = latexToTex(in)
    out = strrep(in,"$","");
end