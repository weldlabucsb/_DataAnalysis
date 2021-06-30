function [band,quasimomentum] = calcQuasiTrans(depth,transEnergy)
%CALCQUASITRANS Summary of this function goes here
%   Given a transition energy in Er, find the quasimomentum and the band
%   that this happens at. Search the first 10 bands. Assume starting at
%   ground band. Depth is in recoils, as is the transitionEnergy
%   OUPTUTS: band is the excited band that accomodates the transition. 1 is
%   first excited, 2 is second excited (i.e. starting at ground = 0). 
%   quasimomentum is the quasimomentum (in units of k_l, the lattice laser
%   light). Therefore is it between [-1,1)
%   OUTPUTS ARE -1 IF TRANSITION IS NOT ALLOWED
if nargin < 2
    depth = 10;
    transEnergy = 5.74; %recoils
end
n = 31;
V = depth;
q = linspace(-1,1,300);
[E,ck] = bloch1D(V,q,n);

%find the energy differences from the ground band to excited bands
E = -repmat(E(1,:),9,1) + E(2:10,:);
%make sure that the transition is possible at all, i.e. it lies with the
%difference between the gound and some excited band
transitionPossible = 0;
band = -1;
quasimomentum = -1;
for ii = 1:9
    lowerEnergy = min(E(ii,:),[],'all');
    upperEnergy = max(E(ii,:),[],'all');
    if (transEnergy > lowerEnergy)&&(transEnergy < upperEnergy)
        transitionPossible = 1;
    end
end
if(transitionPossible)
        %difference from the energy value
    E = abs(E-transEnergy); 
    [~,I] = min(E,[],'all','linear');
    [row,col] = ind2sub(size(E),I);
    band = row;
    quasimomentum = q(col);
end


% figure(1);
% hold on;
% for ii = 2:10
%     plot(q,E(ii,:));
% end
% keyboard;


end

