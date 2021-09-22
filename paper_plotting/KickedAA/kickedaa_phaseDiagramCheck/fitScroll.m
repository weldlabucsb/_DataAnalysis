h = figure(4);

% for ii = 1:length(RunDatas)
%     for j = 1:length(RunDatas{ii}.Atomdata)

for ii = 1:length(avgRD)
    for j = 1:length(avgRD{ii})
        
%         rmse(ii,j) = checkGOF( avgRD.summedODy, RunDatas{ii}.Atomdata(j).fitData_y);
        
%         plot(RunDatas{ii}.Atomdata(j).summedODy);
        plot(avgRD{ii}(j).summedCropODy);
        set(h,'Position',[-894, 432, 560, 420]);
        hold on;
%         plot(RunDatas{ii}.Atomdata(j).fitData_y);
        plot(avgRD{ii}(j).cropFitData_y);
        hold off;
        ylim([-100,3000]);
%         title( [strcat("ii = ", num2str(ii), ", j = ", num2str(j),...
%             ", rmse = ", num2str(rmse(ii,j))) ;
%             strcat("gAtomNy = ", num2str(RunDatas{ii}.Atomdata(j).gaussAtomNumber_y),...
%             ", cloudSDy = ", num2str(RunDatas{ii}.Atomdata(j).cloudSD_y)) ] );
        title( [strcat("ii = ", num2str(ii), ", j = ", num2str(j)) ;
            strcat("cloudSDy = ", num2str(RunDatas{ii}.Atomdata(j).cloudSD_y)) ] );
        keyboard;
        
    end
end

% imagesc(