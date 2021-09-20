% save('T1000-tau10-pulseData.mat','RunDataLib','RunDatas','RunVars')

%%

varied_var = RunVars.varied_var;

ptitle = plotTitle(RunDatas,'mixOD',varied_var,RunVars.heldvars_all);

%%

mixODfig = figure(1);
tiledlayout(3,1,'TileSpacing','none','Padding','none');
set(mixODfig,'Position',[835, 317, 560, 686]);
clf;

for ii = 1:3
    nexttile;
    
    [figHandles] = mixOD(RunDatas{ii},RunVars,'WrapPlot',0,...
        'FigureHandle',mixODfig,...
        'FontSize',9,...
        'TickLabelFontSize',9,...
        'Interpreter','tex',...
        'PlotEvery',1,...
        'HeightCropOD',205,...
        'ShiftYPixels',23);
    
    if ii == 1
        ca = caxis();
    else
        caxis(ca);
    end
%     
%     if ii ~= 3
%        xlabel("") 
%        xticklabels("")
%     end
    
    pt = RunDatas{ii}.ncVars.PulseType;
    
    switch pt
        case {'S','s'}
            pulsetype(ii) = "Square";
        case {'G','g'}
            pulsetype(ii) = "Gaussian";
        case {'F','f'}
            pulsetype(ii) = "Filtered";
    end
    
%     title(pulsetype(ii),'Interpreter','latex','FontSize',14)

    colormap(JetWhite);
    caxis([0,3.3]);   
    
end

vpos = [0.82, 0.53, 0.24];

for ii = 1:3
    annotation('textbox',[0.5 vpos(ii) 0.1 0.1],...
        'String',pulsetype(ii),...
        'HorizontalAlignment','center',...
        'VerticalAlignment','middle',...
        'FitBoxToText',1,...
        'Color','w',...
        'EdgeColor','w',...
        'FontSize',9)
end

% colormap(inferno)


sgtitle(ptitle,'Interpreter','latex','FontSize',9);

%%

fns = {"atomNumber","cloudSD_y","gaussAtomNumber_y","summedODy"};

for ii = 1:length(RunDatas)
   [avg_rds{ii},varied_var_vals{ii}] = avgRepeats(RunDatas{ii},varied_var,fns);
end

%%

% [idx,tf] = listdlg('PromptString','Choose a dependent quantity to plot.',...
%     'SelectionMode','single','ListString',fns);

%%

% plot2 = figure(2);
% clf;
% 
% for ii = 1:length(avg_rds)
%     
%     thedata = [avg_rds{ii}.(fns{idx})];
%     [plotme, tf] = rmoutliers( thedata );
%     my_x_axis = [varied_var_vals{ii}];
%     my_x_axis = my_x_axis( ~tf );
%     
%     plot( my_x_axis , plotme, '-o', 'LineWidth', 2 );
%     hold on;
% end
% 
% ptitle2 = plotTitle(RunDatas,fns{idx},varied_var,RunVars.heldvars_all);
% title(ptitle2,'Interpreter','latex','FontSize',14);
% legend(pulsetype,'Interpreter','latex','FontSize',14);

%%

savedir = 'G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\KickedAA_pulseCompare\kickedaa_decay_rates_compare_samples\figs';

ptitle = plotTitle(RunDatas,'MixOD','LatticeHold',{'T','tau'});

filname = filenameFromPlotTitle(ptitle);
saveas(mixODfig,fullfile(savedir,filname));

filname = filenameFromPlotTitle(ptitle,'FileType','.fig');
saveas(mixODfig,fullfile(savedir,filname));
