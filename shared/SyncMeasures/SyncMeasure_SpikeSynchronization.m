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

function [Sync]=SyncMeasure_SpikeSynchronization(TS,rec_dur, flag_profile) 

    if nargin <=2
        flag_profile = 0;
    end

    %% 0) Init
    Sync.S=NaN;
    Sync.PREF.method='SPIKE-synchronization';
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
    
    %% 3) call synchrony measure
    S=STS.SPIKEsynchro();
    if flag_profile 
        Sync.PREF.P = NaN; % not available yet: STS.SPIKESynchroProfile(); 
        [Sync.PREF.M, Sync.PREF.OM, Sync.PREF.NOM] = STS.SPIKESynchroMatrix();
        % [SPIKESM,SPIKEOM,normSPIKEOM] = STS.SPIKESynchroMatrix(time1, time2, threshold);
        % SPIKESM: Spike synchronization matrix, SPIKEOM: Spike order matrix, normSPIKEOM: normalized spike order matrix
    end
    
    %% 4) Save results in structure
    Sync.S=S;
    
    t=toc;
    
    %% 5) save prefs:
    Sync.PREF.method='SPIKE-Synchronization';
    Sync.PREF.rec_dur=rec_dur;
    Sync.PREF.t=t; % calculation time
    
end