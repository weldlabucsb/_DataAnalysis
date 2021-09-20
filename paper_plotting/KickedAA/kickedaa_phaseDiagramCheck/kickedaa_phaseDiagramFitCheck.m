if ~exist('RunDatas','var')
    RunDatas = Data.RunDatas;
end

rdlist = runDateList(RunDatas);
rdlist = split(rdlist,' - ');
rdlist = rdlist(1);

%%

% gif_path = "E:\Data\kickedaa_3-23_small_phasemap\3-23_fit_gif.gif";
gif_path = "E:\Data\kickedaa_2-27_small_phasemap\2-27_fit_gif.gif";
% gif_path = "E:\Data\kickedaa_6-15_phasemap\6-15_fit_gif.gif";
frame_rate = 10;

%%

N = sum( cellfun(@(rd) numel(rd.Atomdata), RunDatas) );
frame_t = 1/frame_rate;


%%

fitDatas = cellfun(@(rd) cell2mat(arrayfun(@(ad) ad.fitData_y, rd.Atomdata, 'UniformOutput',0)) ,RunDatas, 'UniformOutput',0);
densities = cellfun(@(rd) cell2mat(arrayfun(@(ad) ad.summedODy, rd.Atomdata, 'UniformOutput',0)) ,RunDatas, 'UniformOutput',0);
lambdas = cellfun(@(rd) cell2mat(arrayfun(@(ad) ad.vars.Lambda, rd.Atomdata, 'UniformOutput',0)) ,RunDatas, 'UniformOutput',0);

% Ts = cellfun(@(rd) cell2mat(arrayfun(@(ad) ad.vars.Scope_CH2_DeltaT, rd.Atomdata, 'UniformOutput',0)) ,RunDatas, 'UniformOutput',0);
Ts = cellfun(@(rd) rd.ncVars.T, RunDatas);

widths = cellfun(@(rd) cell2mat(arrayfun(@(ad) ad.cloudSD_y * 1e6, rd.Atomdata, 'UniformOutput',0)) ,RunDatas, 'UniformOutput',0); 

xConvert = 2; % um per pixel

h = figure(1);
set(h,'Position',[-655, 511, 560, 420]);
frameN = 1;

for ii = 1:length(fitDatas)
    for j = 1:size(fitDatas{ii},1)
        x = (1:length(fitDatas{ii}(j,:)))*xConvert;
        plot(x,densities{ii}(j,:),'.');
        hold on;
        plot(x,fitDatas{ii}(j,:),'--');
        
        [maxy,maxidx] = max(fitDatas{ii}(j,:));
        line( x(maxidx) + [-1,1]*widths{ii}(j), maxy*[1,1]/2 , 'Color', 'k', 'LineWidth', 2);
        
        hold off;
        title({strcat("Data from ", rdlist);['T = ',num2str(Ts(ii),'%2.0f'),', lambda = ',num2str(lambdas{ii}(j))]});
%         keyboard;

        frame = getframe(h);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if frameN == 1
            imwrite(imind,cm,gif_path,'gif', 'Loopcount',inf,'DelayTime',frame_t);
        else
            imwrite(imind,cm,gif_path,'gif','WriteMode','append','DelayTime',frame_t);
        end
        frameN = frameN + 1;
    end
end