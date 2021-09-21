function avgd_rundatas = ODcrop_x( avgd_rundatas, N_sigma_crop )
% ODCROP_X crops the OD to a width N_sigma_crop*cloudSD_x around the cloud
% center in the x (transverse) direction, then recomputes a gaussian fit
% and the cloud parameters. Takes a repeat-averaged avgd_rundatas that
% contains fields cloudSD_x, fitData_x, and OD.

    arguments
        avgd_rundatas
        N_sigma_crop = 4
    end
    
CameraName = 'andor';
    
%% For testing

% rds = Data.RunDatas;
% 
% vars =
% {'cloudCenter_x','cloudSD_x','OD','cloudCenter_y','cloudSD_y','summedODy','summedODx','fitData_y','fitData_x','cloudAmp_y','cloudAmp_x'};
% avgd_rundatas = cellfun(@(rds) avgRepeats(rds,'Lattice915VVA',vars), rds
% , 'UniformOutput', 0);

%%

[root_dir,camname,pixelsize,mag,photonspercount,h,lambda,c,Ephoton,gamma,Isat,res_crosssec,crosssec,kB,mSr,save_qual,ODsave_qual] = paramsfnc(CameraName);

um_per_pixel = pixelsize/mag;

%%

[~,centerIdx_x] = cellfun( @(RD) arrayfun(@(ad) ...
    max( ad.fitData_x ),...
    RD), avgd_rundatas, 'UniformOutput', 0 );

sigma_x_idx = cellfun( @(RD) arrayfun(@(ad) ...
    round(ad.cloudSD_x / (pixelsize/mag)),...
    RD), avgd_rundatas, 'UniformOutput', 0 );

cropODx = cellfun(@(RDs, centerCells, idxCells) arrayfun(@(ad, centerVec_x, idxVec) ...
    ad.OD( :, (centerVec_x - N_sigma_crop*idxVec):(centerVec_x + N_sigma_crop*idxVec) ), ...
    RDs, centerCells, idxCells, 'UniformOutput', 0), ...
    avgd_rundatas, centerIdx_x, sigma_x_idx, 'UniformOutput', 0);

for ii = 1:length(avgd_rundatas)
    tic;
    for j = 1:length(avgd_rundatas{ii})
        cropOD = cell2mat(cropODx{ii}(j));
        summedCropODx = sum(cropOD,1)*(pixelsize/mag)^2/crosssec;
        summedCropODy = transpose(sum(cropOD,2))*(pixelsize/mag)^2/crosssec;
        
        positionMeshX=(1:length(summedCropODx))*pixelsize/mag;
        positionMeshY=(1:length(summedCropODy))*pixelsize/mag;
        
        fitX = gaussian_fit(positionMeshX, summedCropODx);
        fitY = gaussian_fit(positionMeshY, summedCropODy);
        
        avgd_rundatas{ii}(j).cropOD = cropOD;
        avgd_rundatas{ii}(j).summedCropODx = summedCropODx;
        avgd_rundatas{ii}(j).summedCropODy = summedCropODy;
        
        avgd_rundatas{ii}(j).cropCloudSD_x = fitX.c1;
        avgd_rundatas{ii}(j).cropCloudSD_y = fitY.c1;
        
        avgd_rundatas{ii}(j).cropCloudCenter_x = fitX.b1;
        avgd_rundatas{ii}(j).cropCloudCenter_y = fitY.b1;
        
        avgd_rundatas{ii}(j).cropCloudAmp_x = fitX.a1;
        avgd_rundatas{ii}(j).cropCloudAmp_y = fitY.a1;
    end
    disp(['Completed cropping/fitting ' num2str(ii) '/' ...
        num2str(length(avgd_rundatas)), ' runs.']);
    toc;
end

end

function [fitresult, gof] = gaussian_fit(xx, yy)

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( xx, yy );

ampGuess = max(yy)/2;
centerGuess = xx( round(length(xx)/2) );
widthGuess = abs(( xx(end) - xx(1) ))/64;

% Set up fittype and options.
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 -Inf 0];
opts.Normalize = 'on';
% opts.Robust = 'None';
% opts.StartPoint = [918.44709665982 0.109847007276218 0.226932513257916];
opts.StartPoint = [ampGuess, centerGuess, widthGuess];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

end

