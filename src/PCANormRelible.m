function [PCANormData,PCANormDataRelible] = PCANormRelible(data,dataRelible)
% use relible data to normalize the data
[a,b] = eig(cov(dataRelible));
% [a,b] = eig(cov(data(1:10,:)));
PCANormData = data * a' / (b'^(1/2));
PCANormDataRelible = dataRelible * a' / (b'^(1/2));
end