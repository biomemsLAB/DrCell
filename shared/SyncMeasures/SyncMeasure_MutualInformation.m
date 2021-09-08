
function [Sync]=SyncMeasure_MutualInformation(TS,rec_dur,bin,step,binary,norm) 
% input:    TS: Timestamps of Spikes or Bursts, 
%           rec_dur: recording duration of the timestamp file in seconds,
%           bin: binsize in seconds to discretize spiketrain
%           step: step of bin in seconds (no overlap if step==bin)
%           binary: false: normal binning, true: binary binning
%           norm: method of normalisation,  norm=0: no normalization, 
%                                           norm=1: MI/min(H1,H2), 
%                                           norm=2: 2*MI/(H1+H2), -> norm=2 is more stable
% output:   Sync:   Sync.M:                 matrix containting sync values for each pair of electrode
%                   Sync.mean_M:            mean of M
%                   Sync.std_M:             std of M
%
% needed function:  I = MutualInformation(X,Y)

    
    %% 1) binning:
    %numBins=length(0:step:rec_dur); % in some cases two too much
    %TS_binned=zeros(numBins,size(TS,2));
    %tic
    for n=1:size(TS,2)
        TS_binned(:,n)=binning(nonzeros(TS(:,n)),rec_dur,bin,step,binary);
    end
    %toc

    %% 2) calculate MI for each electrode pair:
    %tic
    M=zeros(size(TS_binned,2));
    M(M==0)=NaN;
    for i=1:size(TS_binned,2)-1
        for j=i+1:size(TS_binned,2)
            Hi = Entropy(TS_binned(:,i));
            Hj = Entropy(TS_binned(:,j));
            if ~isempty(nonzeros(TS_binned(:,i))) && ~isempty(nonzeros(TS_binned(:,j)))
                M(i,j)=MutualInformation(TS_binned(:,i),TS_binned(:,j));
            else
                M(i,j)=NaN;
            end
            
            % normalize:
            if norm==1
                M(i,j)=M(i,j)/min(Hi,Hj);
            elseif norm==2
                M(i,j)=2*M(i,j)/(Hi + Hj); % more robust when sparse and dense signals are compared with each other
            end
        end
    end
    %toc

    

    %% 3) Save results in structure
    Sync.M=M;
    Sync.mean_M=mean(M(:),'omitnan');
    Sync.std_M=std(M(:),'omitnan');
    
    %% 4) save prefs:
    Sync.PREF.method='Mutual Information';
    Sync.PREF.rec_dur=rec_dur;
    Sync.PREF.binSize=bin;
    Sync.PREF.binStep=step;
    Sync.PREF.binary=binary;
    Sync.PREF.norm=norm;
    
end