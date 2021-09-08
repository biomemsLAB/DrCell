function [Sync]=SyncMeasure_Crosscorrelation_Selinger(TS,rec_dur,bin,step,binary) % Selinger: (TS,rec_dur,30,0.5,0.5,true)
% input:    TS: Timestamps of Spikes (zero-patting!)
%           rec_dur: recording duration of the timestamp file in seconds,
%           bin: binsize in seconds to discretize spiketrain
%           step: step of bin in seconds (no overlap if step==bin)
%           binary: false: normal binning, true: binary binning
% output:   Sync:   Sync.M:                 matrix containting sync values for each pair of electrode
%                   Sync.mean_M:            mean of M
%                   Sync.std_M:             std of M
%                   Sync.PREF:              preferences    
%
% needed function:  [r]=Crosscorrelation_selinger(x,y)
%                   [y_binned,x_step,edges_step]=binning(y,rec_dur,binsize,step,flag_binary) 

    
    %% 1) binning:
    %numBins=length(0:step:rec_dur-step);
    %TS_binned=zeros(numBins,size(TS,2));
    for n=1:size(TS,2)
        TS_binned(:,n)=binning(nonzeros(TS(:,n)),rec_dur,bin,step,binary);
    end

    %% 2) call cross-correlation function:
    M=zeros(size(TS_binned,2));
    M(M==0)=NaN;
    for i=1:size(TS_binned,2)-1
        for j=i+1:size(TS_binned,2)
            if ~isempty(nonzeros(TS_binned(:,i))) && ~isempty(nonzeros(TS_binned(:,j)))
                M(i,j)=Crosscorrelation_selinger(TS_binned(:,i),TS_binned(:,j)); 
            else
                M(i,j)=NaN;
            end
        end
    end

    %% 3) Save results in structure
    Sync.M=M;
    Sync.mean_M=mean(M(:),'omitnan');
    Sync.std_M=std(M(:),'omitnan');
    
    %% 4) save prefs:
    Sync.PREF.method='Cross-correlation (Selinger)';
    Sync.PREF.rec_dur=rec_dur;
    Sync.PREF.binSize=bin;
    Sync.PREF.binStep=step;
    Sync.PREF.binary=binary;
    
end