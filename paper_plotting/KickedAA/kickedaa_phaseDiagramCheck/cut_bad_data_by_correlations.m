close all;

tiles = 0;

if tiles
    tiledlayout(2,3,'Padding','loose','TileSpacing','loose');
    set(gcf, 'Position',[2870, 410, 1131, 623]);
end
% set(gcf, 'Position',[2672, 794, 691, 362]);

%%

markerSize = 30;
marker = '.';
% NaNcolor = [0 0 0]/255;
% NaNcolor = 0.2 * [1 1 1];
NaNcolor = [1 1 1];

%%

meanCenterPos = mean( rmoutliers(centerPos(:)) );


if data_date == "2-27"
    centerPosTol = 12; % in um
    minimumSNR = 14;
elseif data_date == "6-15"
    centerPosTol = 6; % in um
    minimumSNR = 14;
end

%%


if tiles
    nexttile(2);
else
    figure();
    set(gcf, 'Position',[-573, 1041, 560, 420]);
end

scatter( widths(:), centerPos(:) - meanCenterPos, markerSize, marker )
set(gca,'XScale','log');

xlabel("Width (\mum)");
ylabel("center position (rel. to mean) (\mum)");

hold on;

over = (meanCenterPos - centerPosTol) < centerPos;
under = centerPos < (meanCenterPos + centerPosTol);
logi = over & under;

w2 = widths(logi);
c2 = centerPos(logi);

scatter( w2(:), c2(:) - meanCenterPos, markerSize, 'r', marker)

yylim = ylim;
ylim( yylim*1.1 );

if abs(yylim(2) - yylim(1)) > 600
   ylim([-200,200]) 
end

xxlim = xlim;
rectangle('Position',[xxlim(1), -centerPosTol, (xxlim(2) - xxlim(1)) 2*centerPosTol],...
    'FaceColor',[0.5 0 0 0.15]);

hold off;

%%


if tiles
    nexttile(1);
else
    figure();
    set(gcf, 'Position',[-1135, 1041, 560, 420]);
end

scatter( avgMaxima(:), centerPos(:) - meanCenterPos, markerSize, marker )
set(gca,'XScale','log');

xlabel("Avg maximum summedODy");
ylabel("center position (rel. to mean) (\mum)");

hold on;
m2 = avgMaxima(logi);
scatter( m2(:), c2(:) - meanCenterPos, markerSize, 'r', marker );
% % set(gca,'XScale','log');
hold off;

yylim = ylim;
ylim( yylim*1.1 );

if abs(yylim(2) - yylim(1)) > 600
   ylim([-200,200]) 
end

xxlim = xlim;
xxlim = xxlim * 1.1;
xlim(xxlim);
rectangle('Position',[xxlim(1) -centerPosTol (xxlim(2) - xxlim(1)) 2*centerPosTol],...
    'FaceColor',[0.5 0 0 0.15]);
% set(gca,'XScale','log');

%%

if tiles
    nexttile(3);
else
    figure();
    set(gcf, 'Position',[-1135, 535, 560, 420]);
end

widthsPlot = widths;
widthsPlot(~logi) = NaN;

% nexttile(2,[2 1]);

% h8 = pcolor(lambda_axis,Ts_unitless_axis,widthsPlot);
% h8 = pColorCenteredGrid(gca,lambda,Ts_unitless,widthsPlot*1e6);
h8 = pColorCenteredNonGrid(gca,lambda,Ts_unitless,widthsPlot*1e6,1e-6,1e-6);
set(h8,'EdgeColor','none');
set(gca,'color',NaNcolor);

colormap(usacolormap_exp_final);
hc = colorbar;
caxis([5,55]);

ylabel(hc,'\sigma (\mum)','FontSize',12)
xlabel('\lambda');
ylabel('T');

hAx = gca;
hAx.YAxis.Exponent=0;
hAx.YDir = 'normal';

%%

if tiles
    nexttile(4);
else
    figure();
    set(gcf, 'Position',[-573, 535, 560, 420]);
end

scatter( centerPos(:), SNR(:), markerSize, marker)
set(gca,'YScale','log');
% set(gca,'XScale','log');
% 
xlim( [500, 800] )

ylabel("SNR")
xlabel("Center Position (\mum)")

yylim = ylim;
% ylim( yylim*1.1 );
ylim( [5,yylim(2)*1.1] )
yylim = ylim;

% rectROI = drawrectangle(gca);
% centerPosLims = rectROI.Position(1) + [0,rectROI.Position(3)];
% SNRlims = rectROI.Position(2) + [0,rectROI.Position(4)];

centerPosLims = meanCenterPos + centerPosTol*[-1,1];
SNRlims = [minimumSNR,Inf];

rpos = [centerPosLims(1), SNRlims(1), centerPosLims(2) - centerPosLims(1), yylim(2) - SNRlims(1)];
rectangle( 'Position', rpos, 'FaceColor', [1 0 0 0.2])

center_over = centerPos > centerPosLims(1);
center_under = centerPos < centerPosLims(2);
center_logi = center_over & center_under;

SNR_over = SNR > SNRlims(1);
SNR_under = SNR < SNRlims(2);
SNR_logi = SNR_over & SNR_under;

net_SNRandCenter_logi = center_logi & SNR_logi;

hold on;
cpos2 = centerPos(net_SNRandCenter_logi);
SNR2 = SNR( net_SNRandCenter_logi);

scatter( cpos2(:), SNR2(:), markerSize, marker, 'r');
hold off;

%%

% ww2 = widths( net_SNRandCenter_logi );
% 
% if tiles
%     nexttile(5)
% else
%     figure();
%     set(gcf, 'Position',[3212, 225, 560, 420]);
% end
% 
% 
% scatter( widths(:)*1e6, SNR(:), markerSize, marker)
% hold on;
% scatter( ww2(:)*1e6, SNR2(:), markerSize, marker, 'r');
% hold off;
% set(gca,'YScale','log');
% set(gca,'XScale','log');
% 
% ylabel("SNR")
% xlabel("Width (\mum)")
% 
% yylim = ylim;
% ylim( [5,yylim(2)*1.1] )

%%

dens2 = avgMaxima( net_SNRandCenter_logi );

if tiles
    nexttile(5)
else
    figure();
    set(gcf, 'Position',[-1135, 29, 560, 420]);
end


scatter( avgMaxima(:), SNR(:), markerSize, marker)
hold on;
scatter( dens2(:), SNR2(:), markerSize, marker, 'r');
hold off;
set(gca,'YScale','log');
set(gca,'XScale','log');

ylabel("SNR")
xlabel("Avg maximum summedODy")

yylim = ylim;
ylim( [5,yylim(2)*1.1] )


%%

if tiles
    nexttile(6);
else
    figure();
    set(gcf, 'Position',[-573, 29, 560, 420]);
end

widths_SNRandCenter = widths;
widths_SNRandCenter(~net_SNRandCenter_logi) = NaN;

h9 = pColorCenteredNonGrid(gca,lambda,Ts_unitless,...
    widths_SNRandCenter*1e6,1e-6,1e-6);
set(h9,'EdgeColor','none');
set(gca,'color',NaNcolor);

colormap(usacolormap_exp_final);
hc = colorbar;
caxis([5,55]);

ylabel(hc,'\sigma (\mum)','FontSize',12)
xlabel('\lambda');
ylabel('T');

hAx = gca;
hAx.YAxis.Exponent=0;
hAx.YDir = 'normal';


%%

copygraphics(gcf)