h = figure(4);

for ii = 1:length(RunDatas)
    for j = 1:length(RunDatas{ii}.Atomdata)
        
        rmse(ii,j) = checkGOF( RunDatas{ii}.Atomdata(j).summedODy, RunDatas{ii}.Atomdata(j).fitData_y);
        
        plot(RunDatas{ii}.Atomdata(j).summedODy);
        set(h,'Position',[-894, 432, 560, 420]);
        hold on;
        plot(RunDatas{ii}.Atomdata(j).fitData_y);
        hold off;
        ylim([-100,2000]);
        title( [strcat("ii = ", num2str(ii), ", j = ", num2str(j),...
            ", rmse = ", num2str(rmse(ii,j))) ;
            strcat("gAtomNy = ", num2str(RunDatas{ii}.Atomdata(j).gaussAtomNumber_y),...
            ", cloudSDy = ", num2str(RunDatas{ii}.Atomdata(j).cloudSD_y)) ] );
        keyboard;
%         pause(0.04);
    end
end

% imagesc(