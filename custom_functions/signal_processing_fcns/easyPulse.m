function [pulse_voltage,pulse_Er,bands_power,figure_handle] = easyPulse(T,tau,options)
% EASYPULSE(T,tau,options) generates a CSV corresponding to the specified
% pulse. T is the period of the pulse (in seconds). tau is the
% width of the pulse (in seconds).
%
% OPTIONS:
%   
%   options.Fs (default = 1e9): The sample rate of the generated pulse.
%
%   options.PulseShape (default = "Gaussian"): Specify pulse shape. Options
%   are "Square", "Bump", and "Gaussian". For power analysis, these pulses
%   are normalized to have area = tau.
%       NOTE: Gaussian pulses have standard deviation tau, while bump and
%       square pulses are nonzero only within a width tau.
%
%   options.Filter (default = "BrickWall"): Specifies the filter to be
%   used. Options are "" and "BrickWall". Brickwall filter removes all
%   frequency components in the band transitions.
%
%   options.LatticeDepth (default = 10): Specifies the 1064 lattice depth
%   in Er for which to compute the band transition frequencies.
%
%   ----- OPTIONS FROM DESIGNPULSE: -----
%
%  SIGNAL OPTIONS:
%   
%   options.Filter: can be specified as "BrickWall" to cut out all power at
%   the frequency components in the pulse train present in transitions_kHz.
%
%   options.SignalTruncateHalfWidth: Width (measured in tau) at which the
%   signal is truncated.
%
%  SAVING NAME OPTIONS
%
%   options.SavePath: default save folder for .mat, .csv, or .fig
%
%   options.SaveNameComment (default = ""): appended to filenames for
%   labeling purposes.
%
%  CHOOSE WHAT TO SAVE
%
%   options.VVACalibratePulse (default = false): toggles whether the
%   output pulse_voltage is scaled to account for VVA nonlinearity using a
%   KD calibration run. If false, pulse_voltage = pulse_Er.
%
%   options.SavePulseCSV (default = true): toggles saving the pulse as a CSV in the format
%   that the KeySight likes.
%
%   options.MaxCSVValue (default = 2^15-1): Amplitude is rescaled to options.MaxCSVValue
%   for maximum resolution, since the KeySight likes integers.
%
%   options.RemoveCSVZeroes (default = true): Removes zero regions around the signal to
%   reduce file size to be uploaded to KeySight.
%
%  OTHER OPTIONS:
%
%   options.useGPU (default = false): toggles use of GPU arrays to speed up
%   FFTs.

arguments
   T (1,1) double
   tau (1,1) double
end
arguments
    options.Fs = 1e9
    options.PulseShape = "Gaussian"
    options.Filter = "BrickWall"
    options.LatticeDepth = 10
    
    options.SaveAnalysisFigure = 1
    
    %%%%% designPulse options %%%%%%
    options.SignalTruncateHalfWidth = 16
    
    % saving options
    options.SavePath = "G:\My Drive\_WeldLab\Code\_Analysis\pulses\pulseoutput";
    
    options.SavePulseMat = 1
    options.SaveFig = 0
    options.SavePulseCSV = 1
    
    options.SaveNameComment = ""
    
    %
    options.VVACalibratePulse = 0;
    options.MaxCSVValue = 2^(15) - 1;
    options.RemoveCSVZeroes = 1;
    
    options.useGPU = 0
end

Fs = options.Fs;

%%

%%

[~,transitions,~] = bandcalc(options.LatticeDepth);

%%

filter = options.Filter;
    
%%

syms y(t)
syms t

%%%%%%%%%%%%%

if options.PulseShape == "Square" 

    y = @(t) (square( 2*pi*(t+tau/2)/T, tau/T * 100 ) + 1)/2;
    pulsetype = "square";

elseif options.PulseShape == "Bump"

    y = @(t) exp( - 1 ./ (1 - 4*( t/tau  ).^2) ) .* ( (-tau/2 < t) & (t < tau /2) );
    discY = y(tt); discY(~isfinite(discY)) = 0;
    norm = trapz(tt,discY);
    y2 = @(t) y(t) * (tau/norm);
    y = @(t) y2(t);
    pulsetype = "bump-sameArea";

elseif options.PulseShape == "Gaussian"

    y = @(t) exp(- t.^2/( 2 * (tau/2)^2 ));
    
    tt = -T:(1/Fs):T; 
 
    discY = y(tt); discY(~isfinite(discY)) = 0;
    norm = trapz(tt,discY);
    y2 = @(t) y(t) * (tau/norm);
    y = @(t) y2(t);
    pulsetype = "gauss-sameArea";
end

%%

[pulse_voltage,pulse_Er,bands_power,figure_handle] = ...
    designPulse(y,T,tau,Fs,transitions,...
    "Filter",options.Filter,...
    "SignalTruncateHalfWidth",options.SignalTruncateHalfWidth,...
    "SavePath",options.SavePath,...
    "VVACalibratePulse",options.VVACalibratePulse,...
    "SavePulseCSV",options.SavePulseCSV,...
    "MaxCSVValue",options.MaxCSVValue,...
    "RemoveCSVZeroes",options.RemoveCSVZeroes,...
    "useGPU",options.useGPU,...
    "SaveNameComment",options.SaveNameComment);

%%

if options.SaveAnalysisFigure

    if filter ~= ""
        pulsetype = strcat(pulsetype,"-",filter);
    end

    fname = strcat(pulsetype,"-T",num2str(T*1e6),...
        ",tau",num2str(tau*1e6),".png");

    saveas(figure_handle,fullfile(options.SavePath,fname));

end

%%

winopen(options.SavePath);

end