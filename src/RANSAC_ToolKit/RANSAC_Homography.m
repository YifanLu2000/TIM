function [H, bestInliers,curTrials] = RANSAC_Homography(X, Y, maxTrials, threshold, confidence, option, Fixed)

N = size(X,1);
X = [X, ones(N,1)]';
Y = [Y, ones(N,1)]';

curTrials = 0;
bestInliers = [];
numBestInliers = 0;
logOneMinusConf = log(1 - confidence);
oneOverNPts = 1/N;

while curTrials <= maxTrials
    [H, curInliers, ~] = MinimalSample_H(X, Y, N, threshold);
    numCurInliers = length(curInliers);
        
    if numBestInliers < numCurInliers
        bestInliers = curInliers;
        numBestInliers = numCurInliers;
        if option == 1
        % local optimization
            if numBestInliers >= 4
                [curInliers, H] = LocalOptimizationH(bestInliers, X, Y, threshold);
                numCurInliers = length(curInliers);
                if numBestInliers < numCurInliers
                    bestInliers = curInliers;
                    numBestInliers = numCurInliers;
                end
            end
        end
        % Update the number of trials
        if ~Fixed
            maxTrials = updateNumTrials(oneOverNPts, logOneMinusConf, numCurInliers, maxTrials, 4);
        end
    end
    curTrials = curTrials + 1;
end
H = norm4Point(X(:, bestInliers), Y(:, bestInliers));
d = SampsonDistanceH(X, Y, H);
bestInliers = find(d<=threshold);
% fprintf('Iteration times: %d.\n',curTrials);
end