function [TS, AMP]=DeleteSpikesByAmplitude(TS,AMP,th)
    TS(TS==0)=NaN;
    mask=AMP>th;
    TS(mask)=NaN;
    AMP(mask)=NaN;
    
    %% sort TS and AMP
    for n=1:size(TS,2)
        [TS(:,n), Index]=sort(TS(:,n));
        AMP(:,n)=AMP(Index,n);
    end

end

