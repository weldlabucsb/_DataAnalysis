function  [decayFitResult, figure_handle] = kickedAA_decayFit_avgRDs(avgRD,options)
    arguments
       avgRD
    end
    arguments
       options.ExcludedIndices = 1:2
       options.ShowFitPlot = 1
       options.Position = [-822, 363, 560, 420]
       options.RemoveOutliers = 1
       options.PlotVariable = 'gaussAtomNumber_y';
    end
    
    plotvar = options.PlotVariable;
    
%     fns = {plotvar,'atomNumber'};
%     [avgRD, t] = avgRepeats(RunData,'LatticeHold',fns);
    
%     t = t/1e3;

    t = [avgRD.LatticeHold];
    tt = 0:10:3500;
    
    decayFitResult.T_us = unique([avgRD.T]);
    decayFitResult.tau_us = unique([avgRD.tau]);
    decayFitResult.PulseType = unique([avgRD.PulseType]);
    
    pt = decayFitResult.PulseType;
    
    %%
    
    y = [avgRD.(plotvar)];
    
%     if plotvar == "gaussAtomNumber_y"
%        y = y ./ [avgRD.atomNumber];
%     end
    
%     if options.RemoveOutliers
%         [y, rmidx] = rmoutliers(y);
%         t = t(~rmidx);
%     end
    
    %% Fit: 'kickedAA_decayRateFit'.
    [xData, yData] = prepareCurveData( t, y );

    % Set up fittype and options.
    ft = fittype( 'exp1' );
    excludedPoints = excludedata( xData, yData, 'Indices', options.ExcludedIndices );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 -Inf];
    opts.Robust = 'Bisquare';
    % opts.Robust = 'LAR';
    opts.StartPoint = [29618.0867505899 -0.000462330123134109];
    opts.Upper = [Inf 0];
    opts.Exclude = excludedPoints;

    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );
    
    decayFitResult.fit = fitresult;
    decayFitResult.gof = gof;
    
    %%
    
    decayFitResult.decayRate = fitresult.b;
    decayFitResult.note = "Note: decayRate given in ms^{-1}.";
    
    %%
    
%     if isfield(RunData.ncVars,'PulseType')
%         decayFitResult.PulseType = RunData.ncVars.PulseType;
%     end
    
    %%
    
    if options.ShowFitPlot
        
        figure_handle = figure(115);
%         ploty = y;
        
        plot(t, y, 'o', 'LineWidth',2);
        hold on;
        
        plot(t(options.ExcludedIndices), y(options.ExcludedIndices), 'rX', ...
                'HandleVisibility', 'off',...
                'LineWidth',2,...
                'MarkerSize',10)
            
        Y = fitresult(tt);
        plot( tt, Y, '--', 'LineWidth', 2 );
        hold off
        
        set(figure_handle,'Position',options.Position);
        
        yLim = ylim;
%         maxy = 1e5;
%         maxy = 50e-6;
%         maxy = 1e5;
        
%         if yLim(2) > maxy
%             yLim(2) = maxy;
%             ylim(yLim);
%         end
        xlim([0,max(t)]);
         ylim([0, 1e5])
        
%         pt = RunData.ncVars.PulseType;
        switch pt
        case {'S','s'}
            pulsetype = "Square";
        case {'G','g'}
            pulsetype = "Gaussian";
        case {'F','f'}
            pulsetype = "Filtered";
        end
        
%         ptitle = plotTitle(RunData,plotvar,'LatticeHold',{'T','tau'});
%         ptitle{2} = strcat( ptitle{2}, ", PulseType - ", pulsetype);
%         title(ptitle);
    end
    
end