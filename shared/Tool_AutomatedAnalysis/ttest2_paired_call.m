% --- ttest_call - compare variable x with variable y (using ttest -> two paired samples) 
function [p,validity]=ttest2_paired_call(x,y, normalize_flag) % x(y(c),1,MEA#)

    x=squeeze(x); % x(y(c),MEA#)
    y=squeeze(y); % y(y(c),MEA#)

    if normalize_flag
      for i=1:size(x,1)
        x_temp(i,:)=x(i,:)./x(1,:); 
        y_temp(i,:)=y(i,:)./y(1,:);
      end
      x=x_temp;
      y=y_temp;
    end

    % set all NaN-Values to zero
%     x(isnan(x))=0; 
%     y(isnan(y))=0; 

    
    % test if normal distributed:
    x_normalDistributed=NaN;
    y_normalDistributed=NaN;
    if size(nonzeros(~isnan(x)),1)>=4
        x_notTestedIFnormalDistributed=0;
        if lillietest(x)==0
            x_normalDistributed=1;
        else
            x_normalDistributed=0;
        end 
    else
        x_notTestedIFnormalDistributed=1;
    end
    if size(nonzeros(~isnan(y)),1)>=4
        y_notTestedIFnormalDistributed=0;
        if lillietest(y)==0
            y_normalDistributed=1;
        else
            y_normalDistributed=0;
        end 
    else
        y_notTestedIFnormalDistributed=1;
    end

    h=0; hp=0; p=1; pp=1;

    % if not normally distributed use parameter free test 
    if x_notTestedIFnormalDistributed==1 || y_notTestedIFnormalDistributed==1 || x_normalDistributed==0 || y_normalDistributed==0
        %[p,~] = ranksum(x,y,'Tail','right'); % unpaired samples: Mann-Whitney U-test aka Wilcoxon rank sum test
        %[p,~] = signrank(x,y,'Tail','right'); % paired samples: Wilcoxon signed rank test
        %p=NaN;
        [h,p,ci,stats] = ttest(x,y,'Tail','right'); % 'Tail','right' -> H0: x==y, H1: x>y
        validity=false;
    end 

    % ttest
    if x_normalDistributed==1 && y_normalDistributed==1
            [h,p,ci,stats] = ttest(x,y,'Tail','right'); % 'Tail','right' -> H0: x==y, H1: x>y
            validity=true;
    end



end
