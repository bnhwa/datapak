%=============================================================
%SIM OF PROBABALISTIC 1 STATE TASK WITHOUT REACH THRESHOLDS =
%fluid prob shift after x trials test subject has to adapt
cont = 1; %each prob separately tested as n(101) trials
%softmax is based on prob generated by softmax, 
%init = 1; init = 0 choose higher prob side ;init = 1; random 0.5 prob between choice

%=============================================================
choices = 1;
choice = 1;
probstate =1; %1 = incresing prob e.g., 0.1,0.2,0.3... 2= follows prl1
%=====================choices================================================
prl0 = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
prl1 = [0.1, 0.1, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 0.9, 0.9, 1];
prl = [prl0;prl1];
aci = 0.1;
agi = 0.1;
ani = 0.1;
bgi = 1;
bni = 1;
% func, v, g, n, act, prob1
vi = 0;
gi = .5;
ni = 1.5;
acti = -1;
% rewvalue = 1;
inczero = 1;
trials = 100;
agshift = 11;
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
        rewvalue = 0.0 + 0.2*(a-1);
        for r = 1:reps% 10 different probabilities (10 if probstate = 0)
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
                    ch(t,3,a,i) = ch(t-1,3,a,i) + ani*(-1*sigmat)*ch(t-1,3,a,i); %n(t) = n(t-1) + an*n(t-1)*sigmat
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

fv2 = sum((reshape(avg(:,1,:),tt,reps,agshift)),1)/101;
fv1 = reshape(fv2,11,11);

fv = reshape((sum((reshape(avg(:,1,:),tt,reps,agshift)),1)/101),11,11)
fg = reshape((sum((reshape(avg(:,2,:),tt,reps,agshift)),1)/101),11,11)
fn = reshape((sum((reshape(avg(:,3,:),tt,reps,agshift)),1)/101),11,11)
fact = reshape((sum((reshape(avg(:,4,:),tt,reps,agshift)),1)/101),11,11)

figure(1);
    subplot(4,2,1);
    plot(prl0,fv);%length(fv)-1,fv check
    title(['V(choice ' 'r=' num2str(rewvalue) ', p, increasing)']);
    
    subplot(4,2,3);
    plot(prl0,fg);
    title(['G(' 'r=' num2str(rewvalue) ', p, increasing)']);
 
    subplot(4,2,5);
    plot(prl0,fn);
    title(['N('  'r=' num2str(rewvalue) ', p, increasing)']);
    
    subplot(4,2,7);
    plot(prl0,fact);
    title(['Act(' 'r=' num2str(rewvalue) ', p, increasing)']);
    xlabel('p(R)');