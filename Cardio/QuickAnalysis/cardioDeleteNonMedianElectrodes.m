function [TS,AMP,numSpikes] = cardioDeleteNonMedianElectrodes(TS,AMP)

% init
numSpikes = 0;

[TS,AMP] = zeroPadding(TS,AMP);

% delete Spike trains which have a different number of spikes as
% the median number of spikes
for n=1:size(TS,2)
    temp = TS(:,n);
    FR(n) = length(nonzeros(temp));
end

if sum(FR)>0 % if any spikes
    
    edges = 0.5:1:max(FR)+0.5;
    [f,edges]=histcounts(nonzeros(FR),edges);
    [~,idx] = max(f);
    FRmin = edges(idx);
    FRmax = edges(idx+1);
    numSpikes = FRmin + 0.5;
    
    numDeletedElectrodes = 0;
    electrodes_toBeDeleted = NaN;
    idx=1;
    for n=1:size(TS,2)
        if (FR(n) < FRmin || FR(n) > FRmax) && FR(n) ~= 0
            electrodes_toBeDeleted(idx)=n;
            idx=idx+1;
            numDeletedElectrodes = numDeletedElectrodes +1;
        end
    end
    
    disp(['Delete non-median electrodes (if firing rate is not between ' num2str(FRmin) ' and ' num2str(FRmax) '):'])    
    [TS,AMP]=cardioDeleteElectrodes(TS,AMP,electrodes_toBeDeleted);
    
else
    disp('Data contains no spikes')
end

end