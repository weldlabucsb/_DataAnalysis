function unk = multiBlochStateX1D(V,n,q,x)
% BLOCHSTATEX1D Returns the Bloch state u_{n,q}(x)
% DEPENDENCIES: BLOCH1D
%   unk = blochStateX1D(V,n,q,x) computes the Bloch state associated with
%   quasimomentum q and band n for a cosine lattice of depth V. If q is a
%   vector, then unk is an len(x) by len(q) matrix, where each row is
%   the wavefunction at the specific quasimomentum for the given band. The
%   band index (n) should be a scalar integer.
%    x is an
%   optional position vector; if given, unk is the Bloch wavefunction
%   evaluted over x. If not, unk is an anonymous function handle
%   corresponding to u_{n,q}(x).
%   output is normalized!
if(~iscolumn(x))
    x = x';
end
if(~isrow(q))
    q = q'; %this should be fine
end
nmax = 2*n+21;
[~,v] = bloch1D(V,q,nmax);
k = 1-nmax:2:nmax-1;
vn = reshape(v(:,n,:),nmax,length(q)); %pick out the selected band
unk = zeros(length(x),length(q));
for ii = 1:nmax
%     u = @(x) u(x) + vn(ii)*exp(1i*(k(ii)+q)*x);
    unk = unk + repmat(vn(ii,:),length(x),1).*exp(1i*(repmat(q,length(x),1) + k(ii)).*repmat(x,1,length(q)));
end
%normalize
% unk = normc(unk);
%unk output has bloch states as rows (for easy dot product later)
unk = unk.';
%normalize
unk = unk./repmat(sqrt(sum(unk.*conj(unk),2)),1,length(x));
end