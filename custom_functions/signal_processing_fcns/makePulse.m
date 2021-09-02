function [outputPulse, time_vector, powers] = makePulse(T_us, tau_us, truncated_pulsewidth_us,options)

arguments
    T_us = 250
    tau_us = 15
    truncated_pulsewidth_us = 100
end
arguments
    options.UseGPU = 0 % use GPU for FFTs. Disable if low on memory or do not have NVIDIA GPU.
    
    options.Fs = 1e7 % in Hz
    options.NSamples = 31 %
    options.PrimaryLatticeDepth = 10 % in 1064 lattice Ers.
    
    options.ExtraFilterWindows = {} % cell array of doubles, {[f1 f2], [f3 f4], ...}, where f's are in Hz. Filters in these windows.
    
    options.FigurePosition = [0,0,500,500] % where the figure is placed by default
    
    options.PeriodsGraphed = 3 % how many periods (T) of the pulse to plot.
    options.PlotAmplitudes = 1 % toggle labeling the amplitudes of each pulse on the figure.
    options.PlotBandRectangles = 1 % boolean, whether or not to plot the bands as shaded rectangles
    
    options.SaveDirectory = '.\' % default save path
    options.SkipFilePicker = 1 % if false, opens file picker for placing each saved file
    options.OpenSaveDirectory = 0 % if true, opens save directory after saving on Windows machines.
    
    options.SkipFiltering = 0
    options.SkipPulseChoiceDialog = 1 % if false, asks whether you want to save Gaussian, filtered gaussian, or truncated filtered gauss pulse.
    
    options.SaveFig = 0 % toggles saving of fig file
    options.SavePNG = 0 % only works if SaveFig = true. Toggles saving of PNG.
    options.SaveMat = 0 % toggles saving of key workspace variables to mat file.
    
    options.SaveCSV = 0 % toggles saving of pulse CSV (for upload to keysight)
    options.SquareRootCSV = 1 % toggles sqrt of pulse before saving to CSV
    options.MaxCSVValue = 2^(15) - 1 % adjust maximum CSV value (for best keysight resolution)
    options.RemoveCSVZeroes = 1 % trims zeros off the edges of the pulses.
end

    %% Argument Handling
    
    T_us = T_us * 1e-6;
    tau_us = tau_us * 1e-6;
    
    if ~mod(options.NSamples,2)
       warning('The specified sample number is not an odd number. Adding one more sample...');       options.NSamples = options.NSamples + 1;
    end

    nT = options.PeriodsGraphed; % number of periods to graph
    Fs = options.Fs; % sample rate in Hz
    NSamples = options.NSamples; % number of periods to sample for analysis
    
    %% Time Vectors, Indexing Setup
    
    Ts = 1/Fs;
    
    % build a time vector with sample rate Fs for Nsamples pulses
    Nt = (-NSamples*T_us/2):Ts:(NSamples*T_us/2); Nt(end) = []; % full-length time vector
    Nt = round(Nt,10); % round (to nearest 1/10 ns) to avoid floating point errors
    
    L = length(Nt);
    
    % make the frequency vector
    f = Fs*(0:(L/2))/L;
    
    % find the indices of the central pulse
    idx1p = round( (NSamples - 1)/2 * T_us/Ts + 1 );
    idx2p = round( idx1p + T_us/Ts - 1 );
    pulseIdx = idx1p:idx2p;
    
    % time vector for a single pulse (centered at t = 0)
    t = Nt(pulseIdx);
    
    time_vector = t;
    
    %%
    
    [~,transitions_kHz,~] = bandcalc(options.PrimaryLatticeDepth);
    transitions_kHz = transitions_kHz( cellfun(@(x) ~isempty(x), transitions_kHz) );
    transitions = cellfun(@(x) x*1e3, transitions_kHz, 'UniformOutput', 0);
    if length(transitions) > 3
        transitions = transitions(1:3);
    end
    
    %% Create Pulses and Filter
    
    % make a square pulse
    Y_square = square_pulse(T_us,tau_us,Nt);
    
    % make a gaussian pulse
    Y_gauss = gaussian_pulse(T_us,tau_us,Fs,t,NSamples);
    
    if ~options.SkipFiltering
        % filter the gaussian pulse
        Y_filt = multiBandStop(Y_gauss,transitions,Fs,'ExtraFilterWindows',options.ExtraFilterWindows);

        % zero out the negative parts of the filtered pulse
        Y_filt(Y_filt < 0) = 0;

        % Grab a single pulse from the filtered pulse train
        Y_filt_single = Y_filt( pulseIdx );

        % Rebuild the filtered pulse train from the central pulse
        % This is to avoid the distortion to the edge pulses due to finite
        % sample length.
        Y_filt = repmat( Y_filt_single, 1, NSamples);
        Y_filt = renormalizeSameArea(Y_filt, Y_gauss);
    else
        Y_filt = Y_gauss;
        Y_filt_single = Y_filt( pulseIdx );
    end
    
    %% Truncate the pulse
    
    Y_single_truncated = truncatePulse( Y_filt_single, t, truncated_pulsewidth_us );
    Y_truncated = repmat( Y_single_truncated, 1, NSamples );
    Y_truncated = renormalizeSameArea(Y_truncated, Y_gauss);
    
    %% Analyze Each Pulse
    
    [~, P1_sq, power_sq] = fourierAnalyze(Y_square,Fs,transitions,...
        'UseGPU',options.UseGPU);
    [~, P1_gauss, power_gauss] = fourierAnalyze(Y_gauss,Fs,transitions,...
        'UseGPU',options.UseGPU);
    [~, P1_filt, power_filt] = fourierAnalyze(Y_filt,Fs,transitions,...
        'UseGPU',options.UseGPU);
    [~, P1_trunc, power_trunc] = fourierAnalyze(Y_truncated,Fs,transitions,...
        'UseGPU',options.UseGPU);
    
    %% Make the Plots
    
    set(groot,'DefaultAxesFontSize', 12);

    figure_handle = figure(1);
    clf;
    tiledlayout(3,1, 'Padding', 'none', 'TileSpacing', 'compact');
    set(figure_handle,'Position',options.FigurePosition);
    
    linecolors = colormap( lines( 4 ) );
    
    %%%%% Pulse Plot %%%%%
    nexttile;
    plot(Nt*1e6,Y_square,'Color',linecolors(1,:),'LineWidth',2);
    hold on;
    plot(Nt*1e6,Y_gauss,'Color',linecolors(2,:),'LineWidth',2);
    plot(Nt*1e6,Y_filt,'Color',linecolors(3,:),'LineWidth',2);
    plot(Nt*1e6,Y_truncated,'Color',linecolors(4,:),'LineWidth',2);
    
    amplitudes.readme = "These are the amplitudes of each pulse which leave the area of each pulse the same.";
    amplitudes.square = max(Y_square);
    amplitudes.gaussian = max(Y_gauss);
    amplitudes.filtered = max(Y_filt);
    amplitudes.filtered_truncated = max(Y_truncated);
    
    if options.PlotAmplitudes
        ampstring = [...
            "Amplitudes:";
            strcat("Square: ", num2str(amplitudes.square));
            strcat("Gaussian: (", num2str(sqrt(amplitudes.gaussian)),")^2");
            strcat("Filtered: (", num2str(sqrt(amplitudes.filtered)),")^2");
            strcat("Filt, Trunc: (", num2str(sqrt(amplitudes.filtered_truncated)),")^2")];
        annotation(...
            'textbox',[0.1 0.85 0.1 0.1],...
            'String',ampstring,...
            'FitBoxToText',1,...
            'BackgroundColor','w');
    end

    title( strcat("T = ", num2str(T_us*1e6), ", \tau = ", num2str(tau_us*1e6), ", N = ", num2str(NSamples)) );
    ylabel("Pulse Amplitude");
    xlabel("Time (us)");
    xlim( [-1,1]*(nT*T_us*1e6)/2 );
    ylim([0,1.05]);
    leg = legend(["Square Pulse", "Gaussian Pulse", "Filtered Gaussian, Zeroed", ...
        strcat("Filtered Gaussian, Truncated: ", num2str( truncated_pulsewidth_us ), " us" )]);
    
    %%%%% Amplitude Spectrum Plot %%%%%
    nexttile;
    
    rectColors = flip(colormap(bone(length(transitions) + 8)));
    
    if options.PlotBandRectangles
        % prelim plot to estimate ylims
        plot(f/1e3,P1_sq,'LineWidth',2);
        hold on;
        plot(f/1e3,P1_gauss,'LineWidth',2);
        plot(f/1e3,P1_filt,'LineWidth',2);
        plot(f/1e3,P1_trunc,'LineWidth',2);
        yy = ylim;
        hold off;
        
        for ii = 1:length(transitions)
            thisBandColor = rectColors(ii+1,:);
            rectangle( 'Position', ...
                [transitions{ii}(1)/1e3, yy(1), ...
                (transitions{ii}(2) - transitions{ii}(1))/1e3, ...
                yy(2) - yy(1)],...
                'FaceColor',thisBandColor,...
                'EdgeColor',[0 0 0]);
            hold on;
        end
    end
    
    % Replot amplitude spectra so that they appear above rectangles
    plot(f/1e3,P1_sq,'LineWidth',2,'Color',linecolors(1,:));
    plot(f/1e3,P1_gauss,'-.','LineWidth',2,'Color',linecolors(2,:));
    plot(f/1e3,P1_filt,'LineWidth',2,'Color',linecolors(3,:));
    plot(f/1e3,P1_trunc,'--','LineWidth',2,'Color',linecolors(4,:));
    ylim(yy);
    
    xlabel('f (kHz)')
    ylabel('Amplitude')
    xlim(75*[0,1]);
    hold off;
    
    %%%%% Power Bar Plots %%%%%
    
    nexttile;
    powers = [power_sq; power_gauss; power_filt; power_trunc]';
    pgraph = bar(powers);
    xlim([0.5,4.5]);
    
    xticks([1 2 3 4]);
    xticklabels(["|g\rangle \rightarrow |1\rangle", ...
        "|g\rangle \rightarrow |2\rangle", ...
        "|g\rangle \rightarrow |3\rangle", ...
        "|g\rangle \rightarrow |4\rangle"]);
    
    ylabel("Power in Transition");
    xlabel("Transition from Ground Band (|g\rangle) to n^{th} Excited Band (|n\rangle)");   
    
    %% Select which pulse you want to output
    
    if ~options.SkipPulseChoiceDialog
        [choice, pulsetype] = choosePulse();

            switch choice
                case 2
                    outputPulse = Y_gauss;
                    thisamp = amplitudes.gaussian;
                case 3
                    outputPulse = Y_filt;
                    thisamp = amplitudes.filtered;
                case 4
                    outputPulse = Y_truncated;
                    thisamp = amplitudes.filtered_truncated;
            end
    else
        disp(['Dialog box skipped. Defaulting to square pulse. Choose a different option by setting option "SkipPulseChoiceDialog" to false.']);
        pulsetype = "Square";
%         thisamp = amplitudes.filtered_truncated;
%         outputPulse = Y_truncated;
        thisamp = amplitudes.square;
        outputPulse = Y_square;
    end
        
    outputPulse = outputPulse(pulseIdx);
    
    %% Saving Things
    
    %%%%%%%%%%%%%%%%%%%%%%
    
%     pulseName = strcat("pulse_",...
%             "T-",num2str(T_us*1e6),...
%             "_tau-",num2str(tau_us*1e6),...
%             "_samprate-",num2str(Fs,'%1.0e'),"Hz",...
%             "_",pulsetype,...
%             "_sqrtAmplitude-",num2str(sqrt(thisamp)));
        
    pulseName = strcat(pulsetype,...
        "_sqrtAmplitude-",num2str(sqrt(thisamp)),...
        "_T-",num2str(T_us*1e6),...
        "_tau-",num2str(tau_us*1e6),...
        "_samprate-",num2str(Fs,'%1.0e'),"Hz");
        
        
    %%%%%%%%%%%%%%%%%%%%%%
    
    if any( [options.SaveMat, options.SaveFig, options.SavePNG, options.SaveCSV])
        
        if options.SaveInSubfolder
            save_subfolder = fullfile(options.SaveDirectory, pulseName, filesep);
            if ~isfolder(save_subfolder)
                mkdir(save_subfolder);
            end
        else
            save_subfolder = options.SaveDirectory;
        end
        
    end
        
    %%%%%% save pulse mat %%%%%%
    if options.SaveMat
        if options.SkipFilePicker
            savename = fullfile(save_subfolder, strcat(pulseName,".mat") );
        else
            [fname, fpath] = ...
           uiputfile( fullfile(save_subfolder, strcat(pulseName,".mat") ), ...
            "Select .mat save location.");
            savename = fullfile(fpath,fname);
        end
        
        Y1_square = Y_square(pulseIdx);
        Y1_gauss = Y_gauss(pulseIdx);
        Y1_filtered = Y_filt(pulseIdx);
        Y1_truncated = Y_truncated(pulseIdx);
        summed_powers = powers;
        relative_amplitudes = amplitudes;
        freq_vector = f;
        transition_frequency_ranges = transitions;
       
        save( savename, ...
            'Y1_square', 'Y1_gauss', 'Y1_filtered', 'Y1_truncated', ...
            'pulseIdx', 'T_us', 'tau_us', 'truncated_pulsewidth_us', ...
            'Fs', 'Nt', 'time_vector', 'freq_vector', ...
            'transition_frequency_ranges', 'summed_powers', 'relative_amplitudes');
    end
    
    %%%%%% Saving Figure %%%%%%
    if options.SaveFig
        
        if options.SkipFilePicker
            savename = fullfile(save_subfolder, strcat(pulseName,".fig") );
        else
            [fname, fpath] = ...
           uiputfile( fullfile(save_subfolder, strcat(pulseName,".fig") ), ...
            "Select .fig save location.");
            savename = fullfile(fpath,fname);
        end
        
        
        saveas( figure_handle, savename  );
        if options.SavePNG
            saveas( figure_handle, strrep(savename,".fig",".png") );
        end
    end
    
    %%%%%% Saving CSV %%%%%%
    
    if options.SaveCSV
        
        % square-root waveform if specified
        if options.SquareRootCSV
           outputPulse = sqrt(outputPulse); 
        end
        
        % renormalize to get maximum resolution on Keysight
        thismax = max(outputPulse);
        newmax = options.MaxCSVValue;
        outputPulse = outputPulse * (newmax / thismax);
        
        outputPulse = round(outputPulse);
        
        if options.RemoveCSVZeroes
            findarray = logical(outputPulse);
            idx1 = find(findarray,1,'first');
            idx2 = find(findarray,1,'last');
            outputPulse = outputPulse(idx1:idx2);
        end
        
        if options.SkipFilePicker
            savename = fullfile(save_subfolder, strcat(pulseName,".csv") );
        else
            [fname, fpath] = uiputfile( fullfile(save_subfolder, strcat(pulseName,".csv") ), ...
            "Select CSV save location.");
            savename = fullfile(fpath,fname);
        end
        
        csvwrite( savename, outputPulse' );
        
    end
    
    %%
    
    if ispc
        if options.OpenSaveDirectory
            winopen(save_subfolder);
        end
    end
    
end

function [idx, val] = findNearest(guess, vector)
    [val, idx] = min( abs(vector-guess) );
end

function Y = square_pulse(T,tau,NSample_time_vector)
    ysquare = @(t) (square( 2*pi*(t+tau/2)/T, tau/T * 100 ) + 1)/2;
    Y = ysquare(NSample_time_vector);
end

function Y = gaussian_pulse(T,tau,Fs,cycle_time_vector,NSamples)

y = @(t) exp(- t.^2/( 2 * (tau/2)^2 ));

% normalize to area tau
tt = -T:(1/Fs):T; 
discY = y(tt); discY(~isfinite(discY)) = 0;
norm = trapz(tt,discY);
y2 = @(t) y(t) * (tau/norm);
yg = @(t) y2(t);

% repeat pulse to get NSamples
Y = repmat(yg(cycle_time_vector), 1,  NSamples);

end

function Y_filtered = multiBandStop(Y,frequency_ranges_Hz,Fs,options)

    arguments
        Y
        frequency_ranges_Hz
        Fs
    end
    arguments
        options.ExtraFilterWindows = {}
    end
    
    exfilt = options.ExtraFilterWindows;
    
    % get rid of empty cells
    frequency_ranges_Hz = frequency_ranges_Hz( cellfun(@(x) ~isempty(x), frequency_ranges_Hz) );
    
    Y_filtered = Y;
    
    if ~isempty(exfilt)
        for j = 1:length(exfilt)
            disp(['Filtered ' num2str(j) '/' num2str( length(exfilt) ) ' of extra frequency bands.' ])
            Y_filtered = bandstop(Y_filtered, exfilt{j}, Fs);
        end
    end
    
    for j = 1:length(frequency_ranges_Hz)
        disp(['Filtered ' num2str(j) '/' num2str( length(frequency_ranges_Hz) ) ' of specified frequency bands.' ])
        Y_filtered = bandstop(Y_filtered, frequency_ranges_Hz{j}, Fs);
    end
end

function Y_single_truncated = truncatePulse( Y_single, cycle_time_vector, truncated_pulsewidth_us )

    % find the indices corresponding to where we want to truncate
    truncate_edge = truncated_pulsewidth_us/2*1e-6;
    idx1t = findNearest(-truncate_edge,cycle_time_vector);
    idx2t = findNearest(truncate_edge,cycle_time_vector);
    
    Y_single_truncated = Y_single;
    Y_single_truncated( 1:idx1t ) = 0;
    Y_single_truncated( idx2t:end ) = 0;
    
end

function [fftx, amplitude_spectrum, powers] = fourierAnalyze(Y,Fs,frequency_ranges_Hz,options)

    arguments
        Y
        Fs
        frequency_ranges_Hz
    end
    arguments
        options.UseGPU = 0
    end

    % get rid of empty cells
    frequency_ranges_Hz = frequency_ranges_Hz( cellfun(@(x) ~isempty(x), frequency_ranges_Hz) );

    % fft the input signal
    if options.UseGPU
        Y = gpuArray(Y);
    end
    fftx = fft(Y);
    thisL = length(Y);
    
    % compute two-sided amplitude spectrum
    P2 = abs(fftx/thisL);
    
    % compute one-sided amplitude spectrum
    P1 = P2(1:thisL/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    P1(1) = 0; %remove constant component
    amplitude_spectrum = gather(P1);

    % compute the power in each band using the default Hamming windows
    for jj = 1:length(frequency_ranges_Hz)
        powers(jj) = bandpower(Y,Fs,frequency_ranges_Hz{jj});
    end
    powers = gather(powers);
    
end

function [choice, answer] = choosePulse()
    answer = questdlg('Which pulse would you like to output and save to CSV?',...
        'Choose a pulse to save.',...
        'Gaussian Pulse', ...
        'Filtered Gaussian',...
        'Truncated Filtered Gaussian',...
        'Truncated Filtered Gaussian');
    
    if isempty(answer)
       answer = 'Truncated Filtered Gaussian'; 
    end
    
    switch answer
%         case 'Square Pulse'
%             disp(['Saving ' answer '...']);
%             choice = 1;
        case 'Gaussian Pulse'
            disp(['Saving ' answer '...']);
            choice = 2;
        case 'Filtered Gaussian'
            disp(['Saving ' answer '...']);
            choice = 3;
        case 'Truncated Filtered Gaussian'
            disp(['Saving ' answer '...']);
            choice = 4;
    end
    
    answer = strrep(answer,' ',"");
end

function renormed_func = renormalizeSameArea(function_in, reference_function)
    ref_area = trapz(reference_function);
    in_area = trapz(function_in);
    renormed_func = function_in * (ref_area/in_area);
end