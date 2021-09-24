cmax = 3;
cmin = 0;

outputDir = "G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\KickedAA_Paper_Figures\kickedaa_decay_rates\figures";
expFitRunData = load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\KickedAA_Paper_Figures\kickedaa_decay_rates\figures\first_run\expfit\expFitExampleRunData.mat");
expFitRunData = expFitRunData.expFitRunData;

%%

[avgRD, varvals] = avgRepeats(expFitRunData,'LatticeHold',{'OD'});

h = figure();
set(h, 'Position', [2562, 225, 923, 579]);

% tiledlayout(1,3, 'Padding', 'none', 'TileSpacing', 'compact');
tiledlayout(1,3, 'TileSpacing', 'compact');

idx = [6, 13, 17];

height = 5/6;
xposes = linspace(0.2,0.735,3);

locs = {[xposes(1) height .1 .1], [xposes(2) height .1 .1], [xposes(3) height .1 .1]};

xoffset = 40;
yoffset = 150;

for ii = 1:length(idx)
    
    nexttile;
   imagesc( [avgRD(idx(ii)).OD] );
   
   xdim = size([avgRD(idx(ii)).OD],2);
   ydim = size([avgRD(idx(ii)).OD],1);
   
%    xlim([0,xdim] + xoffset*[1,-1]);
%    ylim([0,ydim] + yoffset*[1,-1]);
    xlim([51,71])
    ylim([165 295])
   
   if ii == 1
      ylabel('Axial Position',...
          'interpreter','tex',...
          'FontSize',24);
   end
   
   if ii == 2
      xlabel('Radial Position',...
          'interpreter','tex',...
          'FontSize',24); 
   end
   
%    if ii ~= 1
%        set(gca,'YTickLabel',[]);
%    end
   set(gca,'YTickLabel',[]);
   set(gca,'XTickLabel',[]);
   
%    title( strcat(num2str(varvals(idx(ii)))," (ms)"),...
%           'interpreter','tex',...
%           'FontSize',18); 
%   title( strcat("Lattice Hold = ",num2str(varvals(idx(ii)))," ms"),...
%       'interpreter','tex',...
%       'FontSize',16); 

    str = strcat("t = ", num2str(varvals(idx(ii)))," ms");
    annotation( 'textbox', locs{ii}, 'String', str, ...
        'FitBoxToText','on',...
        'VerticalAlignment','middle',...
        'HorizontalAlignment','center',...
        'Color','w',...
        'FontSize',16,...
        'EdgeColor','none',...
        'FontWeight','bold');
      
   
   caxis manual;
   caxis([cmin,cmax])
end

% set(gcf, 'color', 'none'); set(gca, 'color', 'none');

colormap(fake_parula);
% 
% sgtitle("Lattice Hold",...
%           'interpreter','tex',...
%           'FontSize',18); 

saveFigure(h, ...
    "ODMix_Snapshots.png" ...
    , fullfile(outputDir,"expfit"), 'SaveFigFile', 1, 'FileType', '.png');

exportgraphics(h,'ODMix_Snapshots.pdf','BackgroundColor','none','ContentType','vector')