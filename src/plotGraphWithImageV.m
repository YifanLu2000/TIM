function plotGraphWithImageV(I1,I2,X,Y,W,VFCIndex,CorrectIndex,AReverse)
if nargin == 8
    WReverse = AReverse;
end
figure;
%% plot matches
siz1 = size(I1);
siz2 = size(I2);
NumPlot = 1000000;
n = size(X,1);
tmp=zeros(1, n);
tmp(VFCIndex) = 1;
tmp(CorrectIndex) = tmp(CorrectIndex)+1;
VFCCorrect = find(tmp == 2);
TruePos = VFCCorrect;   %Ture positive
tmp=zeros(1, n);
tmp(VFCIndex) = 1;
tmp(CorrectIndex) = tmp(CorrectIndex)-1;
FalsePos = find(tmp == 1); %False positive
tmp=zeros(1, n);
tmp(CorrectIndex) = 1;
tmp(VFCIndex) = tmp(VFCIndex)-1;
FalseNeg = find(tmp == 1); %False negative

FP = FalsePos;
FN = FalseNeg;

NumPos = length(TruePos)+length(FalsePos)+length(FalseNeg);
if NumPos > NumPlot
    t_p = length(TruePos)/NumPos;
    n1 = round(t_p*NumPlot);
    f_p = length(FalsePos)/NumPos;
    n2 = round(f_p*NumPlot);
    f_n = length(FalseNeg)/NumPos;
    n3 = round(f_n*NumPlot);
else
    n1 = length(TruePos);
    n2 = length(FalsePos);
    n3 = length(FalseNeg);
end

per = randperm(length(TruePos));
TruePos = TruePos(per(1:n1));
per = randperm(length(FalsePos));
FalsePos = FalsePos(per(1:n2));
per = randperm(length(FalseNeg));
FalseNeg = FalseNeg(per(1:n3));


interval = 20;
Imgheight = max(siz1(1),siz2(1));
WhiteInterval = 255*ones(Imgheight,interval, 3);
if siz1(1) == Imgheight
    imgtemp = ones(Imgheight,siz2(2),3);
    imgtemp(1:siz2(1),:,:) = I2;
    I2 = imgtemp;
else
    imgtemp = ones(Imgheight,siz1(2),3);
    imgtemp(1:siz1(1),:,:) = I1;
    I1 = imgtemp;
end
imagesc(cat(2, I1, WhiteInterval, I2));

hold on ;
% linwidth = 0.8;
linwidth = 0.5;
for i = 1:n
    if ismember(i,FalseNeg)
%         l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color', 'g') ;%'g'
    elseif ismember(i,FalsePos)
        l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color','r') ;%  [0.8,0.1,0]
    elseif ismember(i,TruePos)
        l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color','b' ) ;%[0,0.5,0.8]
    end
    l.Color(4) = 0.4;
end
% plot(X(TruePos,1)',X(TruePos,2)','x','color','y');
% plot(Y(TruePos,1)'+size(I1,2)+interval,Y(TruePos,2)','x','color','y');
% plot(X(:,1)',X(:,2)','x','color','y');
% plot(Y(:,1)'+size(I1,2)+interval,Y(:,2)','x','color','y');
temp = zeros(n,1);
temp(CorrectIndex) = 1;
CorrectIndex = find(temp == 1);
FalseIndex = find(temp == 0);
plot(X(CorrectIndex,1),X(CorrectIndex,2),'b.','Markersize',4);hold on  
plot(X(FalseIndex,1),X(FalseIndex,2),'r.','Markersize',4);hold on  
plot(Y(CorrectIndex,1)+size(I1,2)+interval,Y(CorrectIndex,2),'b.','Markersize',4);hold on  
plot(Y(FalseIndex,1)+size(I1,2)+interval,Y(FalseIndex,2),'r.','Markersize',4);hold on
axis equal ;
axis([0 siz1(2)+siz2(2)+interval 0 Imgheight]);
set(gca,'XTick',-2:1:-1)
set(gca,'YTick',-2:1:-1)
%% plot graph
N = size(X,1);
W = (W + W')/2;
UseEle = find(sum(W)>0);
temp = zeros(N,1);
temp(CorrectIndex) = 1;
temp = temp(UseEle);
CorrectIndex = find(temp == 1);
FalseIndex = find(temp == 0);
W = W(UseEle,UseEle);
X = X(UseEle,:);
N = size(X,1);
% if N>2001
%     fprintf('N is too large to plot the graph!\n');
%     randSample = randperm(N,800);
%     X = X(randSample,:);
%     temp = zeros(N,1);
%     temp(CorrectIndex) = 1;
%     temp = temp(randSample);
%     CorrectIndex = find(temp == 1);
%     FalseIndex = find(temp == 0);
%     W = W(randSample,randSample);
%     if nargin == 8
%         WReverse = WReverse(randSample,randSample);
%     end
% end

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

% figure;
for i = 1:N
    for j = i+1:N
        if W(i,j)~=0
%             linewidth = 0.5*W(i,j)/4.5;
            linewidth = W(i,j)/4.5;
            l = plot([X(i,1),X(j,1)],[X(i,2),X(j,2)],'color', [1, 1, 0],'LineWidth',linewidth);hold on
            transparent = W(i,j);
            if transparent > 1
                transparent = 1;
            end
            l.Color(4) = transparent;
        end
    end
end
% reverse
if nargin == 8
%     W = AReverse;
    
    for i = 1:N
        for j = i+1:N
            if WReverse(i,j)~=0
    %             linewidth = 0.5*W(i,j)/4.5;
                linewidth = WReverse(i,j)/4.5;
                l = plot([X(i,1),X(j,1)],[X(i,2),X(j,2)],'color', [1, 0, 0],'LineWidth',linewidth);hold on
                transparent = WReverse(i,j);
                if transparent > 1
                    transparent = 1;
                end
                l.Color(4) = transparent;
            end
        end
    end
end

%     plot(X(:,1),siz(1)-X(:,2),'k.','Markersize',8);hold on  

% axis([0 siz(2) 0 siz(1)])
axis equal ;
axis([0 siz1(2)+siz2(2)+interval 0 Imgheight]);
set(gca,'XTick',-2:1:-1)
set(gca,'YTick',-2:1:-1)
hold off
drawnow;


