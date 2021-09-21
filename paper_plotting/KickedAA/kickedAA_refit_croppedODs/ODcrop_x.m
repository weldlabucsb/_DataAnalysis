function avgd_rundatas = ODcrop_x( avgd_rundatas, N_sigma_crop, um_per_pixel )

    arguments
        avgd_rundatas
        N_sigma_crop = 4
        um_per_pixel = 2
    end
    
%% For testing

% rds = Data.RunDatas;
% 
% vars = {'cloudCenter_x','cloudSD_x','OD','cloudCenter_y','cloudSD_y','summedODy','summedODx','fitData_y','fitData_x','cloudAmp_y','cloudAmp_x'};
% avgd_rundatas = cellfun(@(rds) avgRepeats(rds,'Lattice915VVA',vars), rds , 'UniformOutput', 0);

%%

[~,centerIdx_x] = cellfun( @(RD) arrayfun(@(ad) ...
    max( ad.fitData_x ),...
    RD), avgd_rundatas, 'UniformOutput', 0 );

sigma_x_idx = cellfun( @(RD) arrayfun(@(ad) ...
    round(ad.cloudSD_x * 1e6 / um_per_pixel),...
    RD), avgd_rundatas, 'UniformOutput', 0 );

cropODx = cellfun(@(RDs, centerCells, idxCells) arrayfun(@(ad, centerVec_x, idxVec) ...
    ad.OD( :, (centerVec_x - N_sigma_crop*idxVec):(centerVec_x + N_sigma_crop*idxVec) ), ...
    RDs, centerCells, idxCells, 'UniformOutput', 0), ...
    avgd_rundatas, centerIdx_x, sigma_x_idx, 'UniformOutput', 0);

for ii = 1:length(rds)
    for j = 1:length(avgd_rundatas{ii})
        avgd_rundatas{ii}(j).cropOD = cropODx{ii}(j);
    end
end

end