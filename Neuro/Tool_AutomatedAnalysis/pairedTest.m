%% paired test using parameter dependent t-test and parameter free Wilcoxon signed rank test
% input:    x: n values that are assumed to be higher than y
%           y: n values that are assumed to be lower than x

function [pp,ppf,ppf_rel,validity]=pairedTest(x,y,Tail)

    % init
    pp = NaN; % parameter dependent
    ppf = NaN; % parameter free    
    ppf_rel = NaN; % parameter free relavite

    [~,pp,CI,STATS] = ttest(x,y,'Tail',Tail); % Tail='right': H1: x>y, Tail='both': H1: x!=y
    %delta=x-y;
    %pp=sum(delta) / sum(abs(x-y)); 
    if length(x)>=4 && length(y)>=4
        %[H_y, p_y] = lillietest(x);
        %[H_x, p_x] = lillietest(y);
        [H_y, p_y] = adtest(x); % anderson darling test has a higher test strength than lilliefors test
        [H_x, p_x] = adtest(y);
        validity=~H_y & ~H_x; % H=0 indicates that the null hypothesis ("the data are normally distributed") cannot be rejected at the 5% significance level. H=1 indicates that the null hypothesis can be rejected at the 5% level.
        %pp(~validity)=NaN;
    else
        validity=0;
    end

    [ppf,~,STATS] = signrank(x, y, 'Tail',Tail); % Tail='right': H1: x>y, Tail='both': H1: x!=y %Wilcoxon signed rank test -> for paired samples
    
    % also calculate relative ppf
    if sum(y)~=0 % if every element of y is zero, ppf is NaN
        [ppf_rel,~,STATS] = signrank(x./y, y./y, 'Tail',Tail); % Tail='right': H1: x>y, Tail='both': H1: x!=y %Wilcoxon signed rank test -> for paired samples
    end
    
    %X=matrix(:,:,1); % ref
    %Y=matrix(:,:,2); % bic
    %[h_smaller,p_smaller] = kstest2(x,y, 'tail','smaller');   % smaller: H1: F1(x)<F2(x) -> X>Y
    %[h_larger,p_larger] = kstest2(x,y, 'tail','larger');     % larger: H1: F1(x)>F2(x) -> X<Y
    %[h_unequal,p_unequal] = kstestx,y, 'tail','unequal');     % unequal: H1: F1(x)!=F2(x)
    %ppf=p_smaller;

end