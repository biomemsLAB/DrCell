function [Sync]=SyncMeasure_Crosscovariance(TS,rec_dur,bin,step,lag,binary) 
% input:    TS: Timestamps of Spikes or Bursts, 
%           rec_dur: recording duration of the timestamp file in seconds,
%           bin: binsize in seconds to discretize spiketrain
%           step: step of bin in seconds (no overlap if step==bin)
%           binary: false: normal binning, true: binary binning
% output:   Sync:   Sync.M:                 matrix containting sync values for each pair of electrode
%                   Sync.mean_M:            mean of M
%                   Sync.std_M:             std of M
%                   Sync.delay:             delay between each electrode in seconds
%                   Sync.lag:               delay between each electrode in samples
%
% needed function: [y_binned,x_step,edges_step]=binning(y,rec_dur,binsize,step,flag_binary) 

    
    %% 1) binning:
    %numBins=length(0:step:rec_dur);
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
                if ~isnan(lag)
                    [xcor,xlag] = xcov(TS_binned(:,i),TS_binned(:,j),lag,'coeff'); % custom value for lag
                else
                    [xcor,xlag] = xcov(TS_binned(:,i),TS_binned(:,j),'coeff'); % default value for lag = max lag
                end
                M(i,j)=max(xcor);
                [~,I] = max(abs(xcor));
                Sync.lag(i,j)=xlag(I);
                Sync.delay(i,j)=xlag(I)*bin;
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
    Sync.PREF.method='Cross-covariance';
    Sync.PREF.rec_dur=rec_dur;
    Sync.PREF.binSize=bin;
    Sync.PREF.binStep=step;
    Sync.PREF.lag=lag;
    Sync.PREF.binary=binary;
    
end

