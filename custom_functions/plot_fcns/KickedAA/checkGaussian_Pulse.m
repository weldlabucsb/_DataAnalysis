function [] = checkGaussian_Pulse(atomdata)
% the purpose of this function is to check how good the gaussian pulses are
% in a given atomdata. The reason we want to check is potentially the
% amplifier might have some non-linearity at high RF strengths that leads
% to the pulses being mis-shaped. 

%make sure to get the right V0 and vva values
V0s = [0,0,0,0,0.0214142327406058,0.0448419166066287,0.0696651347848517,0.0976720999403696,0.123915194747385,0.150318061066050,0.175217142963462,0.203661981680046,0.229693968240054,0.256610077932329,0.278704823507391,0.298843729898948,0.322004432958256,0.343654736733345,0.352643720071468,0.372125390157261,0.386915527019837];
vvas = [0,1,1.20000000000000,1.50000000000000,2,2.50000000000000,3,3.50000000000000,4,4.50000000000000,5,5.50000000000000,6,6.50000000000000,7,7.50000000000000,8,8.50000000000000,9,9.50000000000000,10];


%run to test
toTest = 18;
tData = atomdata(toTest).scopeTrace.tData;
yData = atomdata(toTest).scopeTrace.y2Data;

%focus on the gaussian
tRange = [0.01 0.015];
include = logical((tData > tRange(1)).*(tData < tRange(2)));

x = tData(include);
y = yData(include);

y = smooth(y,3);

start = fit(x,y,'gauss1');

g = fittype(@(a,b,c,d,x) d + a*exp(-((x-b)/c).^2));
f = fit(x,y,g,'startpoint',[coeffvalues(start) 0]);

%assess the fit
% yfit = f(x);
% yresid = y - yfit;
% SSresid = sum(yresid.^2);
% SStotal = (length(y)-1)*var(y);
% rsq = 1- SSresid/SStotal;


%compute xsquared
yfit = f(x);
yresid = y-yfit;
deviations = yresid./0.01;
chisq = sum(deviations.^2);
redchisq = chisq/4;

%find the area discrepancy
traceInt = trapz(x,y-f.d);
fitInt = trapz(x,yfit-f.d);
fitdiscrep = abs((traceInt-fitInt)/traceInt);

%compute setpoint
sigma = (300*1E-6)/(2*sqrt(2*log(2)));
mean = f.b;
coeff = V0s(toTest);

yset = coeff*exp(-0.5.*((x-mean)/sigma).^2)+f.d;
setInt = trapz(x,yset-f.d);
setdiscrep = abs((setInt-traceInt)/traceInt); 

figure(1);
hold on;
plot(f,x,y);
yline(V0s(toTest)+f.d);
plot(x,yset);
hold off;
legend(['Scope Trace'],['fit, \chi^2_{\nu} = ' num2str(redchisq)],['Amplitude Setpoint'],['Predicted Output']);
title({['VVA setpt = ' num2str(vvas(toTest))],['trace/fit area discrepancy = ' num2str(fitdiscrep*100) '%'],...
    ['trace/setpoint area discrepancy = ' num2str(setdiscrep*100) '%']});
xlabel('Time, (s)');
ylabel('PD Voltage, (V)');
ax = gca;
ax.FontSize = 14;
end

