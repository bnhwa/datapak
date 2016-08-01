%=============================================================
%SIM OF PROBABALISTIC 1 STATE TASK WITHOUT REACH THRESHOLDS =
%fluid prob shift after x trials test subject has to adapt
cont = 1; %each prob separately tested as n(101) trials
%softmax is based on prob generated by softmax, 
%init = 1; init = 0 choose higher prob side ;init = 1; random 0.5 prob between choice

%=============================================================
choices = 1;
choice = 1;
cho = [1,2];
probstate =1; %1 = incresing prob e.g., 0.1,0.2,0.3... 2= follows prl1
%=====================choices================================================
prl0 = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
prl1 = [0.1, 0.1, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 0.9, 0.9, 1];
prl = [prl0;prl1];
aci = 0.1;
agi = 0.1;%0.1
ani = 0.1;%0.1
bgi = 1;
bni = 1;
% func, v, g, n, act, prob1
% vi = 0;
% gi = .75;
% ni = 1.75;
% acti = -1;
vi = 0.5;
gi = 1;
ni = 1;
acti = 0;
% rewvalue = 1;
inczero = 0;
trials = 101;
agshift = 11;
rewvalue = 1;
reps = 11;%at different probs
simtot = 1000;%total repetitition
shiftstate = 1;
tt = trials + inczero;
st = tt*reps;
% ch = cell(simtot);%1000,2 choices
ch = zeros(st,7,agshift,simtot);
%====================================================================================
%===prob generation==================================================================
%====================================================================================
prob = rand(st,agshift,simtot);% if 2 choices, first 1010rows for choice1 next 1010 for choice 2 etc.
pr = zeros(st,choices);%probability of reward
%first 1000 columns for choice1 next columns.
for i = 1: st
    pr(i,1) = prl(1,(fix((i-1)/(tt))+1));
    pr(i,2) = 1-pr(i,1);
end
% for c = 1: reps
%     for r = 1:tt
%         xlabel(r,a) = (r-1)/100;
%     end
% end
%====================================================================================
%===simulation=======================================================================
%====================================================================================

for i = 1: simtot%1000 total sim
    for a = 1:agshift
        agi = 0.0 + 0.01*(a-1);
        for r = 1:reps% 
            for j = 1:tt%101 including 0 trials
                t = ((r-1)*tt + j);       
                    %t = ((r-1)*tt + j);
                if (j == 1) || t == 1%first trial in every rep or first in general
                    sigmat = 0;
                    ch(t,1,a,i) = vi;
                    ch(t,2,a,i) = gi;
                    ch(t,3,a,i) = ni;
                    ch(t,4,a,i) = bgi*ch(t,2,a,i)-bni*ch(t,3,a,i);
                else
                    sigmat = (ch(t-1,7,a,i) - ch(t-1,1,a,i));%sigmat = r(t-1)-v(t-1)
                    ch(t,1,a,i) = ch(t-1,1,a,i) + aci*sigmat;%v(t) = v(t-1) + ac*sigmat
                    ch(t,2,a,i) = ch(t-1,2,a,i) + agi*sigmat*ch(t-1,2,a,i);%g(t) = g(t-1) + ag*g(t-1)*sigmat
                    ch(t,3,a,i) = ch(t-1,3,a,i) - (ani*(sigmat)*ch(t-1,3,a,i)); %n(t) = n(t-1) + an*n(t-1)*sigmat
                    ch(t,4,a,i) = bgi*ch(t,2,a,i)-bni*ch(t,3,a,i);%act(t) = bg*g(t) - bn*n(t)
                end
                ch(t,5,a,i) = 1;
    %====================================================================================
    % DEFINE A SOFTMAX RULE
    %====================================================================================
                ch(t,6,a,i) = 1;
                if prob(t,a,i) <= pr(t,1)
                   ch(t,7,a,i) = rewvalue;
                else
                   ch(t,7,a,i) = 0;
                end
            end
        end
    end
end
%====================================================================================
% GRAPHING
%====================================================================================
avg = sum(ch,4)/simtot;
avg2 = mean(avg,3);
% fv2 = sum((reshape(avg(:,1,:),tt,reps,agshift)),1)/100;
% fv1 = reshape(fv2,11,11);
for n = 1: reps
    fv(:,n) = avg(trials:trials:end,1,n);
    fg(:,n) = avg(trials:trials:end,2,n);
    fn(:,n) = avg(trials:trials:end,3,n);
    fact(:,n) = avg(trials:trials:end,4,n);
end
%     fv2 = reshape(avg2(:,1),tt,reps);
%     fg2 = reshape(avg2(:,2),tt,reps);
%     fn2 = reshape(avg2(:,3),tt,reps);
%     fact2 = reshape(avg2(:,4),tt,reps);
%     
    fv2 = reshape(avg(:,1,6),tt,reps);
    fg2 = reshape(avg(:,2,6),tt,reps);
    fn2 = reshape(avg(:,3,6),tt,reps);
    fact2 = reshape(avg(:,4,6),tt,reps);
    
figure(1);
%     set(gca, 'ColorOrder', cl);
    subplot(4,2,2);
    plot(prl0,fv);%length(fv)-1,fv check
    title(['V(choice ' 'r=' num2str(rewvalue) ', p, increasing)']);
    
    subplot(4,2,4);
    plot(prl0,fg);
    title(['G(' 'r=' num2str(rewvalue) ', p, increasing)']);
 
    subplot(4,2,6);
    plot(prl0,fn);
    title(['N('  'r=' num2str(rewvalue) ', p, increasing)']);
    
    subplot(4,2,8);
    plot(prl0,fact);
    title(['Act(' 'r=' num2str(rewvalue) ', p, increasing)']);
    figure(2);
    plot(prl0,fact(:,11));
    title(['Act(' 'r=' num2str(rewvalue) ', p, increasing)']);
%     xlabel('p(R)');
%     subplot(4,2,1);
%     plot(1:length(fv2),fv2);%length(fv)-1,fv check
%     title(['V(choice ' 'r=' num2str(rewvalue) ', p, increasing)']);
%     xlim([0,100]);
%     subplot(4,2,3);
%     plot(1:length(fg2),fg2);
%     title(['G(' 'r=' num2str(rewvalue) ', p, increasing)']);
%     xlim([0,100]);
%     subplot(4,2,5);
%     plot(1:length(fn2),fn2);
%     title(['N('  'r=' num2str(rewvalue) ', p, increasing)']);
%     xlim([0,100]);
%     subplot(4,2,7);
%     plot(1:length(fact2),fact2);
%     title(['Act(' 'r=' num2str(rewvalue) ', p, increasing)']);
%     xlabel('p(R)');
%     xlim([0,100]);    
%     a = axes;
%     t1 = title(['Single state OPAL, aC=' num2str(aci)]);
%     a.Visible = 'off';
%     t1.Visible = 'on';
