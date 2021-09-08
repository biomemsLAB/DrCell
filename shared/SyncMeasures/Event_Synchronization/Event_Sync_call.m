% TS: Timestamps of spikes in seconds
% SaRa: Samplerate of original recorded data in Hz (usually 10000)
% tauMax: maximal tau in seconds (usually 0.04)
% precision:  - logarithm_10 ( sampling interval ) 1: 0.1ms, 0.1: 1ms, 0.01: 10ms


function [Sync,Delay]=Event_Sync_call(TS,SaRa,tauMax,precision)
    
    N=size(TS,2); % number of electrodes

    
    % calculate Matrix (pairwise sync)
    Sync=zeros(N);
    Sync(Sync==0)=NaN;
    Delay=Sync;
    for x=1:N-1
        for y=x+1:N
            if ~isempty(nonzeros(TS(:,x))) && ~isempty(nonzeros(TS(:,y)))
                [Sync(x,y),Delay(x,y)]= Event_Sync(nonzeros(TS(:,x)*SaRa),nonzeros(TS(:,y)*SaRa),tauMax*SaRa,precision);
                %[Sync(x,y),Delay(x,y)]= Event_Sync(nonzeros(TS(:,x)),nonzeros(TS(:,y)),tauMax,precision);
            end
        end
    end
    
    
end