function plotGraphWithSeed(X, W, seedMask, I1, CorrectIndex)

N = size(X,1);
temp = zeros(N,1);
temp(CorrectIndex) = 1;
FalseIndex = find(temp == 0);
siz = size(I1);
figure;
% plot(X(:,1),siz(1)-X(:,2),'.','Markersize',4,'color',[100,100,100]/255);hold on  

if seedMask ~= 0
    plot(X(seedMask,1),siz(1)-X(seedMask,2),'.','Markersize',12,'color',[244,177,131]/255);hold on  
end


if seedMask ~= 0
    temp2 = zeros(N,1);
    temp2(seedMask) = 1;
end
non_empty = sum(W,1) > 0;
X = X(non_empty,:);
W = W(non_empty,non_empty);
temp = temp(non_empty);
if seedMask ~= 0
    temp2 = temp2(non_empty);
    seedMask = find(temp2 == 1);
end

CorrectIndex = find(temp == 1);
FalseIndex = find(temp == 0);
N = size(X,1);

if N>4000
    fprintf('N is too large to plot the graph!\n');
    randSample = randperm(N,800);
    X = X(randSample,:);
    temp = zeros(N,1);
    temp(CorrectIndex) = 1;
    temp = temp(randSample);
    CorrectIndex = find(temp == 1);
    FalseIndex = find(temp == 0);
    W = W(randSample,randSample);
end

cc = [84 134 135
    240 100 73
    62 43 109
    255 170 50
    ]/255;
cc = [cc;
    0.0 0.9 0.6
     0.9 0.6 0.0
     0.9 0 0.6
     0.6 0.9 0.1
     0.6 0.0 0.9
     0.9 0.2 0.0];
siz = size(I1);
N = size(X,1);

maxW = max(max(W));
for i = 1:N
    for j = i+1:N
        if W(i,j)~=0
            linewidth = 0.5*W(i,j)/maxW;
            l = plot([X(i,1),X(j,1)],siz(1)-[X(i,2),X(j,2)],'color', [0.1, 0.1, 0.1],'LineWidth',linewidth);hold on
            transparent = W(i,j)/maxW;
            if transparent > 1
                transparent = 1;
            end
            l.Color(4) = transparent;
        end
    end
end
plot(X(:,1),siz(1)-X(:,2),'.','Markersize',8,'color',[100,100,100]/255);hold on  
% plot(X(CorrectIndex,1),siz(1)-X(CorrectIndex,2),'b.','Markersize',8);hold on  
% plot(X(FalseIndex,1),siz(1)-X(FalseIndex,2),'r.','Markersize',8);hold on  
axis([0 siz(2) 0 siz(1)])
axis equal;axis off;
set(gca,'XTick',-2:1:-1)
set(gca,'YTick',-2:1:-1)
hold off
drawnow;


