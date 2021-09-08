% this function calculates the cross-mutualInformation between signal x and y (different to matlab's xcorr as here negative r-values are possible!)
%
% Input:
% x: binned spiketrain 1
% y: binned spiketrain 2
% maxlag: "lagtime" in samples, defines how far y is shifted against x (maxlag=0:
% no shift -> simple mutual information, maxlag=length(x)=length(y): shift over whole
% signal)
%
% Output:
% rmax: max. mutual information value (not normalized!)
% dmax: delay in samples

function [rmax,dmax]=CrossMutualInformation(x,y,maxlag) 
        
    if maxlag>=length(x)
       maxlag=maxlag-1; % limit maxlag to N-1 (maxlag-2 as zero belongs also to N)
    end
    
    if size(x,2)>1 % make sure that second dimension is one
        x=x';
        y=y';
    end
    
    % init
    %x(end+1:end+maxlag)=0;
    %y(end+1:end+maxlag)=0;

    % calculate cross-correlation:
    r = zeros(1,length(-maxlag:maxlag)); % init
    d = r; % init
    i=0; % array index
    for lag=-maxlag:maxlag
        yd=circshift(y,[lag,0]);
        i=i+1;
        r(i)=MutualInformation(x,yd);
        d(i)=lag;
    end

    [rmax,dindex]=max(r);
    dmax=d(dindex);

end