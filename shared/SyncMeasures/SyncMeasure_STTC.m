function [Sync]=SyncMeasure_STTC(TS,rec_dur,dt) % Selinger: (TS,rec_dur,30,0.5,0.5,true)
% input:    TS: Timestamps of Spikes (zero-padding!)
%           rec_dur: recording duration of the timestamp file in seconds,
%           dt: time in which spikes are considered synchronous 
% output:   Sync:   Sync.M:                 matrix containting sync values for each pair of electrode
%                   Sync.mean_M:            mean of M
%                   Sync.std_M:             std of M
%                   Sync.PREF:              settings    
%
% needed function:  [S]=STTC(x,y,T,dt)



    %% 1) call STTC_mc function:
    M=zeros(size(TS,2));
    M(M==0)=NaN;
    for i=1:size(TS,2)-1
        for j=i+1:size(TS,2)
            if ~isempty(nonzeros(TS(:,i))) && ~isempty(nonzeros(TS(:,j)))
                M(i,j)=STTC(TS(:,i),TS(:,j),rec_dur,dt); 
            else
                M(i,j)=NaN;
            end
        end
    end

    %% 2) Save results in structure
    Sync.M=M;
    Sync.mean_M=mean(M(:),'omitnan');
    Sync.std_M=std(M(:),'omitnan');
    
    %% 3) save settings:
    Sync.PREF.method='STTC';
    Sync.PREF.rec_dur=rec_dur;
    Sync.PREF.dt = dt;
    
end