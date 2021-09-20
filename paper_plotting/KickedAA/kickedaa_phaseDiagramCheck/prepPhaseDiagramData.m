clear;

%%

% 2/27
% load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\kickedaa_phaseDiagramCheck\kickedaa_2-27_small_phasemap\2-27_phase_map_data.mat");

% 6/15
load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\kickedaa_phaseDiagramCheck\kickedaa_6-15_phasemap\data_compiled_on_27-Aug-2021.mat");
GaussianFWHM_us = 313; 

%% Colormaps

% NaNcolor = [0 150 0]/255;
% % NaNcolor = [200 0 200]/255;

load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\kickedaa_phaseDiagramCheck\kickedaa_6-15_phasemap\usacolormap_exp_final.mat");

%% Data Date
 
RunDatas = Data.RunDatas;

rdlist = runDateList(RunDatas);
rdlist = split(rdlist,' - ');
rdlist = rdlist(1);

data_date = unique(cellfun(@(rd) strcat(num2str(rd.Month),"-",num2str(rd.Day)), RunDatas));

%% Threshold values

% gAtomNlow = 3e3;
% gAtomNhi = 1e5;
% 
% if data_date == "2-27"
%     width_threshold = 6e-5;
%     max_thresholdAmplitude = 210;
%     thresholdAmplitude = 200;
% elseif data_date == "6-15"
%     width_threshold = 6e-5;
%     max_thresholdAmplitude = 210;
%     thresholdAmplitude = 200;
% end

%% Constants

hbar = 1.0545718e-34; % J * sec
kg_per_amu = 1.66054e-27; % amu/kg
mSr_amu = 84; % amu
lambda_1064 = 1064e-9; % m
k_1064 = 2*pi/lambda_1064;

mSr_kg = mSr_amu * kg_per_amu;

Er_1064 = (hbar^2 * k_1064^2)/(2*mSr_kg); % "J per Er"

hbar_Er1064 = hbar / Er_1064; % units of Er * seconds
hbar_Er1064_us = hbar_Er1064 * 1e6;

% hbar_Er1064 = 7.578e-5; %Units of Er*seconds
% hbar_Er1064_us = 75.78; %hbar in units of Er*microseconds

%% s1, J

s1 = 10;
[J,~] = J_Delta_PiecewiseFit(s1,0);
the_J = J;

%%

KD_path_6_15 = "X:\StrontiumData\2021\2021.06\06.15\11 - 915 kd with good scope\atomdata.mat";
KDatomdata6_15 = load(KD_path_6_15); KDatomdata6_15 = KDatomdata6_15.atomdata;

%%

if data_date == "2-27"
    T_convert_to_us = 1;
elseif data_date == "6-15"
    T_convert_to_us = 1000;
end

Ts = cellfun(@(rd) rd.ncVars.T, RunDatas) * T_convert_to_us;

tau_us = unique(cellfun(@(rd) rd.ncVars.tau, RunDatas));
tau = tau_us*J/hbar_Er1064_us;

%%

vars_to_avg = {'summedODy','cloudSD_y','fitData_y','Delta','gaussAtomNumber_y',...
    'cloudCenter_y'};

%%

[Ts_sorted, sort_idx] = sort(Ts);
[Ts_unique, unique_idx] = unique(Ts_sorted);

RDs_sorted = RunDatas(sort_idx);

for ii = 1:length(unique_idx)
    
    if ii < length(unique_idx)
       idx_for_this_T = unique_idx(ii):(unique_idx(ii+1)-1);
    else
       idx_for_this_T = unique_idx(ii):length(RunDatas);
    end
    RunDatas_with_this_T = RDs_sorted(idx_for_this_T);
    
    [avgRD{ii}, ~] = avgRepeats( RunDatas_with_this_T, ...
        'Lattice915VVA',vars_to_avg);
    
    for j = 1:length(avgRD{ii})
        avgRD{ii}(j).T = Ts_unique(ii);
    end
    
    vvas = [avgRD{ii}.Lattice915VVA];
    
    if data_date == "2-27"
        s2_vector = vva_to_depth(vvas);
    elseif data_date == "6-15"
        s2_vector = VVAtoEr(vvas,'KDAtomdata',KDatomdata6_15);
    end
    
    for j = 1:length(avgRD{ii})
        
        s2 = s2_vector(j);
        
        
        if data_date == "2-27"
            [J, Delta] = J_Delta_PiecewiseFit(s1,s2);
            Lambda = Delta * tau / J;
        elseif data_date == "6-15"
            J = the_J;
            Lambda = calc_lambda_gaussian(s1,s2,GaussianFWHM_us)/(hbar_Er1064_us);
        end
            
        avgRD{ii}(j).s2 = s2;
        avgRD{ii}(j).J = J;
%         avgRD{ii}(j).Delta = Delta;
        avgRD{ii}(j).Lambda = Lambda;
        
    end
   
end

%% make data into matrix for plotting

for ii = 1:length(avgRD)
   for j = 1:length(avgRD{ii})
      widths(ii,j) = avgRD{ii}(j).cloudSD_y;
      gatomNy(ii,j) = avgRD{ii}(j).gaussAtomNumber_y;
      maxima(ii,j) = max(avgRD{ii}(j).summedODy);
      avgMaxima(ii,j) = avgAroundMax( avgRD{ii}(j).summedODy, 3 );
      centerPos(ii,j) = avgRD{ii}(j).cloudCenter_y * 1e6;
      
      Ts_unitless(ii,j) = avgRD{ii}(j).T * J / hbar_Er1064_us;
      lambda(ii,j) = avgRD{ii}(j).Lambda;
      
      summedODys{ii,j} = avgRD{ii}(j).summedODy;
      
      SNR(ii,j) = compute_kaa_snr(avgRD{ii}(j));
   end
end

lambda_axis = lambda(1,:);
Ts_unitless_axis = Ts_unitless(:,1);

%%

function SNR = compute_kaa_snr(avgAD, options)

    arguments
        avgAD
    end
    arguments
       options.movmeanWindow = 5 
    end
    
    data = avgAD.summedODy;
    fitted = avgAD.fitData_y;

    x = 1:length(data);
    smdata = movmean(data,options.movmeanWindow);

    noise = data - smdata;

    data_noise_remov = data - noise;

    SNR = snr(data_noise_remov, noise);

end