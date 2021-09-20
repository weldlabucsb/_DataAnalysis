load("G:\My Drive\_WeldLab\Code\_Analysis\pulses\pulseoutput\TruncFiltGaussian_sqrtAmplitude-0.51322_T-1000_tau-10_samprate-1e+07Hz\TruncFiltGaussian_sqrtAmplitude-0.51322_T-1000_tau-10_samprate-1e+07Hz.mat");

%%

pulsePlotFig = figure(2);
set(pulsePlotFig,'Position',[-826, 631, 340, 434]);
% tiledlayout(3,1,'TileSpacing','none');
clf;

%%

t0 = 10*tau_us*1e6;

% nexttile;
subplot(3,1,1);
plot(Nt*1e6,Y_square,'LineWidth',2,'Color','k');
xlim([-1.05,1.05]*t0);
yLim = ylim;
ylim([-0.005,1.1]);


% nexttile;
subplot(3,1,2)
plot(Nt*1e6,Y_gauss,'LineWidth',2,'Color','k');
xlim([-1.05,1.05]*t0);
ylim([-0.005,0.9]);

% nexttile;
subplot(3,1,3);
plot(Nt*1e6,Y_truncated,'LineWidth',2,'Color','k');
xlim([-1.05,1.05]*t0);
xlabel('Time (us)');
yLim = ylim;
ylim([-0.005, 0.335]);
% ylim(yLim);