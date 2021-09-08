% this function calculates the correlation between signal x and y
%
% Input:
% x: binned spiketrain 1
% y: binned spiketrain 2
%
% Output:
% r: max. correlation value (-1 ... +1)

function [r]=Correlation(x,y) 
        
    N=length(x);
  
    % definition Selinger et al.:
    sum1=0;
    sum2=0;
    sum3=0;
    sum4=0;
    sum5=0;
    sum6=0;
    sum7=0;
    
    for t=1:N
       sum1=sum1+(x(t)*y(t));
       sum2=sum2+x(t);
       sum3=sum3+y(t);
       sum4=sum4+(x(t)^2);
       sum5=sum2;
       sum6=sum6+(y(t)^2);
       sum7=sum3;
    end
    
    r = (N*sum1 - sum2*sum3) * (N*sum4 - sum5^2)^(-0.5) * (N*sum6 - sum7^2)^(-0.5);


%     % usual definition:
%     sum=0;
%     for t=1:N
%        sum = sum + ((x(t)-mean(x))*(y(t)-mean(y)))/(std(x)*std(y)); 
%     end
%     r = sum/N;

end