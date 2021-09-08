%% Bin time stamps and calculate number of spikes per bin and number of active electrodes per bin
% Input:    TS:                 time stamps of spikes in seconds (dim: maxNumOfSpikesPerEl x numOfElectrodes)
%                               rec_dur: recording duration of the timestamp file in seconds,
%                               bin: binsize in seconds to discretize spiketrain
%                               step: bin-step, if step==bin -> no overlap
% Output:   AllSpikesPerBin:    array with number of spikes per bin 
%           actElPerBin:        array with number of active electrodes per
%           edges:              edges of bins
%           x:                  center of bins
%
% needed functions: [y_binned,x_step,edges_step]=binning(y,rec_dur,binsize,step,flag_binary) 

function [AllSpikesPerBin,actElPerBin,edges,x]=getNumSpikesAndActElPerBin(TS,rec_dur,bin,step)

    %% 0) init       
    [~,x,edges]=binning(nonzeros(TS(:)),rec_dur,bin,step,0);                % calc edges and bin center 
    %[~,x,edges]=boxcar(nonzeros(TS(:)),rec_dur,1/100,0,0); % bin size zero, only size of x and edges is important
    SPIKEHISTOGRAM=zeros(length(x),size(TS,2));
       
    %% 1) calculate histogram for each electrode
    for n=1:size(TS,2)
       %SPIKEHISTOGRAM(:,n)=histcounts(nonzeros(TS(:,n)),edges);
       SPIKEHISTOGRAM(:,n)=binning(nonzeros(TS(:,n)),rec_dur,bin,step,0);  % y_binned=binning(y,rec_dur,binsize,step,flag_binary)
       %SPIKEHISTOGRAM(:,n)=boxcar(nonzeros(TS(:,n)),rec_dur,1/100,bin,0);    
    end
    if size(SPIKEHISTOGRAM,1)==1                                            % in case only one El is active the size of hist would be [1,numberOfbins]
        SPIKEHISTOGRAM=SPIKEHISTOGRAM';
    end           

    %% 2) calculate parameter over all electrodes 
    AllSpikesPerBin=sum(SPIKEHISTOGRAM,2)';                                 % number of spikes per bin over all electrodes

    mask=SPIKEHISTOGRAM~=0;
    actElPerBin=sum(mask,2)';                                               % number of active electrodes per bin
        
end