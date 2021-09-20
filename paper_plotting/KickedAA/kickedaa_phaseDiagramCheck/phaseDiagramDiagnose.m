clear;
close all;

%%

% load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\kickedaa_phaseDiagramCheck\kickedaa_2-27_small_phasemap\2-27_phase_map_data.mat");
load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\kickedaa_phaseDiagramCheck\kickedaa_6-15_phasemap\data_compiled_on_27-Aug-2021.mat");

%%

load("G:\My Drive\_WeldLab\Code\_Analysis\kickedaa\kickedaa_phaseDiagramCheck\kickedaa_6-15_phasemap\usacolormap_exp_final.mat");

%%

% if ~exist('RunDatas','var')
RunDatas = Data.RunDatas;
% end

rdlist = runDateList(RunDatas);
rdlist = split(rdlist,' - ');
rdlist = rdlist(1);

data_date = unique(cellfun(@(rd) strcat(num2str(rd.Month),"-",num2str(rd.Day)), RunDatas));

NaNcolor = [200 0 200]/255;

gAtomNlow = 3e3;
gAtomNhi = 1e5;

if data_date == "2-27"
    width_threshold = 6e-5;
    max_thresholdAmplitude = 210;
    thresholdAmplitude = 200;
elseif data_date == "6-15"
    width_threshold = 6e-5;
    max_thresholdAmplitude = 210;
    thresholdAmplitude = 200;
end

%%

s1 = 10;
[J,~] = J_Delta_PiecewiseFit(s1,0);

hbar_Er1064 = 7.578e-5; %Units of Er*seconds
hbar_Er1064_us = 75.78; %hbar in units of Er*microseconds

%%

KD_path_6_15 = "X:\StrontiumData\2021\2021.06\06.15\11 - 915 kd with good scope\atomdata.mat";
KDatomdata6_15 = load(KD_path_6_15); KDatomdata6_15 = KDatomdata6_15.atomdata;

%%

Ts = cellfun(@(rd) rd.ncVars.T, RunDatas);

tau_us = unique(cellfun(@(rd) rd.ncVars.tau, RunDatas));
tau = tau_us*J/hbar_Er1064_us;

%%

vars_to_avg = {'summedODy','cloudSD_y','fitData_y','Delta','gaussAtomNumber_y'};

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
        s2_vector = VVAto915Er(vvas,'KDAtomdata',KDatomdata6_15);
    end
    
    for j = 1:length(avgRD{ii})
        
        s2 = s2_vector(j);
        
        [J, Delta] = J_Delta_PiecewiseFit(s1,s2);
        
        Lambda = Delta * tau / J;
        
        avgRD{ii}(j).s2 = s2;
        avgRD{ii}(j).J = J;
        avgRD{ii}(j).Delta = Delta;
        avgRD{ii}(j).Lambda = Lambda;
        
    end
   
end

%%

for ii = 1:length(avgRD)
   for j = 1:length(avgRD{ii})
      widths(ii,j) = avgRD{ii}(j).cloudSD_y;
      gatomNy(ii,j) = avgRD{ii}(j).gaussAtomNumber_y;
      maxima(ii,j) = max(avgRD{ii}(j).summedODy);
      avgMaxima(ii,j) = avgAroundMax( avgRD{ii}(j).summedODy, 3 );
      
      if (widths(ii,j)  > width_threshold)
          widths(ii,j) = NaN;
      end
      
      if avgMaxima(ii,j) < max_thresholdAmplitude
%          widths(ii,j) = NaN;
         avgMaxima(ii,j) = NaN;
      end
      
      if maxima(ii,j) < thresholdAmplitude
         maxima(ii,j) = NaN;
      end
      
      if gatomNy(ii,j) < 0 || ~( gAtomNlow < gatomNy(ii,j) < gAtomNhi )
          gatomNy(ii,j) = NaN;
      end
      
      Ts_unitless(ii,j) = avgRD{ii}(j).T * J / hbar_Er1064_us;
      lambda(ii,j) = avgRD{ii}(j).Lambda;
      
      summedODys{ii,j} = avgRD{ii}(j).summedODy;
   end
end

%%

lambda_axis = lambda(1,:);
Ts_unitless_axis = Ts_unitless(:,1);

%%

figure(1);
set(gcf,'Position',[-1078, 1029, 560, 420]);
hh = pcolor(lambda_axis,Ts_unitless_axis,widths);
set(hh,'EdgeColor','none');
set(gca,'color',NaNcolor);

% hh = imagesc(lambda_axis,Ts_unitless_axis,widths);

% pColorCenteredNonGrid(gca,lambda_axis,Ts_unitless_axis,widths);
colormap(usacolormap_exp_final);
hc = colorbar;
caxis([5,55]*1e-6)

ylabel(hc,'\sigma (m)','FontSize',12)

xlabel('\lambda');
ylabel('T');

hAx = gca;
hAx.YAxis.Exponent=0;
hAx.YDir = 'normal';

%%

figure(2);
set(gcf,'Position',[-1078, 523, 560, 420]);
% imagesc(lambda_axis,Ts_unitless_axis,log(maxima));
hh2 = pcolor(lambda_axis,Ts_unitless_axis,log(maxima));
set(hh2,'EdgeColor','none');
set(gca,'color',NaNcolor);

colormap(viridis);
h2 = colorbar;
ylabel(h2,'log(summedODy Maximum)','FontSize',12);
% ylabel(h2,'summedODy Maximum','FontSize',12);

title(strcat(data_date," Data"));
xlabel('\lambda');
ylabel('T');

hAx = gca;
hAx.YAxis.Exponent=0;
hAx.YDir = 'normal';



%%

h3 = figure(3);
set(h3,'Position',[-1078, 17, 560, 420]);
% imagesc(lambda_axis,Ts_unitless_axis,log(avgMaxima));
hh3 = pcolor(lambda_axis,Ts_unitless_axis,log(avgMaxima));
set(hh3,'EdgeColor','none');
set(gca,'color',NaNcolor);

colormap(viridis);
h2 = colorbar;
ylabel(h2,'log(summedODy Average Around Maximum)','FontSize',12);
% ylabel(h2,'summedODy Average Around Maximum','FontSize',12);

title(strcat(data_date," Data"));
xlabel('\lambda');
ylabel('T');

hAx = gca;
hAx.YAxis.Exponent=0;
hAx.YDir = 'normal';

%%

h4 = figure(4);
set(h4,'Position',[-516, 17, 560, 420]);
% imagesc(lambda_axis,Ts_unitless_axis,log(avgMaxima));
hh4 = pcolor(lambda_axis,Ts_unitless_axis,log(gatomNy));
set(hh4,'EdgeColor','none');
set(gca,'color',NaNcolor);

colormap(viridis);
h2 = colorbar;
ylabel(h2,'log(gaussAtomNumber y)','FontSize',12);
% ylabel(h2,'summedODy Average Around Maximum','FontSize',12);

caxis([8,14]);

title(strcat(data_date," Data"));
xlabel('\lambda');
ylabel('T');

hAx = gca;
hAx.YAxis.Exponent=0;
hAx.YDir = 'normal';