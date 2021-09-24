RedoGaussFit
fitCoeffResults = createGaussYExpFit;

% fitCoeffResult.a
fitCoeffResults.b

fitCoeffInterval = confint(fitCoeffResults);


% % % % %%%%%%%%%% Interval for a
% % % % fitCoeffInterval(1,1);
% % % % fitCoeffInterval(2,1);

%%%%%%%%%% Interval for b
fitCoeffInterval(1,2);  % lower bound for the decay rate
fitCoeffInterval(2,2);  % Upper bound for the decay rate

fitResults = [fitResults; 0 fitCoeffResults.b fitCoeffInterval(1,2) fitCoeffInterval(2,2) fitCoeffResults.b-fitCoeffInterval(1,2) fitCoeffInterval(2,2)-fitCoeffResults.b 0 0];