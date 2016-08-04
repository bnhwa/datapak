%=============================================================
%SIM OF PROBABALISTIC 2 STATE TASK WITHOUT REACH THRESHOLDS =
%fluid prob shift after x trials test subject has to adapt
cont = 1; %each prob separately tested as n(101) trials
%if cont = 2; prob tested successively, one after the other (101*reps) trials
%softmax is based on prob generated by softmax, 
%init = 1; init = 0 choose higher prob side ;init = 1; random 0.5 prob between choice

%=============================================================
choices = 2;
cho = [1,2]
choice = 1;
probstate =1; %1 = incresing prob e.g., 0.1,0.2,0.3... 2= follows prl1
%=====================================================================
prl0 = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
% prl1 = [0.1, 0.1, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 0.9, 0.9];
% prl = [prl0;prl1];
aci = 0.05;
agi = 0.1;
ani = 0.1;
bgi = 1;
bni = 1;
% func, v, g, n, act, prob1
vi = 0.5;
gi = 1;
ni = 1;
acti = 0;
rewvalue = 1;
inczero = 1;
trials = 100;
reps = 11;%at different probs
simtot = 1000;%total repetitition
shiftstate = 1;
tt = trials + inczero;
st = tt*reps;
% ch = cell(simtot);%1000,2 choices
ch = zeros(st,7,choices,simtot);
sm = zeros(st,choices,simtot);
color = varycolor(reps);
%====================================================================================
%===prob generation==================================================================
%====================================================================================
prob = rand(st,choices,simtot);% if 2 choices, first 1010rows for choice1 next 1010 for choice 2 etc.
pr = zeros(st,choices);%probability of reward
%first 1000 columns for choice1 next columns.
for i = 1: st
    pr(i,1) = prl0((fix((i-1)/(tt))+1));
    pr(i,2) = 1-pr(i,1);
end
%====================================================================================
%===simulation=======================================================================
%====================================================================================

for i = 1: simtot%1000 total sim
    for r = 1:reps% 10 different probabilities (10 if probstate = 0)
        for j = 1:tt%101 including 0 trials
            t = ((r-1)*tt + j);
            tiebreaker = randi(choices);
            for c = 1: choices%choices
                %t = ((r-1)*tt + j);
                if (j == 1 && cont == 1) || t == 1%first trial in every rep or first in general
                    sigmat = 0;
                    ch(t,1,c,i) = vi;
                    ch(t,2,c,i) = gi;
                    ch(t,3,c,i) = ni;
                    ch(t,4,c,i) = bgi*ch(t,2,c,i)-bni*ch(t,3,c,i);
                else
                    sigmat = (ch(t-1,7,c,i) - ch(t-1,1,c,i));%sigmat = r(t-1)-v(t-1)
                    ch(t,1,c,i) = ch(t-1,1,c,i) + aci*sigmat;%v(t) = v(t-1) + ac*sigmat
                    ch(t,2,c,i) = ch(t-1,2,c,i) + agi*sigmat*ch(t-1,2,c,i);%g(t) = g(t-1) + ag*g(t-1)*sigmat
                    ch(t,3,c,i) = ch(t-1,3,c,i) + (-1)*ani*sigmat*ch(t-1,3,c,i); %n(t) = n(t-1) + an*n(t-1)*sigmat
                    ch(t,4,c,i) = bgi*ch(t,2,c,i)-bni*ch(t,3,c,i);%act(t) = bg*g(t) - bn*n(t)
                end
            end
%             sumc1 = ch{i,1}(t,4)+ch{i,2}(t,4);
%             sumc = sum(cellfun(@(x) x(t,4),ch(i)));
            for c = 1: choices
                if range(ch(t,4,:,i)) == 0
                    ch(t,5,c,i) = 1/choices;
                else
                    ch(t,5,c,i) = (exp(ch(t,4,c,i)))/sum(exp(ch(t,4,1,i)+exp(ch(t,4,2,i))));
                end
%                     sm(t,c,i) = ch(t,5,c,i);
            end
%====================================================================================
% DEFINE A SOFTMAX RULE
%====================================================================================
%           hardmax[M,I] = max(ch{i,1:choices}(t,5)); picks highest prob
%             p = cumsum([0; sm(t,1:end-1,i).'; 1+1e3*eps]);
%             [a, a] = histc(rand,p);
            pick = cho(find(rand<cumsum(ch(t,5,:,i)),1,'first'));
            for c = 1: choices
                if c == pick
                    ch(t,6,c,i) = 1;
                    if rand <= pr(t,c)
                        ch(t,7,c,i) = rewvalue;
                    else
                        ch(t,7,c,i) = 0;
                    end
                else
                    ch(t,6,c,i) = 0;
                    ch(t,7,c,i) = 0;
                end
            end
        end
    end
end
%====================================================================================
% GRAPHING
%====================================================================================
avg = sum(ch,4)/simtot;
bias = reshape((avg(:,5,1)-avg(:,5,2)),tt, reps);
% avgc = 
for c = 1: choices
fv = reshape(avg(:,1,c),tt,reps);
fg = reshape(avg(:,2,c),tt,reps);
fn = reshape(avg(:,3,c),tt,reps);
fact = reshape(avg(:,4,c),tt,reps);
avgc = reshape(avg(:,5,c),tt,reps);
figure(1);
    subplot(4,2,c);
    plot(0:length(fv)-1,fv);
    title(['V(choice ' num2str(c) 'r=' num2str(rewvalue) ', p, increasing)']);
    subplot(4,2,2+c);
    plot(0:length(fg)-1,fg);
    title(['G(choice' num2str(c) 'r=' num2str(rewvalue) ', p, increasing)']);

    subplot(4,2,4+c);
    plot(0:length(fn)-1,fn);
    title(['N(choice' num2str(c) 'r=' num2str(rewvalue) ', p, increasing)']);

    subplot(4,2,6+c);
    plot(0:length(fact)-1,fact);
    title(['Act(choice' num2str(c) 'r=' num2str(rewvalue) ', p, increasing)']);
    xlabel('time');
figure(3);
    subplot(4,2,c);
    plot(0:length(fv)-1,fv);
    title(['Choice' num2str(c)]);
    subplot(4,2,2+c);
    plot(0:length(fg)-1,fg);
    title(['G(choice' num2str(c) 'r=' num2str(rewvalue) ', p, increasing)']);

end
figure(2)
    subplot(4,2,1);
    plot(0:length(bias)-1, bias);
    title(['bias p(c1-c2)'', p, increasing)']);
    xlabel('time');
    ylabel('bias');

    