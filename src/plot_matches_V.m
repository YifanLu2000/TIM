function plot_matches_V(I1,I2,X,Y,ind,CorrectIndex)
%% plot matches
siz1 = size(I1);
siz2 = size(I2);
NumPlot = 1000000;
n = size(X,1);
tmp=zeros(1, n);
tmp(ind) = 1;
tmp(CorrectIndex) = tmp(CorrectIndex)+1;
indCorrect = find(tmp == 2);
TruePos = indCorrect;   %Ture positive
tmp=zeros(1, n);
tmp(ind) = 1;
tmp(CorrectIndex) = tmp(CorrectIndex)-1;
FalsePos = find(tmp == 1); %False positive
tmp=zeros(1, n);
tmp(CorrectIndex) = 1;
tmp(ind) = tmp(ind)-1;
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
    imgtemp = zeros(Imgheight,siz2(2),3);
    imgtemp(1:siz2(1),:,:) = I2;
    I2 = imgtemp;
else
    imgtemp = zeros(Imgheight,siz1(2),3);
    imgtemp(1:siz1(1),:,:) = I1;
    I1 = imgtemp;
end
imagesc(cat(2, I1, WhiteInterval, I2));

hold on ;
temp = zeros(n,1);
temp(CorrectIndex) = 1;
CorrectIndex = find(temp == 1);
FalseIndex = find(temp == 0);
linwidth = 0.3;
for i = 1:n
    if ismember(i,FalseNeg)
%         l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color', 'g') ;%'g'
    elseif ismember(i,FalsePos)
        l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color','r') ;%  [0.8,0.1,0]
        plot(X(i,1),X(i,2),'r.','Markersize',4);hold on  
        plot(Y(i,1)+size(I1,2)+interval,Y(i,2),'r.','Markersize',4);hold on
    elseif ismember(i,TruePos)
%         l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color','b' ) ;%[0,0.5,0.8]
    end
    l.Color(4) = 0.5;
end

linwidth = 0.3;
for i = 1:n
    if ismember(i,FalseNeg)
        l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color', 'g') ;%'g'
        plot(X(i,1),X(i,2),'g.','Markersize',4);hold on  
        plot(Y(i,1)+size(I1,2)+interval,Y(i,2),'g.','Markersize',4);hold on
    elseif ismember(i,FalsePos)
%         l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color','r') ;%  [0.8,0.1,0]
%         plot(X(i,1),X(i,2),'r.','Markersize',4);hold on  
%         plot(Y(i,1)+size(I1,2)+interval,Y(i,2),'r.','Markersize',4);hold on
    elseif ismember(i,TruePos)
%         l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color','b' ) ;%[0,0.5,0.8]
    end
    l.Color(4) = 0.5;
end

linwidth = 0.5;
for i = 1:n
    if ismember(i,FalseNeg)
%         l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color', 'b') ;%'g'
    elseif ismember(i,FalsePos)
%         l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color','r') ;%  [0.8,0.1,0]
    elseif ismember(i,TruePos)
        l = plot([X(i,1)'; Y(i,1)'+size(I1,2)+interval], [X(i,2)' ;  Y(i,2)'],'linewidth', linwidth, 'color','b' ) ;%[0,0.5,0.8]
        plot(X(i,1),X(i,2),'b.','Markersize',4);hold on  
        plot(Y(i,1)+size(I1,2)+interval,Y(i,2),'b.','Markersize',4);hold on  
    end
    l.Color(4) = 0.8;
end

axis equal ;
axis([0 siz1(2)+siz2(2)+interval 0 Imgheight]);

set(gca,'XTick',-2:1:-1)
set(gca,'YTick',-2:1:-1)
hold off
