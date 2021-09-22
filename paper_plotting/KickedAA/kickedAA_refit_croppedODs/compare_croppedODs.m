close all;

tiles = 1;
sigma_lims = 1;
lognormal_limits = 1;

if tiles
    h = figure(1);
    tiledlayout(2,3,'Padding','loose','TileSpacing','loose');
    set(gcf, 'Position',[-1037, 280, 1010, 648]);
    sgtitle(data_date)
end

%%

markerSize = 30;
marker = '.';
% NaNcolor = [0 0 0]/255;
NaNcolor = 0.2 * [1 1 1];
% NaNcolor = [1 1 1];

%%

Nsigma_threshold = 4;
lambdatol = 1e-8;
Ttol = 1e-8;

meanCenterPos = mean( rmoutliers(centerPos(:)) );
cropMeanCenterPos = mean(rmoutliers(cropCenterPos(:)));

if lognormal_limits
    
    [~,pd] = histfit2( SNR(:), 50, 'lognormal' );
    
    sigma_SNR_lognormal = pd.sigma;
    mean_SNR_lognormal = pd.mu;
    
    sigma_SNR = exp(sigma_SNR_lognormal);
    mean_SNR = exp(mean_SNR_lognormal);
    
    [~,pd] = histfit2( cropSNR(:), 50, 'lognormal' );
    
    crop_sigma_SNR_lognormal = pd.sigma;
    crop_mean_SNR_lognormal = pd.mu;
    
    % STILL NEED TO FIX PLOTTING FUNCTIONS SO THAT SELECTION IS MADE IN LOG
    % BASE INSTEAD OF LINEAR (MAYBE JUST WRITE ANOTHER FCN)
    
elseif sigma_lims && ~lognormal_limits
    sigma_SNR = std(rmoutliers(SNR(:)));
    mean_SNR = mean(rmoutliers(SNR(:)));
    
    sigma_centerPos = std(rmoutliers(centerPos(:)));
    
    sigmaTol = sigma_SNR * Nsigma_threshold;
    centerPosTol = sigma_centerPos * Nsigma_threshold;
    
    minimumSNR = max([mean_SNR - sigmaTol,5]);
    
    %
    
    crop_sigma_SNR = std(rmoutliers(cropSNR(:)));
    crop_mean_SNR = mean(rmoutliers(cropSNR(:)));
    
    crop_sigma_centerPos = std(rmoutliers(cropCenterPos(:)));
    
    crop_sigmaTol = crop_sigma_SNR * Nsigma_threshold;
    crop_centerPosTol = crop_sigma_centerPos * Nsigma_threshold;
    
    crop_minimumSNR = max([crop_mean_SNR - crop_sigmaTol,5]);
else
    if data_date == "2-27"

        if ~sigma_lims
            centerPosTol = 12; % in um
            minimumSNR = 14;
        else

        end

    elseif data_date == "6-15"
        centerPosTol = 6; % in um
        minimumSNR = 16.75;
    end
end

%%

if tiles
    nexttile(1);
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
ylim( [5,yylim(2)*1.1] )
yylim = ylim;

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

dens2 = avgMaxima( net_SNRandCenter_logi );

if tiles
    nexttile(2)
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

xxlim1 = xlim;


%%

if tiles
    nexttile(3);
else
    figure();
    set(gcf, 'Position',[-573, 29, 560, 420]);
end

widths_SNRandCenter = widths;
widths_SNRandCenter(~net_SNRandCenter_logi) = NaN;

h9 = pColorCenteredNonGrid(gca,lambda,Ts_unitless,...
    widths_SNRandCenter*1e6,lambdatol,Ttol);
set(h9,'EdgeColor','none');
set(gca,'color',NaNcolor);

colormap(usacolormap_exp_final);
hc = colorbar;
caxis([5,55]);

ylabel(hc,'\sigma (\mum)','FontSize',12)
xlabel('\lambda');
ylabel('T');
title('Standard OD Data');

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

scatter( cropCenterPos(:), cropSNR(:), markerSize, marker)
set(gca,'YScale','log');
% set(gca,'XScale','log');
% 
xlims = cropMeanCenterPos + [-1,1]*150;
xlim(xlims);

ylabel("(crop) SNR")
xlabel("(crop) Center Position (\mum)")

yylim = ylim;
ylim( [5,yylim(2)*1.1] )
yylim = ylim;

centerPosLims = cropMeanCenterPos + crop_centerPosTol*[-1,1];

SNRlims = [crop_minimumSNR,Inf];

rpos = [centerPosLims(1), SNRlims(1), centerPosLims(2) - centerPosLims(1), yylim(2) - SNRlims(1)];
rectangle( 'Position', rpos, 'FaceColor', [1 0 0 0.2])

center_over = cropCenterPos > centerPosLims(1);
center_under = cropCenterPos < centerPosLims(2);
center_logi = center_over & center_under;

SNR_over = cropSNR > SNRlims(1);
SNR_under = cropSNR < SNRlims(2);
SNR_logi = SNR_over & SNR_under;

net_SNRandCenter_logi = center_logi & SNR_logi;

hold on;
cpos2 = cropCenterPos(net_SNRandCenter_logi);
SNR2 = cropSNR( net_SNRandCenter_logi);

scatter( cpos2(:), SNR2(:), markerSize, marker, 'r');
hold off;

%%

dens2 = cropAvgMaxima( net_SNRandCenter_logi );

if tiles
    nexttile(5)
else
    figure();
    set(gcf, 'Position',[-1135, 29, 560, 420]);
end


scatter( cropAvgMaxima(:), cropSNR(:), markerSize, marker)
hold on;
scatter( dens2(:), SNR2(:), markerSize, marker, 'r');
hold off;
set(gca,'YScale','log');
set(gca,'XScale','log');

ylabel("(crop) SNR")
xlabel("(crop) Avg maximum summedODy")

yylim = ylim;
ylim( [5,yylim(2)*1.1] )

xlim(xxlim1);

%%

if tiles
    nexttile(6);
else
    figure();
    set(gcf, 'Position',[-573, 29, 560, 420]);
end

widths_SNRandCenter = cropWidths;
widths_SNRandCenter(~net_SNRandCenter_logi) = NaN;

h9 = pColorCenteredNonGrid(gca,lambda,Ts_unitless,...
    widths_SNRandCenter*1e6,lambdatol,Ttol);
set(h9,'EdgeColor','none');
set(gca,'color',NaNcolor);

colormap(usacolormap_exp_final);
hc = colorbar;
caxis([5,55]);

ylabel(hc,'\sigma (\mum)','FontSize',12)
xlabel('\lambda');
ylabel('T');
title('Cropped OD Data');

hAx = gca;
hAx.YAxis.Exponent=0;
hAx.YDir = 'normal';

%%

copygraphics(gcf)

% saveas(h,strcat(data_date,"_cropRefitCompare.png"));