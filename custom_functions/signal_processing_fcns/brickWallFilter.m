function [y_filtered, oneSidedAmplitudeSpectrum] = brickWallFilter(y, sample_frequency, filter_frequencies)
% BRICKWALLFILTER(y, sample_frequency, filter_frequencies) filters a signal
% y sampled at sample_frequency (in Hz) by entirely cutting out the fourier
% components in the frequency windows f1<f<f2 specified by the cell array
% of 2x1 doubles [f1,f2] where f1, f2 are specified in Hz.

%% construct the frequency vector

L = length(y);
Fs = sample_frequency;
fWindows = filter_frequencies;

f2_x = Fs*((-L/2):(L/2))/L; f2_x(end) = [];

%%

fWindows = fWindows( cellfun(@(x) ~isempty(x), fWindows) );

x_fc = find(f2_x == 0);
filter_idx = cellfun(@(c) arrayfun(@(ff) findNearest(ff,f2_x), c), fWindows,'UniformOutput',0);
for ii = 1:length(filter_idx)
    for j = 1:length(filter_idx{ii})
       extraFreq(j) = 2*x_fc - filter_idx{ii}(j); 
    end
    filter_idx{ii} = sort([filter_idx{ii}, extraFreq]);
end

%% do the filtering

Yfilter = fft(y);
Yfilter = fftshift(Yfilter);

for ii = 1:length(filter_idx)
    for jj = 1:2:length(filter_idx{ii})
        Yfilter( filter_idx{ii}(jj):filter_idx{ii}(jj+1) ) = 0;
    end
end

Yfilter = ifftshift(Yfilter);

P2filter = abs(Yfilter/L);

P1filter = P2filter(1:L/2+1);
P1filter(2:end-1) = 2*P1filter(2:end-1);
P1filter(1) = 0; %remove constant component

oneSidedAmplitudeSpectrum = P1filter;

y_filtered = ifft(Yfilter);

end

function [idx, val] = findNearest(guess, vector)
    [val, idx] = min( abs(vector-guess) );
end