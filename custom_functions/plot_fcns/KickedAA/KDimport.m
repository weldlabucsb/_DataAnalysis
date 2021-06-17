function [V0s,vvas,ErPerV] = KDimport()
%KDIMPORT this is to make importing the relevant KD values straightforward
[file,path] = uigetfile('*.mat','Please select most recent KD');
KDatomdata = load(fullfile(path,file));
KDatomdata = KDatomdata.atomdata;
clear V0s; clear vvas; 
V0s = [KDatomdata(:).V0];
for ii = 1:length(KDatomdata)
    vvas(ii) = KDatomdata(ii).vars.Lattice915VVA; 
end

ErPerV = KDatomdata(1).fitKD.B;
end

