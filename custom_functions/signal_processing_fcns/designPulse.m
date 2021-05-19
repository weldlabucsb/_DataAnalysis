function [pulse_voltage,pulse_Er,bands_power,figure_handle] = designPulse(y,T,tau,Fs,transitions_kHz,options)
% DESIGNPULSE(y,T,tau,Fs,transitions_kHz,options) takes in a function y(t)
% which represents a SINGLE pulse of width tau, to be used in a pulse train
% of period T. It is sampled at sample rate Fs (in Hz).
%
% The one-sided amplitude spectrum of a pulse train composed of y(t),
% repeated every time T, is plotted.
%
% The power present in each frequency band specified by transitions_kHz
% (specified in kHz) is computed using matlab's bandpower function, which
% if I understand correctly computes the overlap of the power with hamming
% windows over each frequency range. transitions_kHz should be specified as
% a cell array of pairs, [f1,f2], which form the edges of the frequency
% windows in question.
%
%  SIGNAL OPTIONS:
%   
%   options.Filter: can be specified as "BrickWall" to cut out all power at
%   the frequency components in the pulse train present in transitions_kHz.
%
%   options.Delta: scales the overall amplitude of the signal by a
%   constant factor.
%
%   options.SignalTruncateHalfWidth: Width (measured in tau) at which the
%   signal is truncated.
%
%  SAVING NAME OPTIONS
%
%   options.SavePath: default save folder for .mat, .csv, or .fig
%
%   options.SaveNameComment: an optional string which gets added to the
%   default savenames.
%
%  CHOOSE WHAT TO SAVE
%
%   options.VVACalibrateCSVPulse (default = false): toggles whether the
%   output pulse_voltage is scaled to account for VVA nonlinearity using a
%   KD calibration run. If false, pulse_voltage = pulse_Er.
%
%   options.SavePulseMat (default = true): toggles saving of .mat which contains the pulses,
%   parameters, etc.
%
%   options.SaveFig (default = true): toggles saving of the .fig of the analysis. Also saves
%   a .png of this.
%
%   options.SavePulseCSV (default = true): toggles saving the pulse as a CSV in the format
%   that the KeySight likes.
%
%   options.MaxCSVValue (default = 1): Amplitude is rescaled to options.MaxCSVValue
%   for maximum resolution, since the KeySight likes integers.
%
%   options.RemoveCSVZeroes (default = true): Removes zero regions around the signal to
%   reduce file size to be uploaded to KeySight.
%
%  PLOT OPTIONS:
%
%   options.ReferencePower: just a ylimit for the power plot.
%
%   options.tF: the pulse is repeated out to the time tF before analysis is
%   conducted.
%
%   options.PlotFrequencyRangekHz: right xlim for amplitude spectrum, in kHz.


arguments
    y
    T (1,1) double
    tau (1,1) double
    Fs (1,1) double
    transitions_kHz cell
end
arguments
    options.Filter = ""
    options.Delta = 1
    options.SignalTruncateHalfWidth = 16
    
    % default calibration atomdata
    options.KDAtomdataPath = "X:\StrontiumData\2021\2021.05\05.03\05 - 915 kd\atomdata.mat"
    
    % saving options
    options.SavePath = "G:\My Drive\_WeldLab\Code\spectral_engineering\output";
    options.SaveNameComment = ""
    
    options.SavePulseMat = 1
    options.SaveFig = 0
    options.SavePulseCSV = 1
    
    %
    options.VVACalibrateCSVPulse = 1;
    options.MaxCSVValue = 2^(15) - 1;
    options.RemoveCSVZeroes = 1;
    
    % plotting options
    options.ReferencePower = 6.5e-4
    options.tF = 1e-2 % signal will be duplicated to this many seconds before analysis
    options.PlotFrequencyRangekHz = 100
    
end

    Ts = 1/Fs;
    plotFreqRangekHz = options.PlotFrequencyRangekHz;
    
    %%

    Ncycles = round(options.tF/T);
    Ncycle_time = Ncycles * T;

    t_oneCycle = [0:Ts:T] - T/2;
    L_oneCycle = length(t_oneCycle);
    if mod(length(L_oneCycle)/2,2)
       t_oneCycle(end) = [];
       L_oneCycle = length(t_oneCycle);
    end

    t = [0:Ts:Ncycle_time] - T/2;
    L = length(t);
    if mod(length(t)/2,2)
       t(end) = [];
       L = length(t);
    end
    
    f = Fs*(0:(L/2))/L;
    f0 = 1/T;
    
    %%

    y_pulse0 = y(t_oneCycle);
    y_pulse0(~isfinite(y_pulse0)) = 0;
    pulse_idx = 1:length(y_pulse0);
    
    %% Fix up formatting to frequency bands
    
    transitions_kHz = transitions_kHz( cellfun(@(x) ~isempty(x), transitions_kHz) );
    transitions_kHz = cellfun(@(x) x * 1e3, transitions_kHz, 'UniformOutput',0);
    transitions_kHz = cellfun(@(c) sort(c), transitions_kHz,'UniformOutput',0);
    
    %% Filter the input waveform
    
    S = repmat(y_pulse0,1,Ncycles);
    S(~isfinite(S)) = 0;
    
    if options.Filter == "BrickWall"
       [S, ~] = brickWallFilter(S, Fs, transitions_kHz);
    elseif options.Filter == "BandStop"
        for ii = 1:length(transitions_kHz)
            
            disp(num2str(ii))
            thisWindow = transitions_kHz{ii};
            S = bandstop(S,thisWindow,Fs);
        end
    end
    
    %% 
    
    y_pulse = S(pulse_idx);
    
    cut = options.SignalTruncateHalfWidth;
%     savenote_str = strcat("zeroNegatives-flattenEdges-",num2str(cut),"tau");
    cut_cond = (t_oneCycle < -cut*tau) | (t_oneCycle > cut*tau);
    
    y_pulse( y_pulse <= 0 ) = 0;
    y_pulse( cut_cond ) = 0;
    
    %%
    
    if options.VVACalibratePulse
        [adName, adPath] = uigetfile(options.KDAtomdataPath,"Select KD calibration atomdata.");

        KDatomdata = load( fullfile(adPath,adName) ); KDatomdata = KDatomdata.atomdata;
        y_voltage = ErToVVA(y_pulse,'DefaultKDValue',0,'KDAtomdata',KDatomdata);
    else
        y_voltage = y_pulse;
    end
    
    %%
    
    pulse_Er = y_pulse;
    pulse_voltage = y_voltage;
    
    %%
    
    S = repmat(pulse_Er,1,Ncycles);
    
    %%
    
    S = gpuArray(S);
    Y = fft(S);
    
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    P1(1) = 0; %remove constant component
    
    %% compute the power in each frequency band
    
    for ii = 1:length(transitions_kHz)
        powerW(ii) = bandpower(S,Fs,transitions_kHz{ii});
    end
    powerW = gather(powerW);
    bands_power = powerW;
    
    %% Plotting
    
    %%%%%%%%%%%%%%%%%%
    
    set(groot,'DefaultAxesFontSize', 12);
    
    figure_handle = figure();
    clf;
    tiledlayout(3,1, 'Padding', 'none', 'TileSpacing', 'compact');
    set(figure_handle,'Position',[-889, 303, 703, 598]);
    
    %%%%%%%%%%%%%%%%%%
    % plot the pulse
    nexttile;
    plot(t_oneCycle*1e6,pulse_Er);
    hold on;
    plot(t_oneCycle*1e6,pulse_voltage);
    hold off;
    xlim(50*tau/2*1e6*[-1,1]);
    Ylim = ylim;
    ylim([Ylim(1),1.1*Ylim(2)])
    ylabel('y(t)');
    xlabel('t (\mus)');
    title('Pulse y(t)');
    
    leg = ["Er","Voltage"];
    lgnd = legend(leg);
    
    set(lgnd,'Location','northwest');
    
    str_Ttau = strcat("T = ",num2str(T*1e6)," us,"," \tau = ",num2str(tau*1e6)," us");
    title(leg,str_Ttau);

    %%%%%%%%%%%%%%%%%%
    % plot the amplitude spectrum with frequency Bands
    
    nexttile;
    hamColors = colormap(lines(length(transitions_kHz) + 1));
    
    for ii = 1:length(transitions_kHz)
        [fH,hammingWindow,~] = ...
            getHammingWindow(f,transitions_kHz{ii});
        renorm = max(P1) / max(hammingWindow);
        area(fH/1e3,hammingWindow * renorm,...
            'FaceColor',hamColors(ii+1,:),...
            'EdgeColor','k');
        hold on;
    end
    
    plot(f/1e3,P1,'Color',hamColors(1,:));
    title('Single-Sided Amplitude Spectrum of y(t)')
    xlabel('f (kHz)')
    ylabel('|P1(f)|')
    xlim(plotFreqRangekHz*[0,1]);
    hold off;
    
    %%%%%%%%%%%%%%%%%%
    % plot a histogram of the power in each band transition
    nexttile;
    
    pgraph = bar(powerW);
    
    ylabel('Power (W)');
    xlabel('Transition to N^{th} Excited Band');
    title('Power Spectrum of y(t): Ground Band to Nth Excited')
    
    pgraph.FaceColor = 'flat';
    for ii = 1:length(transitions_kHz)
       pgraph.CData(ii,:) = hamColors(ii+1,:);
    end
    ylim([0,options.ReferencePower]);
    
    %% Saving Things
    
    pulse_voltage_out = pulse_voltage;
    
    %%%%%%% Save Name
    
    if options.SaveNameComment ~= ""
        comment_str = strcat("_",options.SaveNameComment);
    else
        comment_str = "";
    end
    
    pulseName = strcat("pulse_",...
            "T-",num2str(T*1e6),...
            "_tau-",num2str(tau*1e6),...
            "_Delta-",num2str(options.Delta),...
            "_",options.Filter,...
            "_samprateHz-",num2str(1e9,'%1.0e'),...
            "_maxSignalV-",num2str(max(pulse_voltage_out)),...
            comment_str);
        
    %%%%%%% Pulse .mat
        
    if options.SavePulseMat
       [fname, fpath] = ...
           uiputfile( fullfile(options.SavePath, strcat(pulseName,".mat") ), ...
            "Select .mat save location.");
        save( fullfile(fpath,fname), ...
            'pulse_voltage', 'pulse_Er', 'y', ...
            'T', 'tau', 'Fs', 't_oneCycle', 'f', ...
            'transitions_kHz', 'bands_power');
    end
    
    %%%%%%% Fig, PNG
    
    if options.SaveFig
        [fname, fpath] = ...
           uiputfile( fullfile(options.SavePath, strcat(pulseName,".fig") ), ...
            "Select .fig save location.");
        saveas( figure_handle, fullpath(fpath,fname)  );
        saveas( figure_handle, strrep(fullpath(fpath,fname),".fig",".png") );
    end
    
    %%%%%%% CSV
    
    if options.SavePulseCSV
        
        thismax = max(pulse_voltage);
        newmax = options.MaxCSVValue;
        
        pulse_voltage_out = pulse_voltage_out * (newmax / thismax);
        
        if options.RemoveCSVZeroes
            findarray = logical(pulse_voltage);
            idx1 = find(findarray,1,'first');
            idx2 = find(findarray,1,'last');
            pulse_voltage_out = pulse_voltage_out(idx1:idx2);
        end
        
        pulse_voltage_out = round(pulse_voltage_out);
        
        [fname, fpath] = uiputfile( fullfile(options.SavePath, strcat(pulseName,".csv") ), ...
            "Select CSV save location.");
        
        csvwrite( fullfile(fpath, fname), pulse_voltage_out' );
        
    end
    
end

function [idx, val] = findNearest(guess, vector)
[val, idx] = min( abs(vector-guess) );
end

function [f_axis, hammingWindow, f_idx] = getHammingWindow(f,frequencyWindow)
f1_x = findNearest(min(frequencyWindow),f);
f2_x = findNearest(max(frequencyWindow),f);

L = f2_x - f1_x + 1;
f_idx = f1_x:f2_x;

f_axis = f(f_idx);
hammingWindow = hamming(L);
end