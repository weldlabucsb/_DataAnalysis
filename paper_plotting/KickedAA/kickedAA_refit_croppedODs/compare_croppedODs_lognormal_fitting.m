% close all;

tiles = 0;
% sigma_lims = 1;
logs = 0;
% manual_override_minSNR = 1;

if tiles
    h = figure(1);
    tiledlayout(1,3,'Padding','loose','TileSpacing','loose');
%     set(gcf, 'Position',[-1036, 867, 942, 288]);
    sgtitle(data_date)
end

%%

markerSize = 30;
marker = '.';
% NaNcolor = [0 0 0]/255;
NaNcolor = 0.2 * [1 1 1];
% NaNcolor = [1 1 1];

%%

if data_date == "6-15"
    Nsigma_threshold_SNR = 4;
    Nsigma_threshold_centerPos = 4;
elseif data_date == "2-27"
    Nsigma_threshold_SNR = 2;
    Nsigma_threshold_centerPos = 8;
end

lambdatol = 1e-8;
Ttol = 1e-8;

% meanCenterPos = mean( rmoutliers(centerPos(:)) );
% cropMeanCenterPos = mean(rmoutliers(cropCenterPos(:)));

if logs
    figure(2);
    [hh1,pd] = histfit2( rmoutliers(cropSNR(:)), 50, 'lognormal' );
    % [hh1,pd] = histfit2( rmoutliers(cropSNR(:)), 50, 'normal' );
%     set(gcf, 'Position',[-1036, 493, 465, 288]);
    xlabel('SNR');
    ylabel('Frequency');
    figure(1);

    sigma_SNR = pd.sigma;
    mean_SNR = pd.mu;

    sigmaTol = sigma_SNR * Nsigma_threshold_SNR;
    crop_minimumSNR = max([mean_SNR - sigmaTol,0]);
else
    mean_SNR = mean( rmoutliers( cropSNR(:) ) );
    crop_minimumSNR = 0.3 * mean_SNR;
end
    
% if manual_override_minSNR
%     crop_minimumSNR = log(5)
%     figure(2);
% end

figure(3);
[hh2,pd] = histfit2( rmoutliers(cropCenterPos(:)), 50, 'normal');
% set(gcf, 'Position',[-569, 493, 475, 288]);
xlabel('Center Position (um)');
ylabel('Frequency');
figure(1);

sigma_centerPos = pd.sigma;
mean_centerPos = pd.mu;

centerPosTol = sigma_centerPos * Nsigma_threshold_centerPos;

%%

if tiles
    nexttile(1);
else
    figure();
    set(gcf, 'Position',[-573, 535, 560, 420]);
end

if logs
    scatter( cropCenterPos(:), log(cropSNR(:)), markerSize, marker)
else
    scatter( cropCenterPos(:), cropSNR(:), markerSize, marker)
end

% 
xlims = mean_centerPos + [-1,1]*150;
xlim(xlims);

if logs
    ylabel("log(SNR)")
else
    ylabel('SNR');
end
xlabel("(crop) Center Position (\mum)")

% yylim = ylim;
% ylim( [5,yylim(2)*1.1] )
yylim = ylim;

centerPosLims = mean_centerPos + centerPosTol*[-1,1];

SNRlims = [crop_minimumSNR,Inf];

rpos = [centerPosLims(1), SNRlims(1), centerPosLims(2) - centerPosLims(1), yylim(2) - SNRlims(1)];
rectangle( 'Position', rpos, 'FaceColor', [1 0 0 0.2])

center_over = cropCenterPos > centerPosLims(1);
center_under = cropCenterPos < centerPosLims(2);
center_logi = center_over & center_under;

if logs == 1
    SNR_over = log(cropSNR) > SNRlims(1);
    SNR_under = log(cropSNR) < SNRlims(2);
else
    SNR_over = cropSNR > SNRlims(1);
    SNR_under = cropSNR < SNRlims(2);
end

SNR_logi = SNR_over & SNR_under;

net_SNRandCenter_logi = center_logi & SNR_logi;

hold on;
cpos2 = cropCenterPos(net_SNRandCenter_logi);
SNR2 = cropSNR( net_SNRandCenter_logi);

if logs
    scatter( cpos2(:), log(SNR2(:)), markerSize, marker, 'r');
else
    scatter( cpos2(:), SNR2(:), markerSize, marker, 'r');
end
hold off;

%%

dens2 = cropAvgMaxima( net_SNRandCenter_logi );

if tiles
    nexttile(2)
else
    figure();
    set(gcf, 'Position',[-1135, 29, 560, 420]);
end

if logs
    scatter( cropAvgMaxima(:), log(cropSNR(:)), markerSize, marker)
    hold on;
    scatter( dens2(:), log(SNR2(:)), markerSize, marker, 'r');
else
    scatter( cropAvgMaxima(:), cropSNR(:), markerSize, marker)
    hold on;
    scatter( dens2(:), SNR2(:), markerSize, marker, 'r');
end
hold off;
% set(gca,'YScale','log');
if logs
    set(gca,'XScale','log');
    ylabel("log(SNR)")
else
    ylabel('SNR');
end
xlabel("(crop) Avg maximum summedODy")

% yylim = ylim;
% ylim( [5,yylim(2)*1.1] )

% xlim(xxlim1);

%%

if tiles
    nexttile(3);
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