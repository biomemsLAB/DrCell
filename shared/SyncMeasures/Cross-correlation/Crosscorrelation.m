% this function calculates the cross-correlation between signal x and y (different to matlab's xcorr as here negative r-values are possible!)
%
% Input:
% x: binned spiketrain 1
% y: binned spiketrain 2
% maxlag: "lagtime" in samples, defines how far y is shifted against x (maxlag=0:
% no shift -> simple correlation, maxlag=length(x)=length(y): shift over whole
% signal)
%
% Output:
% old: rmax: max. correlation value (-1 ... +1)
% old: dmax: delay in samples
% r: all correlation values
% d: all corresponding lag values

function [r,d]=Crosscorrelation(x,y,maxlag) 
        
    if maxlag>=length(x)
       maxlag=maxlag-1; % limit maxlag to N-1 (maxlag-2 as zero belongs also to N)
    end
    
    % init
    x(end:end+maxlag)=0;
    y(end:end+maxlag)=0;

    % calculate cross-correlation:
    r = zeros(1,length(-maxlag:maxlag)); % init
    d = r; % init
    i=0; % array index
    for lag=-maxlag:maxlag
        yd=circshift(y,[0,lag]);
        i=i+1;
        r(i)=Correlation(x,yd);
        d(i)=lag;
    end

%     N=length(x);
%     sum=0;
%     mx = mean(x);
%     my = mean(y);
%     sx = std(x);
%     sy = std(y);
%     denom=sx*sy;
%     for i=1:N
%         j= i + maxlag;
%         if j<0 || j>=N
%             sum=sum+ (x(i)-mx) * (-my); 
%         else
%             sum=sum+ (x(i)-mx) * (y(j)-my); 
%         end
%         r(i)=sum/denom;
%         d(i)=j;
%     end
%     %r = sum/denom;

   % [rmax,dindex]=max(r);
   % dmax=d(dindex);

end