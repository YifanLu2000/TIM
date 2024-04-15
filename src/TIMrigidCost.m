function [rigidCost] = TIMrigidCost(X,Y, randposition,tau)
Xnorm = sqrt(sum(X.^2,2)); Ynorm = sqrt(sum(Y.^2,2));
lengthRatio = min(Xnorm,Ynorm) ./ max(Xnorm,Ynorm);
cosTheta = sum(X.*Y,2) ./(Xnorm .* Ynorm);
rigidCostArr = lengthRatio .* cosTheta;
rigidCostArr(isnan(rigidCostArr)) = -1;
rigidCostArr(randposition) = -1;
rigidCostArr = (rigidCostArr+1)/2;
rigidCostArr(find(rigidCostArr<tau)) = 0;
rigidCost = sum(rigidCostArr);
end