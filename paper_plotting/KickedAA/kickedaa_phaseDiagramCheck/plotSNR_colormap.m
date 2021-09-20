close all;

figure()
tiledlayout(1,3);

sgtitle(strcat("Data from ",data_date));

nexttile(1);
pColorCenteredGrid( gca, lambda, Ts_unitless, SNR );
colormap(viridis);
hc = colorbar;
xlabel('\lambda');
ylabel('T');
ylabel(hc,'SNR','FontSize',12)

nexttile(2);
pColorCenteredGrid( gca, lambda, Ts_unitless, centerPos);
colormap(viridis);
hc = colorbar;
xlabel('\lambda');
ylabel('T');
ylabel(hc,'center position','FontSize',12)
caxis([300,900])

nexttile(3);
pColorCenteredGrid( gca, lambda, Ts_unitless, avgMaxima);
colormap(viridis);
hc = colorbar;
xlabel('\lambda');
ylabel('T');
ylabel(hc,'Maximum Density','FontSize',12)

set(gcf, 'Position',[2684, 450, 1538, 420]);

copygraphics(gcf);