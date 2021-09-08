function [Sync]=SyncMeasure_Crosscorrelation(TS,rec_dur,bin,step,lag,binary) 
% TS: Timestamps of Spikes or Bursts, 
% rec_dur: recording duration of the timestamp file in seconds,
% bin: binsize in seconds to discretize spiketrain
% step: step of bin in seconds (no overlap if step==bin)
% lag: max lag in samples
% binary: false: normal binning, true: binary binning


    for f=1:size(TS,3)
        
        % 1) binning:
        for n=1:size(TS,2)
            TS_binned(:,n,f)=binning(nonzeros(TS(:,n,f)),rec_dur,bin,step,binary);
        end
        
        % if lag == NaN set lag to default value
        if isnan(lag)
           lag = size(TS_binned,1)-1; 
        end
        
        % 2) call cross-correlation function:
        M=zeros(size(TS_binned,2));
        M(M==0)=NaN;
        for i=1:size(TS_binned,2)-1
            for j=i+1:size(TS_binned,2)
                if ~isempty(nonzeros(TS_binned(:,i,f))) && ~isempty(nonzeros(TS_binned(:,j,f)))
                    %[xcor,~]=xcorr(TS_binned(:,i,f),TS_binned(:,j,f),'coeff');
                    %[xcor,~]=xcov(TS_binned(:,i,f),TS_binned(:,j,f),lag,'coeff');
                    [xcor,~]=xcorr(TS_binned(:,i,f),TS_binned(:,j,f),lag,'coeff'); % coeff: normalization autocorr=1
                    %[xcor,~]=Crosscorrelation(TS_binned(:,i,f),TS_binned(:,j,f),lag); % crosscorrelation (MC) using correlation as in statistic book
                    M(i,j)=max(xcor);
                    %[~,I] = max(abs(xcor));
                    %CC_lag(i,j,f)=xlag(I);
                end
            end
        end
        
        CC_M(:,:,f)=M;

        % 3) calculate mean and std
        CC_mean(f)=mean(nonzeros(CC_M(:,:,f)),'omitnan');
        CC_std(f)=std(nonzeros(CC_M(:,:,f)),'omitnan');
        
    end
    
    % calc mean of all temporary files
    Sync.mean_M=mean(CC_mean);
    Sync.std_M=mean(CC_std);
    for i=1:size(CC_M,1)
        for j=1:size(CC_M,2)
            Sync.M(i,j)=mean(CC_M(i,j,:),'omitnan');
        end
    end
    
    %% 4) save prefs:
    Sync.PREF.method='Cross-correlation (xcor)';
    Sync.PREF.rec_dur=rec_dur;
    Sync.PREF.binSize=bin;
    Sync.PREF.binStep=step;
    Sync.PREF.binary=binary;
    
end