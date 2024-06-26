function [F, bestInliers] = RANSAC_FundamentalMatrix(X, Y, maxTrials, threshold, confidence, option, Fixed)

N = size(X,1);
X = [X, ones(N,1)]';
Y = [Y, ones(N,1)]';

curTrials = 0;
bestInliers = [];
numBestInliers = 0;
logOneMinusConf = log(1 - confidence);
oneOverNPts = 1/N;

while curTrials <= maxTrials
    [F, curInliers, indices] = MinimalSample_F(X, Y, N, threshold);
    numCurInliers = length(curInliers);
        
    if numBestInliers < numCurInliers
        bestInliers = curInliers;
        numBestInliers = numCurInliers;
        if option == 2 || option == 3
        % degenaracy check
            [H, degeneracy] = DegeneracyCheck(X, Y, indices, threshold);
            if degeneracy
                [curInliers, F] = DegeneracyUpdate(X, Y, threshold, bestInliers, H);
                numCurInliers = length(curInliers);
                if numBestInliers < numCurInliers
                    bestInliers = curInliers;
                    numBestInliers = numCurInliers;
                end
            end
        end
        if option == 1 || option == 3
        % local optimization
            if numBestInliers >= 8
                [curInliers, F] = LocalOptimizationF(bestInliers, X, Y, threshold);
                numCurInliers = length(curInliers);
                if numBestInliers < numCurInliers
                    bestInliers = curInliers;
                    numBestInliers = numCurInliers;
                end
            end
        end
        % Update the number of trials
        if ~Fixed
            maxTrials = updateNumTrials(oneOverNPts, logOneMinusConf, numCurInliers, maxTrials, 7);
        end
    end
    curTrials = curTrials + 1;
end
F = norm8Point(X(:, bestInliers), Y(:, bestInliers));
d = SampsonDistanceF(X, Y, F);
bestInliers = find(d<=threshold);
end