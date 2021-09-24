%computeCloudParameters
% This code projects a 2D optical density onto its x and y directions and
% fits it to a gaussian profile.

function [atomdata] = computeGaussianCloudParametersWithConstraints(atomdata,CameraName)    
    if ~isfield(atomdata, 'OD')
        atomdata=computeOD(atomdata); 
    end    
    % Params Call
    [root_dir,camname,pixelsize,mag,photonspercount,h,lambda,c,Ephoton,gamma,Isat,res_crosssec,crosssec,kB,mSr,save_qual,ODsave_qual] = paramsfnc(CameraName);

    for ii=1:length(atomdata)     
        % Params Call
%         [root_dir,camname,pixelsize,mag,photonspercount,h,lambda,c,Ephoton,gamma,Isat,res_crosssec,crosssec,kB,mSr,save_qual,ODsave_qual] = paramsfnc(CameraName);
        
        % Compute the summed atom numbers and appropriate meshes
        summedODx=sum(atomdata(ii).OD,1)*(pixelsize/mag)^2/crosssec;        
        summedODy=transpose(sum(atomdata(ii).OD,2))*(pixelsize/mag)^2/crosssec;
        
        atomdata(ii).summedODx=summedODx;
        atomdata(ii).summedODy=summedODy;

        positionMeshX=(1:length(summedODx))+atomdata(ii).ROI(3);       
        positionMeshX=positionMeshX*pixelsize/mag;
        
        positionMeshY=(1:length(summedODy))+atomdata(ii).ROI(1);        
        positionMeshY=positionMeshY*pixelsize/mag;                  
        
        summedODy(isinf(summedODy))=NaN;
        summedODx(isinf(summedODx))=NaN;
        
        maxODx = mean(positionMeshX(find(summedODx==max(summedODx))));
        maxODy = mean(positionMeshY(find(summedODy==max(summedODy))));
        atomdata(ii).maxODx=maxODx;
        atomdata(ii).maxODy=maxODy;
        
        % Get the fitting parameters        
        [fitParamsX, fitDataX]=getFitParams(positionMeshX,summedODx);
        [fitParamsY, fitDataY]=getFitParamsWithConstraints(positionMeshY,summedODy);

        % Add X Parameters
        atomdata(ii).gaussParams_x=fitParamsX;
        atomdata(ii).cloudSD_x=fitParamsX(1); %cloud standard deviation width in m
        atomdata(ii).cloudCenter_x=fitParamsX(3); %cloud position in m
        atomdata(ii).cloudAmp_x=fitParamsX(2); %gauss fit amplitude
        atomdata(ii).bkgd_x=fitParamsX(4);
        atomdata(ii).fitData_x=fitDataX;       
        
        atomdata(ii).gaussAtomNumber_x=sqrt(2*pi)*atomdata(ii).cloudSD_x*...
            atomdata(ii).cloudAmp_x/(pixelsize/mag);%total area under curve
        atomdata(ii).bkgdRemovedAtomNumber_x=sum(summedODx-atomdata(ii).bkgd_x);%subract off bkgd
        
        % Add Y Parameters
        atomdata(ii).gaussParams_x=fitParamsY;
        atomdata(ii).cloudSD_y=fitParamsY(1);
        atomdata(ii).cloudCenter_y=fitParamsY(3);
        atomdata(ii).cloudAmp_y=fitParamsY(2);
        atomdata(ii).bkgd_y=fitParamsY(4);
        atomdata(ii).fitData_y=fitDataY; 
         
        atomdata(ii).gaussAtomNumber_y=sqrt(2*pi)*atomdata(ii).cloudSD_y*...
            atomdata(ii).cloudAmp_y/(pixelsize/mag);
        atomdata(ii).bkgdRemovedAtomNumber_y=sum(summedODy-atomdata(ii).bkgd_y);     
        
        %% Make assumptions abbout the third dimension        
        atomdata(ii).cloudSD_z_FACTOR=0.5;
        atomdata(ii).cloudSD_z=atomdata(ii).cloudSD_z_FACTOR*mean([atomdata(ii).cloudSD_x,atomdata(ii).cloudSD_y]);
    end
end

 function [fitParams, fitData]=getFitParams(xData,yData)   
%     params;  
    guessSigma=(max(xData)-min(xData))/64;%was /8 on 1/10/2020 was /32 on 3/1
    guessAmplitude=max(yData(~isinf(yData)))-min(yData);  
    guessCenter=mean(xData(find(yData==max(yData))));    
    guessOffset=min(yData);
%     guessOffset=0;
    guessParams=[guessSigma guessAmplitude guessCenter guessOffset]; 
  
    [fitParams,fitData] = fitgaussian(xData,yData,guessParams);
    end

 function [fitParams, fitData]=getFitParamsWithConstraints(xData,yData)   
%     params;  
    guessSigma=(max(xData)-min(xData))/64;%was /8 on 1/10/2020 was /32 on 3/1
    guessAmplitude=max(yData(~isinf(yData)))-min(yData);  
    guessCenter=mean(xData(find(yData==max(yData))));    
    guessOffset=min(yData);
%     guessOffset=0;
    guessParams=[6.1e-06 guessAmplitude guessCenter guessOffset]; 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% This is where you put constraints
    ParamsMin=[5e-06 guessAmplitude*0.01 0.00064 guessOffset-500]; 
    ParamsMax=[20e-06 guessAmplitude*1.2 0.00070 guessOffset+500];
  
    [fitParams,fitData] = fitgaussianWithConstraints(xData,yData,guessParams,ParamsMin,ParamsMax);
%     test=0;
    end

    function [outParams, fitData] = fitgaussian(xData,yData,guesspParams)
        outParams=fminsearch(@(inParams) lsqmingetgauss(inParams,xData,yData),guesspParams);
        fitData=makeGaussianProfile(outParams,xData);    
    end
    
    function [outParams, fitData] = fitgaussianWithConstraints(xData,yData,guesspParams,ParamsMin,ParamsMax)
        outParams=fmincon(@(inParams) lsqmingetgauss(inParams,xData,yData),guesspParams,[],[],[],[],ParamsMin,ParamsMax);
        fitData=makeGaussianProfile(outParams,xData);    
    end
    
    function [RMSerror]=lsqmingetgauss(params,xData,yData)
        fitData=makeGaussianProfile(params,xData);
        yData(isinf(yData))=fitData(isinf(yData));
        yData(isnan(yData))=fitData(isnan(yData)); 
        errorData=fitData-yData;        
%         ODthreshold=3;
%         errorData(yData>ODthreshold)=0;        
        RMSerror=sqrt(sum(errorData.^2));
    end
    
    function [outData]=makeGaussianProfile(params,xData)
        sigma=params(1);
        amplitude=params(2);
        center=params(3);
        offset=params(4);
%         offset=0;
        x=xData-center;
        outData = offset + amplitude * exp(-(x.^2)./(2*(sigma^2)));
    end



