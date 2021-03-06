% classdef shade
%     methods(Access = public)
function [f1, col1] = shade(arr, minv, hval, height,col,ltr)
%array([data,ndatasets],logical array for conditions, stem base value (make low e.g., -2
% , y val to place at, height of bar (goes down from yval placed at),
% %color, line thickness
% BY BAILEY N. HWA, 2015-2016 HHMI
% color array
    hold off
    if nargin ==0
    end
%     f1 = arr;
    for i = 1:size(arr,2)
        if nargin ==5
            f1 = find((arr(:,i))==1);
            if iscellstr(col)==1
                col1 = col{i};
            end
            if isnumeric(col)==1
                col1 = col(i,:);
            end
            hold on
            c1 = stem(f1,(repmat(1:1,numel(f1),1))*(hval(i)),'LineWidth',1,...
                'Marker','s','BaseValue',minv, 'MarkerSize',0.1,'Color',col1);
            c1.BaseLine.Visible = 'off';
            hold all
            bar((repmat(1:1,500,1))*(hval(i) - height(i)),'FaceColor','w','Barwidth',1,'EdgeColor','w','LineWidth',1, ...
                    'BaseValue',minv);
        end
        if nargin ==6
            f1 = find((arr(:,i))==1);
            if iscellstr(col)==1
                col1 = col{i};
            end
            if isnumeric(col)==1
                col1 = col(i,:);
            end
            hold on
            c1 = stem(f1,(repmat(1:1,numel(f1),1))*(hval(i)),'LineWidth',ltr(i),...
                'Marker','s','BaseValue',minv, 'MarkerSize',0.1,'Color',col1);
            c1.BaseLine.Visible = 'off';
            hold all
            bar(abs(repmat(1:1,size(arr,1),1))*(hval(i) - height(i)),'FaceColor','w','Barwidth',1,'EdgeColor','w','LineWidth',1.1, ...
                    'BaseValue',minv);
        end
    end
    
    end
% end
% end
