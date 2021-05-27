function [lambda] = calc_lambda_gaussian(s1,s2,FWHM)
%Compute the total lambda when the 915 power is varied as a gaussian. This
%means that Delta is not going to be varying as a gaussian and therefore
%has to be computed numerically in time.
% INPUTS: s1 primary lattice depth in Er
%         s2 secondary lattice depth in it's own Er
%         FWHM full width half max of gaussian pulse
% OUTPUTS: lambda the integral of lambda vs time, effectively the impulse.
% Given in units of (Er of primary lattice)*(us)

startTime = -4*FWHM;
endTime = 4*FWHM;
points = 1000;

sigma = FWHM/(2*sqrt(2*log(2)));
%time mesh
xVec = linspace(startTime,endTime,points);
%915 power vs time
yVec = s2*exp(-(xVec.^2)./(2*sigma^2));

deltas = zeros(size(xVec));


for ii = 1:length(xVec)
    %calculate delta vs time (as 915 is changing)
    [~,deltas(ii)] = J_Delta_PiecewiseFit(s1,yVec(ii));
end


%numerically integrate Delta vs time to find lambda:
lambda = trapz(xVec,deltas);
end

