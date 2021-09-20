% ii = 1; j = 20; % nice fit

% ii = 15; j = 15; % nice fit, middling peak height
% 
% ii = 6; j = 14; % nice fit, low peak height
% 
% ii = 6; j = 18; % no obvious central peak, wide fit
ii = 6; j = 20; % very low peak height, decent fit
% ii = 6; j = 21; % garbage

tic
for ii = 1:length(avgRD)
    for j = 1:length(avgRD{ii})

    data = avgRD{ii}(j).summedODy;
    fitted = avgRD{ii}(j).fitData_y;

    x = (1:length(data))*2;

    plot(x,data);
    hold on;
    plot(x,fitted);


    smdata = movmean(data,5);

    plot(x, smdata, 'k')

    noise = data - smdata;

    data_noise_remov = data - noise;

    plot(x, noise, 'Color', [1 1 1]*0.2)

    set(gcf, 'Position',[2641, 376, 833, 651])
    hold off;

    SNR(ii,j) = snr(data_noise_remov, noise);
    
    end
end
toc


%%

figure()
pColorCenteredGrid( gca, lambda, Ts_unitless, SNR );
colormap(viridis);
hc = colorbar;
xlabel('\lambda');
ylabel('T');
ylabel(hc,'SNR','FontSize',12)
set(gcf, 'Position',[2684, 450, 560, 420]);
