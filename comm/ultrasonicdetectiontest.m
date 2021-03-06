filepathp = '/Users/hwab/Dropbox (HHMI)/2015-16 experiment/comm/receive/DataBuffer/';
fnamesp = dir(strcat(filepathp,'*.csv'));
ns = length(fnamesp);%number of test subjects
testobject = {'metal', 'acryllic', 'pencil'};

for k = 1:ns
    fnamep = fnamesp(k).name;
    tpd1 = csvread(strcat(filepathp,fnamep));
    tpd1(:,1) = tpd1(:,1)-tpd1(1,1);
    if k<2
        tpd = [tpd1,repmat(k:k, [size(tpd1,1),1])];
    else
        tpd = vertcat(tpd,[tpd1,repmat(k:k, [size(tpd1,1),1])]);
    end
    figure(1);
        subplot(ns,1,k);
                set(gca,'fontsize',18);
%         plot(tpd(tpd(:,3)==k,1),tpd(tpd(:,3)==k,2));
        plot(tpd(:,2),tpd(:,3));
%         title(strcat('Distance over time(milliseconds)with: ',testobject{k}));
        title('example reaches, starting point = 63 cm');
        xlabel('Time(milliseconds)');
        ylabel('Distance(cm)');
end