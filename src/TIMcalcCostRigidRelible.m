function costRigid = TIMcalcCostRigidRelible(Xnei,Ynei,controlposition,XneiRelible,YneiRelible,controlpositionRelible,tau)
N = size(Xnei,1);
NRelible = size(XneiRelible,1);
costRigid = zeros(N,1);
XnTilde = Xnei - repmat(Xnei(controlposition,:),N,1);
YnTilde = Ynei - repmat(Ynei(controlposition,:),N,1);
XnTildeRelible = XneiRelible - repmat(XneiRelible(controlpositionRelible,:),NRelible,1);
YnTildeRelible = YneiRelible - repmat(YneiRelible(controlpositionRelible,:),NRelible,1);
scaleArr = sum(XnTilde.^2,2);
sinthetaArr = -(XnTilde(:,1) .* YnTilde(:,2) - XnTilde(:,2) .* YnTilde(:,1))./scaleArr;
costhetaArr = (XnTilde(:,1) .* YnTilde(:,1) + XnTilde(:,2) .* YnTilde(:,2))./scaleArr;
R = zeros(2,2,N);
R(1,1,:) = costhetaArr; R(2,2,:) = costhetaArr; 
R(1,2,:) = -sinthetaArr; R(2,1,:) = sinthetaArr; 
for i = 1:N
    if isnan(R(1,1,i))
        continue;
    end
    YnTildeRelible2 = XnTildeRelible*R(:,:,i);
    
%     costRigid(i) = TIMrigidCost(YnTildeRelible,YnTildeRelible2,controlpositionRelible,tau);
    rigidCostArr = sqrt(sum((YnTildeRelible - YnTildeRelible2).^2,2));
    costRigid(i) = sum(rigidCostArr < tau);
end
costRigid = costRigid / NRelible;
costRigid(controlposition) = 0;
end
