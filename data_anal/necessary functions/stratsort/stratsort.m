function psorted = stratsort(tpd,ns,version,ad)
% tpd, number of subjects, version, ad(if version==1)
% BY BAILEY N. HWA, 2015-2016 HHMI
%
psort = zeros(500*ns,4);%subjchoice,correct/incorrect,trapline
if version == 1
    lrb = tpd(1,10,1);
    x = [tpd(1,12), tpd(1,14)];
    y = sort(unique(tpd(:,13)), 'descend');
end
if version == 2
    lrb = tpd(1,11,1,1);
    x = sort(unique(tpd(:,13)));%larger x = right, smaller x left
    y = sort(unique(tpd(:,14)), 'descend');
end
tgd = tpd(1,(8+version));
x0 = tpd(1,(9+version));
y0 = tpd(1,(10+version));
dist = [sqrt((diff(x))^2+0); sqrt((diff(x))^2+(diff(y))^2)];
mp = [[mean(x),y(1)]; [mean(x),mean(y)]]%row is reach; smaller y=furtherreach

    for p = 1:500*ns%trialtot500
        if version == 1
            ptrial = tpd(tpd(:,1)==p,:);
            rnum = ad(p,4);
%             ptrial = tpd(tpd(:,1,k)==p,:,k);
%             rnum = ad(p,4);
        end
        if version == 2
            ptrial = tpd(tpd(:,1)==p,:);
            rnum= tpd(p,5);
%             ptrial = tpd(tpd(:,1,k)==p,:,k);
%             rnum= tpd(p,5,k);ad,version+6=8
        end
        
        if numel(ptrial>0)
            ptrial1 = ptrial(find(ptrial(:,end-1)==2),:);
%             ptrial2 = ptrial(find(ptrial(:,end-1)==3),:);
            NuoLi = ptrial1(([1; (sum(diff(ptrial1(:,(version+5):(version+6)))~=0,2))])~=0,...
                (version+5):(version+6));%remove duplicate time-adjacent point [x,y]%fasterprocessing
            pthresh = sum(NuoLi(:,1)>lrb)/size(NuoLi,1);
            try
                deriv = movAv(abs(diff(NuoLi(:,1))...
                ./diff(reshape(1:size(NuoLi,1),size(NuoLi,1),1),round(length(NuoLi)/12))));
            catch
                deriv = 1;
            end
%             deriv = numel(findpeaks(movAv(abs(diff(NuoLi(:,1))...
%                 ./diff(reshape(1:size(NuoLi,1),size(NuoLi,1),1))),round(length(NuoLi)/12))));
            [a ,cdist, b] = distance2curve(NuoLi(:,:),mp(rnum,:));
            %ignore ultra noisy trials, based on local minima/maxima of
            %derivative of forage curve
            if deriv<30%MAY HAVE TO INCREASE IF USING ULTRASONIC SENSORS, WHICH HAVE FREQUENT NOISE
            if pthresh<0.5
                pchoice = 1;%1 left
                %           DISTANCE FROM FORAGE CURVE TO OTHER TARGET AREA
                [a ,cdist2, b] = distance2curve(NuoLi(:,:),[x(2), y(1)]);
%                 [a ,cdist2, b] = distance2curve(NuoLi2(:,:),[x(2), y(1)]);
            else
                pchoice = 2;%2 right
                %           DISTANCE FROM FORAGE CURVE TO OTHER TARGET AREA
                [a ,cdist2, b] = distance2curve(NuoLi(:,:),[x(1), y(rnum)]);
%                 [a ,cdist2, b] = distance2curve(NuoLi2(:,:),[x(1), y(rnum)]);          
            end
%             tl = ad(p,(6+version));
%             if(pchoice == ad(p,(6+version)))%ad(p,7,k))
%                     rw = 1;
%             else
%                     rw = 0;
%             end
            if nargin ==3 & version == 2
                tl = ptrial(2,4);
                if (pchoice == ptrial(2,4))
                    rw = 1;
                else
                    rw = 0;
                end
            end
            if nargin == 4 & version == 1
                tl = ad(p,7);
                if (version == 1 & pchoice == ad(p,7))%ad(p,7,k))
                    rw = 1;
                else
                    rw = 0;
                end
            end
            if cdist2>((dist(rnum)/2)) & rw == 1;
%               if forage curve's distance from other target distance 
%               is greater than half of distance between target areas and
%               the trial is correct, the forage strategy is categorized
%               as "single reach"
                strat = 1;%SINGLE REACH
            else
                if incircle(x0,y0,NuoLi,tgd*1.5)==1
%                   if the minimum closest distance between the center of 
%                   the start/collect area and the forage curve's 
%                   increasing points is less than 1.5* the start/collect
%                   area's diameter, the trajectory is classified as a 
%                   double reach, as long as the trajectory returns to
%                   within tgd*1.5 distance of start/collect area even if
%                   traplines occur after such action
                    strat = 2;%double reach it is
                else
%                   anything else is trapline; can use the variable cdist
%                   closest (distance from forage curve to midpoint) to
%                   further refine trapline.
                    strat = 3;%BEEZ N THE TRAP(LINE), haha bad pop culture reference
                end
            end
            psort(p,:) = [pchoice; rw; strat; tl];%OUTPUT vector of:
%             choice (returned as 1 for left, 0 for right, right or wrong,
%             strategy, and actual reach
            else
                psort(p,:) = [pchoice; rw; 9; 9];%OUTPUT vector for unknown strategy
%                 abs(pchoice-2)
            end
        else
            if version == 1
                psort(p,:) = [sum((ad(p,6)==1 & ad(p,7)==1) | (ad(p,6)==0 & ad(p,7)==2)); 9; 9; 9];
            else
                psort(p,:) = [ad(p,(version+7)); 9; 9; 9];
            end
        end
    end
psorted = psort;
end
% SEE WHERE FUNCTION IS USED IN LINE 85
function [ yn ] = incircle(x0,y0,NuoLi,tgd)%CHECK WITH V2 TGD
    deriv  = [0, movAv(diff(NuoLi(:,2)),round(length(diff(NuoLi(:,2)))/6))];
    yn = (min(sqrt(sum(power(NuoLi((deriv>0),:)...
    -repmat([x0, y0],[numel(NuoLi((deriv>0)))...
    ,1]),2),2)))<(tgd));%TGD*1.5 = range of starting diameter
end