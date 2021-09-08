%% NOTE: here the code of cSPIKE is used which should be faster than the code of SPIKY
% input:    TS: Timestamps of Spikes or Bursts, 
%           rec_dur: recording duration of the timestamp file in seconds,
%           flag_profile = 1: synchrony over time and matrix is also
%           calculated, 0: it is not calculated
% output:   Sync:   Sync.S:                 Synchrony index
%                   Sync.PREF:              preferences    
%           if flag_profile:
%                   Sync.PREF.P:            Profile => Sync.PREF.P.PlotProfileX(), Sync.PREF.P.PlotProfileY()
%                   Sync.PREF.M:            Synchrony Matrix

function [Sync]=SyncMeasure_AISIDistance(TS,rec_dur, flag_profile) 

    if nargin <=2
        flag_profile = 0;
    end

    %% 0) Init
    Sync.S=NaN;
    Sync.PREF.method='A-ISI-distance';
    Sync.PREF.rec_dur=rec_dur;

    %% 1) Matrix to cell format (NaN-patting)
    % check data
    if size(TS,1)<2
       warning('File contains less than two spikes per spike train')
       return
    end
    
    TS=TS_M2Cell(TS);
    
    % erase emtpy cells
    TS = TS(~cellfun(@isempty, TS));
    
    % check data
    if size(TS,2)<2 
       warning('File contains only one spike train.')
       return 
    end
    
    tic
    
    %% 2) Generate object to call synchrony measure functions from cSPIKE
    STS = SpikeTrainSet(TS,0,rec_dur);
    
    %% 3) call distance measure
    D=STS.AdaptiveISIdistance();
    if flag_profile 
        Sync.PREF.P = STS.AdaptiveISIdistanceProfile(); 
        Sync.PREF.M = STS.AdaptiveISIdistanceMatrix();
    end 
    
    %% 4) Synchrony = 1 - Distance
    S=1-D;    
    
    t=toc; % calculation time

    %% 5) Save results in structure
    Sync.S=S;
    
    %% 6) save prefs:
    Sync.PREF.t=t; % calculation time
    
end