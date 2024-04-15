function [seed] = SeedSelection(X,Y)
lambda = 0.8; 
numNeigh1 = 6;
K = numNeigh1;
tau      = 0.2; 
%%
Xt = X';Yt = Y';
vec=Yt-Xt;
d2=vec(1,:).^2+vec(2,:).^2;
%%  iteration 1
% % % constructe K-NN by kdtree
kdtreeX = vl_kdtreebuild(Xt);
kdtreeY = vl_kdtreebuild(Yt);  
[neighborX, ~] = vl_kdtreequery(kdtreeX, Xt, Xt, 'NumNeighbors', numNeigh1+3) ;
[neighborY, ~] = vl_kdtreequery(kdtreeY, Yt, Yt, 'NumNeighbors', numNeigh1+3) ;
% % % calculate the locality costs C and return binary vector p
[~, L] = size(neighborX);
C = 0;
vx = vec(1, :); vy = vec(2, :);
Km = K+2 : -2 : K-2;%:K-4;
M  = length(Km);
neighborXOrigin = neighborX;   
neighborYOrigin = neighborY;
for KK = Km
neighborX = neighborXOrigin(2:KK+1, :);   
neighborY = neighborYOrigin(2:KK+1, :);
neighborIndex = [neighborX; neighborY];
index = sort(neighborIndex);
temp1 = diff(index);
temp2 = (temp1 == zeros(size(temp1, 1), size(temp1, 2)));
d2i = d2(index);
vxi = vx(index); vyi = vy(index);
%% cost calculation
%**** 
%*****
cos_sita = (vxi.*repmat(vx,size(vxi,1),1) + vyi.*repmat(vy,size(vyi,1),1)) ./ sqrt(d2i.*repmat(d2,size(d2i,1),1));
ratio = min(d2i, repmat(d2,size(d2i,1),1)) ./ max(d2i, repmat(d2,size(d2i,1),1));
% for stability
% cos_sita = (vxi.*repmat(vx,size(vxi,1),1) + vyi.*repmat(vy,size(vyi,1),1)) ./ (sqrt(d2i.*repmat(d2,size(d2i,1),1))+1e-6);
% ratio = min(d2i, repmat(d2,size(d2i,1),1)) ./ (max(d2i, repmat(d2,size(d2i,1),1))+1e-6);
c2i = cos_sita.*ratio > tau.*ones(size(ratio, 1), size(ratio, 2));
c2i0 = c2i(1:end-1, :).*temp2;
c2 = sum(c2i0);
C = C+ c2/KK;%
end
seed = find((C./M) >= (1-lambda).*ones(1,L));%C/M
