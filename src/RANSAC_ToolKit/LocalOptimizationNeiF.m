function [bestInliers,bestF] = LocalOptimizationNeiF(curInliers, X, Y, t)
F = norm8Point(X(:, curInliers), Y(:, curInliers));
bestInliers = curInliers;
numBestInliers = length(bestInliers);
bestF = F;
irlsSteps = 5;
s = 8;

% th_multiplier = 4*sqrt(2); th_step_size = (th_multiplier*t - t)./irlsSteps;
threshold = t;
thresholdRate = 0.8;
for loirls = 0:irlsSteps
    d = SampsonDistanceF(X, Y, F);
    loind = find(d<=1.5*threshold);
%     loind = find(d<=(th_multiplier*t - th_step_size*loirls));
    if length(loind)>=8
        F = norm8Point(X(:, loind), Y(:, loind));
    else
        break;
    end
    d = SampsonDistanceF(X, Y, F);
    ind = find(d<=t);
    if length(loind) > numBestInliers
        bestInliers = ind;
        numBestInliers = length(bestInliers);
        bestF = F;
    end
    threshold = threshold * thresholdRate;
%     if length(loind)>=8
%         loind2 = randsample(loind, min(s*7, length(loind)));
%         w = 1./(1+3*d(loind2)/t);
%         F = weightedNorm8Point(X(:, loind2), Y(:, loind2), w);
%         d = SampsonDistanceF(X, Y, F);
%         loind = find(d<=t);
%         if length(loind) > numBestInliers
%             bestInliers = loind;
%             numBestInliers = length(bestInliers);
%             bestF = F;
%         end
%     end
end