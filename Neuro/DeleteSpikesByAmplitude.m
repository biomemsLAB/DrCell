% delete spikes from spike train which amplitudes are greater than
% threshold (MC)
% (e.g. th=-50 µV, AMP= -20 µV, TS and AMP are deleted)
% (e.g. th=-50 µV, AMP= -60 µV, TS and AMP are kept)

function [TS, AMP]=DeleteSpikesByAmplitude(TS,AMP,th)
    TS(TS==0)=NaN;
    mask=AMP>th; % if mask is 1 these spikes are deleted
    TS(mask)=NaN;
    AMP(mask)=NaN;
    
    %% sort TS and AMP
    for n=1:size(TS,2)
        [TS(:,n), Index]=sort(TS(:,n));
        AMP(:,n)=AMP(Index,n);
    end

end

