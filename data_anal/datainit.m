% =========================================================================
% =========================================================================
% SET VARIABLES
% =========================================================================
% =========================================================================
% GET DIRECTORY FOR TASK 1 TRIALDATA
filepath = '/Users/hwab/Dropbox (HHMI)/2015-16 experiment/task1/DataBuffer/trialdata/';
% GET DIRECTORY FOR TASK 1 TRAJECTORY DATA
filepathp = '/Users/hwab/Dropbox (HHMI)/2015-16 experiment/task1/DataBuffer/positiondata/';
opalt = 0;%include opal model alongside user choice probability over time
acv = 0.1;%ac value
half = 2;% (half=2) take second half of trials for user choice as function of probability
% and standard instatnaneous mean of user choice (separated into reaches
% and reward probabilities
% (half=1) take all trials
trajec = 1;% get user choice/right or wrong from offline trajectory sorter
% 1 = get from trajectory analysis, 0= get from onlie sorter
% =========================================================================
% =========================================================================

fnamesp = dir(strcat(filepathp,'*.csv'));
fnames = dir(strcat(filepath,'*.csv'));
nopos = 0;%0 = no positionstuff; 1 = yes
ns = length(fnames);%number of test subjects
ad = zeros(500,13,ns);%alldata
np = zeros(ns);
rprob = [0.1,0.25,0.5, 0.75,0.9];
halfac = zeros(2,ns);
b = 50; %block
cl = varycolor(ns+1);%use varycolor function
clearvars tpd
clearvars tpd1
for k = 1:ns
    legendcell{k} = ['usr' num2str(k)];
    fname = fnames(k).name;
    ad(:,:,k) = csvread(strcat(filepath,fname),2, 0);
	fnamep = fnamesp(k).name;
    tpd1 = csvread(strcat(filepathp,fnamep), 2,0);
    if k < 2
        %add column to positiondata indicating subject number, then
        %vertically concenate
        tpd = [tpd1(tpd1(:,1)<(1+(500*k)),:),repmat(k:k,[size(tpd1(tpd1(:,1)<(1+(500*k)),:),1),1])];
        ad1 = csvread(strcat(filepath,fname),2, 0);
    else
        %add column to positiondata indicating subject number, then
        %vertically concenate
        tpd1(:,1) = tpd1(:,1)+500*(k-1);
        tpd = vertcat(tpd, [tpd1(tpd1(:,1)<(1+(500*k)),:),[repmat(k:k,[size(tpd1(tpd1(:,1)<(1+(500*k)),:),1),1])]]);
        ad1 = vertcat(ad1,ad(:,:,k));
    end
end
legendcell{k+1} = 'avg';
%trial data for task1 and 2
colp = size(tpd,2);
% colp = size(pd1,2);
% mpd = max(np);
rn = numel(unique(ad(:,4,1)));
pn = numel(unique(ad(:,5,1)));
col = size(ad,2);
tt = pn*b/half;
if half == 2
    hd = reshape((b/2)+1:b,(b/2),1);
    for i = 1:(rn*pn)
        hdx(1+(b/2)*(i-1):(b/2)*i,1) = hd(:,1) + b*(i-1);
    end

    hindex = reshape(hdx,tt,rn);
else
    hindex = reshape(1:500,tt,rn);
end
if colp == 17
    version = 1;
end
if colp == 16
    version = 2;
end
chleft = zeros(pn,rn,ns);
avg = zeros(pn,rn);
td = zeros((size(ad,1)/rn)/half,size(ad,2),rn,ns);
td1 = zeros((size(ad,1)/rn),size(ad,2),rn,ns);
correct = zeros(tt,rn,ns);
idxc = zeros(rn,ns);
incorrect = zeros(tt,rn,ns);% trial number for correct
idxn = zeros(rn,ns);
%=================================================================================
%=================================================================================
% GET TRAJECTORY SORTED DATA
%=================================================================================
%=================================================================================
% the function stratsort returns a ((n subjects*500) by 4) vector of values
if version == 1
    psorted = stratsort(tpd,ns,version,ad1);%get offline sorted data"true choice"
end
if version == 2
    psorted = stratsort(tpd,ns,version);
end
for k = 1:ns
%=================================================================================
%=================================================================================
% HANDLING ALL TRIAL DATA
%=================================================================================
%=================================================================================
    if trajec == 1%if use trajectories to obtain data
        ad(:,(version+5),k) = psorted((1+500*(k-1):500*k),2);
        ad1((1+500*(k-1):500*k),(version+5)) = psorted((1+500*(k-1):500*k),2);
        if version == 2
            ad(:,6,k) = psorted((1+500*(k-1):500*k),1);
            ad1((1+500*(k-1):500*k),6) = psorted((1+500*(k-1):500*k),1);
        end
    end
    if version == 1
        pta(:,k) = ((ad(:,6,k)==1 & ad(:,7,k)==1) ...
            | (ad(:,6,k)==0 & ad(:,7,k)==2));
    end
    if version == 2
        pta(:,k) = (ad(:,6,k)==1);
    end
%=================================================================================
%=================================================================================
    [ok, rindex] = sort(ad(:,4,k));
    for t = 1:rn
        td1(:,:,t,k) = ad(ad(:,4,k)==t,:,k);
        %     separate into thresh 3dim = each separate reach
%         td1(:,:,t,k) = ad(ad(:,4,k)==t,:,k);

        % sort based on prob
        [y,idx] = sort(td1(:,5,t,k));
        td1(:,:,t,k) = td1(idx,:,t,k);
        if max(td1(:,2,t,k))> 250
            hval = 2;
        else
            hval = 1;
        end
        halfac(t,k) = hval;
        if half == 2
            td(:,:,t,k) = td1(ismember(td1(:,2,t,k),hindex(:,hval)),:,t,k);
        else
            td(:,:,t,k) = td1(:,:,t,k);
        end
%       USING ONLINE SORTER
        if version == 1
        %   CORRECT
            idxc(t,k) = numel(find(td(:,6,t,k) == 1));
            correct(1:idxc(t,k),t,k) ...
                = td((td(:,6,t,k) == 1),2,t,k);
            correct(idxc(t,k):tt,t,k) = 0;
        %   INCORRECT
            idxn(t,k) = tt - idxc(t,k);
            incorrect(1:idxn(t,k),t,k) ...
                = td((td(:,6,t,k) == 0),2,t,k);
            incorrect(idxn(t,k):tt,t,k) = 0;
        end
        if version == 2
            idxc(t,k) = numel(find(td(:,7,t,k) == 1));
            correct(1:idxc(t,k),t,k) ...
                = td((td(:,7,t,k) == 1),2,t,k);
            correct(idxc(t,k):tt,t,k) = 0;
        %   INCORRECT
            idxn(t,k) = tt - idxc(t,k);
            incorrect(1:idxn(t,k),t,k) ...
                = td((td(:,7,t,k) == 0),2,t,k);
            incorrect(idxn(t,k):tt,t,k) = 0;

        end
        for i = 1:5
            sl1 = b;%take all trials
            sdx1 = 1+(b)*(i-1);
            if half == 2% take 2nd half
                sl = (b/2);
                sdx = 1+ (i-1)*25;
            else
                sl = b;%take all trials
                sdx = 1+(b)*(i-1);
            end
            if version == 1
%               PROB CHOOSE LEFT
% old "timestamp, trialNum, blockWidth, position_number, LeftTriggerProbability, rightORwrong, Rewardposition, forageDistance, collectionDistance, totalDistance, optimalTotalDistance, Totaldifference, score"
%               CHOOSE LEFT FROM ONLINE SORTER
                chleft(i,t,k) = ((sum((td(sdx:sl*i,6,t,k) == 1 & td(sdx:sl*i,7,t,k) == 1))) ...
                    + (sum((td(sdx:sl*i,6,t,k)== 0 & td(sdx:sl*i,7,t,k) == 2))))/sl;
                pt(k,:,t,i) = reshape(((td1(sdx1:sl1*i,6,t,k)==1 & td1(sdx1:sl1*i,7,t,k)==1) ...
                    | (td1(sdx1:sl1*i,6,t,k)==0 & td1(sdx1:sl1*i,7,t,k)==2)),1,b);
%                 pt(k,:,t,i) = reshape(cumsum((td1(sdx1:sl1*i,6,t,k)==1 & td1(sdx1:sl1*i,7,t,k)==1) ...
%                     | (td1(sdx1:sl1*i,6,t,k)==0 & td1(sdx1:sl1*i,7,t,k)==2))./reshape(1:(b),b,1),1,b); 
%
            end
            if version == 2
%               PROB CHOOSE LEFT
            %            // "timestamp, trialNum, blockWidth, reach4, leftprob5, playerpos6, Rightorwrong7, rpos8, forageDist, totDist, optdist, diff, score";
%               CHOOSE LEFT FROM ONLINE SORTER
                chleft(i,hval,k) = (numel(td((td(sdx:sl*i,6,t)== 1))))/sl;%1 = left
                pt(k,:,hval,i) = reshape((td1(sdx1:sl1*i,6,t,k)==1),1,sl1);
%                 pt(k,:,t,i) = reshape(cumsum(td(sdx1:sl1*i,6,t,k)==1)./reshape(1:(sl1),sl1,1),1,sl1);
            end
        end
    end
end
for i = 1:rn
    avg(:,i) = (sum(chleft(:,i,:),3)/ns);
end
avg1 = sum(avg,2)/rn;
%=================================================================================
%=================================================================================
% TASK1positionstuff
%=================================================================================
%=================================================================================
%=================================================================================
%=================================================================================
% OPAL MODEL STUFF
%=================================================================================
%=================================================================================
%get opal simulation for each test subject
if opalt==1
opaldata = opal(ad1,version,ns,acv);
end
%=================================================================================
%=================================================================================

%=================================================================================
%=================================================================================
% FIGURES
%=================================================================================
%=================================================================================
figure(1);
    subplot(2,1,1);
    set(gca, 'ColorOrder', cl);
    set(gca,'fontsize',18);
    hold all;
    for i = 1:ns+1
        if i <ns+1
            plot(rprob,chleft(:,1,i));
        else
            plot(rprob,avg(:,1));
        end
    end
    legend(legendcell);
    
    xlabel('P(reward)');
    ylabel('P(choose left)');
    if half == 2
        title('P(choose L) as function of P(Leftreward) (R1) 2ndhalf');
    else
        title('P(choose L) as function of P(Leftreward) (R1)');
    end
    
    subplot(2,1,2);
    set(gca, 'ColorOrder', cl);
    set(gca,'fontsize',18);
    hold all;
    for i = 1:ns+1
        if i <ns+1
            plot(rprob,chleft(:,2,i));
        else
            plot(rprob,avg(:,2));
        end
    end
        legend(legendcell);
    
    xlabel('P(reward)');
    ylabel('P(choose left)');
    if half == 2
        title('P(choose L) as function of P(Leftreward) (R2) 2ndhalf');
    else
        title('P(choose L) as function of P(Leftreward) (R2)');
    end
% OLD"trialNum1, blockWidth2, MillisTime3, pos4, prob5, 6MouseX, MouseY7, StartDiam8, ForageDiameter9, CircleX0, Circle Y0, CircleX1, CircleY1, CircleX2, CircleyY2, TrialState";"trialNum, blockWidth, MillisTime, pos, leftTriggerProbability, MouseX, MouseY, Start/CollectionDiameter, ForageDiameter, CircleX0, Circle Y0, CircleX1, CircleY1, CircleX2, CircleyY2, TrialState";"trialNum, blockWidth, MillisTime, pos, leftTriggerProbability, MouseX, MouseY, Start/CollectionDiameter, ForageDiameter, CircleX0, Circle Y0, CircleX1, CircleY1, CircleX2, CircleyY2, TrialState";
% newpos = "trialNum1, blockWidth2, MillisTime3, rpos4, reach5, leftprob6, MouseX7, MouseY8, startdiameter9, targetdiameter10, x011,y012, x1, y1,trialstate"
%=================================================================================
%=================================================================================
% Get strategies, e.t.c, and sort
%=================================================================================
%=================================================================================
% IF USING ULTRASONIC SENSORS, CHECK VARIABLE DERIV(not that of local
% function) TO SEE IF THRESHOLD IS TOO LOW, due to noise in ultrasonic
% sensing
if ns>1
    for r = 1:rn
        figure(r+1);
    %         hold all
        for i = 1:pn
    %         hold on            
        subplot(5,2,i);
        x = 1:length(pt(:,:,r,i));
        semline(pt(:,:,r,i),10,'r');
    %             shadedErrorBar(x,pt(:,:,t,i),{@mean, @(x) 1*std(x)},'r',0);
        hold all
        title(['p(r)=' num2str(rprob(i))]);
        xlabel('trials');
        ylabel('choice prob');
        end
        a = axes;
        t1 = title(['P(choose L) at reach' num2str(t)]);
        a.Visible = 'off';
        t1.Visible = 'on';
    end
end
%=================================================================================
%=================================================================================
% SORT STRATEGIES & TRAJECTORIES
%=================================================================================
%=================================================================================
    figure(((2*rn)+1)+1);
    p = int32(1);%faster speed
    for p = 1:ns*500%numel(unique(tpd(:,1)))
%=================================================================================
%=================================================================================
% SORT STRATEGIES
%=================================================================================
%=================================================================================
        if psorted(p,3)==1
%             subplot(2,3,1 + 3*(ad(p,4,i)-1))%reach1
            subplot(2,4,1 + 4*(ad1(p,4)-1))%reach1
            hold on
            if psorted(p,1)==1%left
                plot(tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+5)),tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+6)),'b');%left
            else
                plot(tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+5)),tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+6)),'r');%right
            end
        title(['L/R, single reach, reach' num2str(ad1(p,4))]);
        else
%             hold off
        end
%=================================================================================
%=================================================================================
        if psorted(p,2)==1 & psorted(p,3)==2
%             subplot(2,3,2 + 3*(ad(p,4,i)-1))%reach1%p-(fix((p-1)/(500))*500)
            subplot(2,4,2 + 4*(ad1(p,4)-1))%reach1%p-(fix((p-1)/(500))*500)
            hold on
            if psorted(p,1)==1%left  
                plot(tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+5)),tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+6)),'b');%left
            else
                plot(tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+5)),tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+6)),'r');%right
            end
        title(['L/R correct double reach, reach ' num2str(ad1(p,4))]);
        else
%             hold off
        end
%=================================================================================
%=================================================================================
        if psorted(p,2)==0 & psorted(p,3)==2
%             subplot(2,3,3 + 3*(ad(p,4,i)-1))%reach1
            subplot(2,4,3 + 4*(ad1(p,4)-1))%reach1
            hold on
            if psorted(p,1)==1%left
                plot(tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+5)),tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+6)),'b');%left
            else
                plot(tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+5)),tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+6)),'r');%right
            end
        title(['L/R incorrect double reach, reach ' num2str(ad1(p,4))]);
        else
%             hold off
        end
%=================================================================================
%=================================================================================
        if psorted(p,3)==3
%             subplot(2,3,3 + 3*(ad(p,4,i)-1))%reach1
            subplot(2,4,4 + 4*(ad1(p,4)-1))%reach1
            hold on
            if psorted(p,1)==1%left
                plot(tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+5)),tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+6)),'b');%left
            else
                plot(tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+5)),tpd(tpd(:,1)==p & tpd(:,colp-1)==2 ,(version+6)),'r');%right
            end
        title(['Trap, reach ' num2str(ad1(p,4))]);
        else
%             hold off
        end
    end
        ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        t = text(0.5, 1,['Forage and Collection Trajectories'],'HorizontalAlignment' ...
        ,'center','VerticalAlignment', 'top');
        t.FontSize = 22;
% end
%=================================================================================
%=================================================================================
for i = 1:ns
    figure(((2*rn)+2)+i);
    hold on
        cl = (ad(:,(6+version),i)==1);
        cr = (ad(:,(6+version),i)==2);
        cc = reshape((ad(:,(6+version),i)==1),1,size(ad,1));
        xs = [(ad(:,4,i)==2),(ad(:,4,i)==1),cl,cr];
        ht = [0.1,0.1,0.075,-0.075];
        hv = [1.3,1.3,1.10,-0.10];
        col = [1 0 0; 0 0 1; 1 .5 0;0 .8 0];
        lt = [2,2,1,1,1,1];
%         plot(find(pta(i,:)==1),1,'Color', [0 0.2 0]); %plot the 1's
%         plot(find(pta(i,:)==0),0,'Color', [0 0.8 0]); %plot the 0's
        avgval = 20;
%         plot(moveavg(cc,avgval), 'c');
        shade(([(ad(:,4,i)==2),(ad(:,4,i)==1),cl,psorted(1+500*(i-1):500*i,3)==3 ...
            & psorted(1+500*(i-1):500*i,4)==1,cr  ...
            , psorted(1+500*(i-1):500*i,3)==3 ...
            & psorted(1+500*(i-1):500*i,4)==2]),-1.1 ...
            ,[1.3,1.3,1.10,1.10, -0.025,-0.025]...
            ,[0.1,0.1,0.075,0.075,0.075,0.075]...
            ,[1 0 0; 0 0 1; 1 .5 0;0.6 0 0; 0 .8 0; 0 0.2 0]...
            ,[2,2,1,1,1,1,1,1]);
%                 ,[1.3,1.3,1.10,-0.025, -0.2,-0.2]...
%                 ,[0.1,0.1,0.075,0.075,0.075,0.075]...
%                 ,[1 0 0; 0 0 1; 1 .5 0;0 .8 0; 0 0.2 0.2; 0.8 0 0]...
%                 ,[2,2,1,1,1,1,1,1]);
        plot(moveavg(cc,avgval), 'c');
        plot(moveavg(pta(:,i),avgval),'k');
%         plot(moveavg(psorted((1+500*(i-1):500*i),1),avgval),'k');%get user choice from trajectories
        if opalt == 1
            plot(1:500,opaldata(:,i));
            legend(['reach' num2str(halfac(1,i))],' ',['reach' num2str(halfac(2,i))],...
                ' ','Reward target: left', ' ', 'Reward target: left/Trapline' ,' ', ...
                'Reward target: right', ' ', 'Reward target: right/Trapline', ' ',...
                'P(reward|left) moving avg',...
                'Choice moving avg (from trajectories)', ['opal, ac =' num2str(acv)],'FontSize',18);     
        else
            legend(['reach' num2str(halfac(1,i))],' ',['reach' num2str(halfac(2,i))],...
                ' ','Reward target: left', ' ', 'Reward target: left/Trapline' ,' ', ...
                'Reward target: right', ' ', 'Reward target: right/Trapline', ' ',...
                'P(reward|left) moving avg',...
                'Choice moving avg (from trajectories)','FontSize',18);
        end
        xlabel('Trials');
        ylabel('Probability');
        xlim([0, size(ad,1)]);
        ylim([-0.25,1.3]);
        ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
        t = text(0.5, 1,['P(choose L) over time, usr ' num2str(i) ',movavg= ' num2str(avgval) ' trials'],'HorizontalAlignment' ...
        ,'center','VerticalAlignment', 'top','FontSize',22);
        t.FontSize = 22;
        
end
% figure