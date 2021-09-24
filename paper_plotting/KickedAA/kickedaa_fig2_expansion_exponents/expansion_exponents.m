
% or find .mat file at 
% https://drive.google.com/file/d/1SAaJGxrP92hoWPFSXiFi-Towi2Pw3_Dx/view?usp=sharing
%
% Runs 3.23 - 22 23 24 25 26 27 28 29
%%

T_us = RunDatas{1}.ncVars.T;
tau_us = RunDatas{1}.ncVars.tau;
s1 = 10;

[J, ~] = vva_to_delta(s1,0);

hbar_Er1064 = 7.578e-5; %Units of Er*seconds
hbar_Er1064_us = 75.78; %hbar in units of Er*microseconds

tau = tau_us*J/hbar_Er1064_us;
T = T_us*J/hbar_Er1064_us;

%%

vars = {'cloudSD_y','LatticeHold'};
for ii = 1:length(RunDatas)
    avg_atomdata{ii} = avgRepeats(RunDatas{ii},'Lattice915VVA',vars);
end

%%

for ii = 1:length(avg_atomdata)
    latticeHolds(:,ii) = [avg_atomdata{ii}.LatticeHold];
    widths(:,ii) = [avg_atomdata{ii}.cloudSD_y];
    lattice915VVA(:,ii) = [avg_atomdata{ii}.Lattice915VVA];
end

for ii = 1:size(latticeHolds,2)
    tAD{ii}.LatticeHold = latticeHolds(ii,:);
    tAD{ii}.cloudSD_y = widths(ii,:);
    
    vva = unique(lattice915VVA(ii,:));
    tAD{ii}.Lattice915VVA = vva;
    
    [J, Delta] = vva_to_delta(s1,vva);
    tAD{ii}.J = J;
    tAD{ii}.Delta = Delta;
    
    tAD{ii}.tau_us = tau_us;
    tAD{ii}.T_us = T_us;
    tAD{ii}.tau = tau;
    tAD{ii}.T = T;
    
    lambda = Delta*tau/J;
    tAD{ii}.lambda = lambda;
    
    tAD{ii}.lambdaOverT = lambda / T;
end

%% Compute the fits

idx0 = 4;
for ii = 1:length(tAD)
    y = log( tAD{ii}.cloudSD_y );
    t = log( tAD{ii}.LatticeHold );
%     fits{ii} = polyfit( t(idx0:end), y(idx0:end), 1 );
    
    [fitresult, gof] = lineFit(t(idx0:end), y(idx0:end),'Plot',0);
    
    exponent = fitresult.p1;
    
    conf = confint(fitresult);
    conf = conf(:,1);
    
    errbars = [abs(exponent - conf(1)); abs(conf(2) - exponent)];

    tAD{ii}.exponent = fitresult.p1;
    tAD{ii}.errbars = errbars;
end
    
%% Plot the exponents

for ii = 1:length(tAD)
    yneg_errbar(ii) = tAD{ii}.errbars(1);
    ypos_errbar(ii) = tAD{ii}.errbars(2);
end

exponents = cellfun(@(x) x.exponent, tAD);
lambda = cellfun(@(x) x.lambda, tAD);
lambdaOverT = cellfun(@(x) x.lambdaOverT, tAD);

for ii = 1:length(tAD)
   plotwidths(ii) = tAD{ii}.cloudSD_y(end);
end

shape = 'o';
% shape = '--o';

h = figure(10);
clf;

yyaxis left;

% plot(lambdaOverT,exponents,'--ok','LineWidth',1);
errorbar( lambdaOverT, exponents, ...
    yneg_errbar, ypos_errbar,...
    shape);

hold on;
ylim([0,0.9]);

xline(2,'Color','k','LineWidth',1);

xlabel("\lambda/T");
ylabel("Expansion Exponent (\gamma, defined as \sigma(t) \propto t^\gamma)")

ptitle = plotTitle(RunDatas,'Expansion Exponent \gamma',"\lambda/T");
title(ptitle);

yyaxis right;

plot(lambdaOverT,plotwidths*1e6,shape);
ylabel("Cloud width \sigma measured at t = 2 s")

hold off;

%%

saveas(h,filenameFromPlotTitle(ptitle));
saveas(h,filenameFromPlotTitle(ptitle,'FileType','.fig'));

%%

function [J, Delta] = vva_to_delta(s1,vva)
    
    s2 = vva_to_depth(vva);
    [J, Delta]  = J_Delta_PiecewiseFit(s1,s2);
    
end

function depth = vva_to_depth(vva)
    secondaryErPerVolt = 12.54;
    secondaryPDGain = 1;
    
    depth = vva_to_voltage(vva)*secondaryErPerVolt/secondaryPDGain;
end


function voltage = vva_to_voltage(vva)
%for the 2/27 data
V0s = [0.0297611340889169,0.0320000000016725,0.0360000000000222,0.0620546063258612,0.0719909967293660,0.100286258828503,0.132132920348285,0.160270640980708,0.194334313681227,0.216658564267728,0.230893463124005,0.254476729560220,0.267785474698420,0.284191264615461,0.300403320122237,0.316392760370631,0.335449780883353,0.341275399292686,0.355480424302642,0.370968685011421,0.386239458185895,0.393433865352977,0.408399987686944];
vvas = [1,1.80000000000000,1.90000000000000,2,2.10000000000000,2.20000000000000,2.40000000000000,2.60000000000000,2.80000000000000,3,3.10000000000000,3.30000000000000,3.40000000000000,3.60000000000000,3.80000000000000,4,4.20000000000000,4.40000000000000,4.70000000000000,5,5.50000000000000,6,7.50000000000000];


voltage = interp1(vvas,V0s,vva);
end

function [fitresult, gof] = lineFit(t, y, options)

arguments
    t
    y
end
arguments
    options.Plot = 1
end

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( t, y );

% Set up fittype and options.
ft = fittype( 'poly1' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );

% Plot fit with data.
if options.Plot
    figure(99);
    h = plot( fitresult, xData, yData );
    legend( h, 'y vs. t', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
    % Label axes
    xlabel( 't', 'Interpreter', 'none' );
    ylabel( 'y', 'Interpreter', 'none' );
    grid on
end

end