function [inliers,A] = TIM(X0,Y0, varargin)
% TIM
%   TIM(X0, Y0, varargin) 
%   Filtering the ourliers in the putative set of the feature
%   correspondences, using the graph-cut techniques. First TIM constructs a
%   graph based on the topology/gemoetric relationship, and then uses the
%   graph-cut to determine the inliers/outliers.

% Inputs:
%   X0 - The coordinates of the correspondences in the left (moved) image.
%       Shape: (N x 2)
%   Y0 - The coordinates of the correspondences in the right (target)
%       image. Shape: (N x 2)
%   seedMask - The mask for the correspondences seed. If not provided, you
%       can just input 0. Shape: (N x 1)
%   I1Size - The image size of the left (moved) image, used for
%       normalization. If not provided, we can infer it from X0. Example:
%       (640, 480).
%   I2Size - The image size of the right (target) image, used for
%       normalization. If not provided, we can infer it from X0. Example:
%       (640, 480).
%   lambda - Penalty of topology preservation in unary term. Default: 0.5.
%   alpha - Trade-off parameter balancing unary term and pairwise term.
%       Default: 0.95.
%   numNeigh - The size of the nearest neighborhood. Default: 15.
%   sigma - The scale of the distance weight. Default: 0.2.
%   tau - Threshold for quantifying cost. Default: 0.8.


% Outputs:
%   inliers - The mask for inliers. Shape: (N x 1)
%   A - The constructed graph by TIM. Shape: (N x N).

% Example:
%   [inliers, ~] = TIM(X0, Y0);
%   This example shows how to call the TIM

% Author: Yifan Lu
% Email: lyf048@whu.edu.cn
% Date: April 1, 2023
% Revision: 1.0
% Paper Reference: Lu, Y., Ma, J., Mei, X., Huang, J., & Zhang, X. P. (2024). 
% Feature Matching via Topology-Aware Graph Interaction Model. 
% IEEE/CAA Journal of Automatica Sinica, 11(1), 113-130. doi:10.1109/jas.2023.123774 

p = inputParser;

% Set default values for optional parameters
addParameter(p, 'lambda', 0.5);
addParameter(p, 'alpha', 0.95);
addParameter(p, 'numNeigh', 15);
addParameter(p, 'sigma', 0.2);
addParameter(p, 'tau', 0.8);
addParameter(p, 'seedMask', 0);
addParameter(p, 'I1Size', []); % default will be set based on X0 if not provided
addParameter(p, 'I2Size', []); % default will be set based on Y0 if not provided

% Parse the input
parse(p, varargin{:});

% Extract variables from the parser
lambda = p.Results.lambda;
alpha = p.Results.alpha;
numNeigh = p.Results.numNeigh;
sigma = p.Results.sigma;
tau = p.Results.tau;
seedMask = p.Results.seedMask;

% select seed matches
if seedMask == 0
    seedMatches = SeedSelection(X0,Y0);
else
    seedMatches = seedMask;
end

if isempty(p.Results.I1Size)
    I1Size = max(X0);
    I1Size = [I1Size(2), I1Size(1)];
else
    I1Size = p.Results.I1Size;
end

if isempty(p.Results.I2Size)
    I2Size = max(Y0);
    I2Size = [I2Size(2), I2Size(1)];
else
    I2Size = p.Results.I2Size;
end

%% construct graph structure
N = size(X0,1);
Xn = X0 ./ [I1Size(2),I1Size(1)];
Yn = Y0 ./ [I2Size(2),I2Size(1)];
gamma = 0.5;
M = [gamma*Xn,gamma*Yn,Yn-Xn]';
relibleNumNeigh = min(8,length(seedMatches));
kdtreeM = vl_kdtreebuild(M);
[neighborM, neighborD] = vl_kdtreequery(kdtreeM, M, M(:,seedMatches), 'NumNeighbors', numNeigh); 
nonUseEle = zeros(N,1);
lookupTable = zeros(N,1);
nonUseEle(neighborM) = 1;
UseEleIndex = find(nonUseEle);
N = length(UseEleIndex);
lookupTable(UseEleIndex) = 1:N;
% some matches are not in the neighborhood 
% list of all seed matches, so we can throw them away in the first to accelerate the processing time
neighborD = neighborD.^(1/2);
kdtreeMRelible = vl_kdtreebuild(M(:,seedMatches)); % relible neighborhood
[neighborMRelible, neighborDRelible] = vl_kdtreequery(kdtreeMRelible, M(:,seedMatches), M(:,seedMatches), 'NumNeighbors', relibleNumNeigh);
neighborMRelible = seedMatches(neighborMRelible);
A = zeros(N,N);
for i = 1:length(seedMatches)
    neighbor = neighborM(:,i); % get neighborhood of control point
    neighbord = neighborD(:,i);
    distanceDecay = exp(-neighbord/sigma);
    neighborRelible = neighborMRelible(:,i); % get neighborhood of control point
    randposition = find(neighbor == seedMatches(i));
    randpositionRelible = find(neighborRelible == seedMatches(i));
    Xnei = X0(neighbor,:); Ynei = Y0(neighbor,:); 
    XneiRelible = X0(neighborRelible,:); YneiRelible = Y0(neighborRelible,:); 
    [XneiNorm,XneiNormRelible] = PCANormRelible(Xnei,XneiRelible); 
    [YneiNorm,YneiNormRelible] = PCANormRelible(Ynei,YneiRelible);
    costRigid = TIMcalcCostRigidRelible(XneiNorm,YneiNorm,randposition,XneiNormRelible,YneiNormRelible,randpositionRelible,tau);
    costRigidT = costRigid;
    costRigidT(find(costRigid < 0.2)) = 0;
    costRigidT(find(costRigid > 0.8)) = 1;
    if sum(costRigidT) < 5
        continue;
    end
    A(lookupTable(seedMatches(i)),lookupTable(neighbor)) = distanceDecay.*costRigidT;
    A(lookupTable(seedMatches(i)),lookupTable(seedMatches(i))) = 0;
end
nonZeroEle = union(find(sum(A,1)~=0),find(sum(A,2)~=0));
A = A(nonZeroEle,nonZeroEle);
A = (A + A')/2;
C = sum(A,2)/numNeigh;
%% graph cut
ep1 = lambda^2/log(2);
datacost = exp(-(C.^2)/ep1);

if alpha ~= 0
    datacost = [1-datacost,datacost];
    label = myGetGraphCutLabel(A, datacost, alpha);
    inliers = find(label==1);
    inliers = UseEleIndex(nonZeroEle(inliers));
else
    inliers = find(datacost<0.5);
    inliers = UseEleIndex(nonZeroEle(inliers));
end
    
ALL = zeros(size(X0,1),size(X0,1));
ALL(UseEleIndex(nonZeroEle),UseEleIndex(nonZeroEle)) = A;
A = ALL;
if length(inliers) < 10
    fprintf("Use seed as inlier");
    inliers = seedMask;
end




