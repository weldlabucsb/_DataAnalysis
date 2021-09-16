function [V0s,vvas,ErPerV] = KDimport(path,file)
%KDIMPORT this is to make importing the relevant KD values straightforward
if (nargin < 2)
    [file,path] = uigetfile('*.mat','Please select most recent KD');
end
KDatomdata = load(fullfile(path,file));
KDatomdata = KDatomdata.atomdata;
clear V0s; clear vvas; 
V0s = [KDatomdata(:).V0];
for ii = 1:length(KDatomdata)
    vvas(ii) = KDatomdata(ii).vars.Lattice915VVA; 
end

ErPerV = KDatomdata(1).fitKD.B;
end

