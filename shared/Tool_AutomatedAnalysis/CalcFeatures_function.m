%% in this function all parameter like Spikerate, Burstrate, Networkbursts, Crosscorrelation ect. are calculated
% input:    MERGED:                 structure conainting all TS files merged together
%           MERGED.PREF.rec_dur:    duration of merged TS file in seconds
%           MERGED.PREF.SaRa:       sample rate used to record raw signals in Hz
%           MERGED.TS:              time stamps of all TS files in seconds(zero padding)
%           MERGED.AMP:             amplitudes of all TS files in uV
%
%           Selection:              cell array conainting names of parameters that has to be calculated ***
%           time_win:               window length in seconds (if duration of all TS files is 300 s and parameter shall be calculated for every 60 s, set time_win=60)
%           FR_min:                 minimum firing rate (aka spike rate) in spikes/minute to be active (e.g. FR_min=6, all electrodes are cleared that contains less than 6 spikes per minute)
%           N:                      number of active electrodes (only needed for function "Sync_Contrast_fixed")
%           binSize:                specify binSize (default = 500 ms)
%
%
% output:   WIN:                        structure containing all parameter for each time_win
%           WIN(i).parameter(k).mean    scalar value of parameter k (i-th window) over all electrodes
%           WIN(i).parameter(k).values  values that have been used to calculate field "mean"
%           WIN(i).parameter(k).std     standard deviation of parameter k if available
%           WIN(i).parameter(k).allEl   scalar value of parameter k for each electrode (needed for electrode wise calculation)
%           MERGED:                     same as input but with x-axis values
%
% NOTE: use function FEATURES=unpackWIN2FEATURES(WIN) to calculate electrdoe wise parameter and unpack WIN into a more handy structure

% *** these parameter names are available:
% Selection={ ...
% 'Spikerate',...
% 'Number of spikes',...
% 'Amplitude',...
% 'ActiveElectrodes',...
% 'BR_baker100',...
% 'BD_baker100',...
% 'SIB_baker100',...
% 'IBI_baker100',...
% 'BR_baker200',...
% 'BD_baker200',...
% 'SIB_baker200',...
% 'IBI_baker200',...
% 'BR_selinger',...
% 'BD_selinger',...
% 'SIB_selinger',...
% 'IBI_selinger',...
% 'NBR_chiappalone',...
% 'NBD_chiappalone',...
% 'SINB_chiappalone',...
% 'INBI_chiappalone',...
% 'NBR_jimbo',...
% 'NBD_jimbo',...
% 'SINB_jimbo',...
% 'INBI_jimbo',...
% 'NBR_MC',...
% 'NBD_MC',...
% 'SINB_MC',...
% 'INBI_MC',...
% 'Sync_CC_selinger',...
% 'Sync_STTC',...
% 'Sync_MI1',...
% 'Sync_MI2',...
% 'Sync_PS',...
% 'Sync_PS_M',...
% 'Sync_Contrast',...
% 'Sync_Contrast_fixed',...
% 'Sync_ISIDistance',...
% 'Sync_SpikeDistance',...
% 'Sync_SpikeSynchronization',...
% 'Sync_ASpikeSynchronization',...
% 'Sync_AISIDistance',...
% 'Sync_ASpikeDistance',...
% 'Sync_RISpikeDistance',...
% 'Sync_RIASpikeDistance',...
% 'Sync_EarthMoversDistance',...
% 'Connectivity_TSPE',...
% 'Connectivity_TSPE_70percent',...
% 'Connectivity_TSPE_withSurrogateThreshold',...
% 'Entropy_bin100',...
% 'Entropy_capurro'
%     };

function [WIN,MERGED]=CalcFeatures_function(MERGED,Selection,time_win,FR_min,N,binSize,flag_60HDMEA, flag_norm, flat_waitbar)

if nargin == 4
    N = 60; % set number of electrodes to a fixed value (only needed for 'Sync_Contrast_fixed')
    binSize = [];
    flag_60HDMEA = 0;
    flag_norm = 1;
    flat_waitbar = 1;
end

if nargin < 7
    flag_60HDMEA = 0;
    flag_norm = 1;
    flat_waitbar = 1;
end



% calculate number of windows and X Values:
k=fix(MERGED.PREF.rec_dur/time_win); % k: number of windows
MERGED.x=(0:time_win:time_win*k-time_win)./60; % save time in minutes


% Fill Timestamps and Amplitudes in new array of size "time_win":
win_beg=0;
win_end=time_win;
WIN(k)=struct(); % init
for i=1:k % loop through all loaded files
    disp(['Seperating spikes into windows: file #' num2str(i) ' of' num2str(k)])
    for n=1:size(MERGED.TS,2)
        mask=MERGED.TS(:,n)>win_beg & MERGED.TS(:,n)<=win_end; % find all TS inside current timewindow
        num_el = length(nonzeros(mask));
        if (num_el/time_win)*60 >= FR_min % clear electrodes which spike rate is smaller than FR_min
            WIN(i).SPIKEZ.TS(1:num_el,n)=MERGED.TS(mask,n)-((i-1)*time_win);
            WIN(i).SPIKEZ.AMP(1:num_el,n)=MERGED.AMP(mask,n);
        else
            WIN(i).SPIKEZ.TS(1:num_el,n)=0;
            WIN(i).SPIKEZ.AMP(1:num_el,n)=0;
        end
        WIN(i).SPIKEZ.PREF=MERGED.PREF;
        WIN(i).SPIKEZ.PREF.rec_dur=time_win; % rec_dur here is the choosen time_win
        WIN(i).SPIKEZ.neg.flag=0; % automated analysis only considers current spikes (by default the negative ones) and not the negative or positive ones separately
        WIN(i).SPIKEZ.pos.flag=0;
    end
    win_beg=time_win*i;
    win_end=time_win*(i+1);
end

% Calculate Parameter for each file
for i=1:size(WIN,2) % loop trough all windows (=files)
    %disp(['file #' num2str(i)])
    k=0;
    
    
    %% FEATURES: SPIKES/Amplitudes
    if any(strcmp('Spikerate',Selection))
        disp('Calculating: Spikerate')
        k=k+1;
        WIN(i).parameter(k).name='Spike rate /1/min';
        temp.SPIKEZ=SpikeFeaturesCalculation(WIN(i).SPIKEZ);
        WIN(i).parameter(k).mean=temp.SPIKEZ.aeFRmean;
        WIN(i).parameter(k).std=temp.SPIKEZ.aeFRstd;
        WIN(i).parameter(k).allEl=temp.SPIKEZ.FR;
        WIN(i).parameter(k).values=WIN(i).SPIKEZ.TS;
        WIN(i).parameter(k).aeN=temp.SPIKEZ.aeN; % sum of all spikes
        WIN(i).parameter(k).pref='';
    end
    if any(strcmp('Number of spikes',Selection))
        k=k+1;
        WIN(i).parameter(k).name='Number of spikes';
        if ~any(strcmp('Spikerate',Selection)); temp.SPIKEZ=SpikeFeaturesCalculation(WIN(i).SPIKEZ); end
        WIN(i).parameter(k).mean=temp.SPIKEZ.aeN; % sum of all spikes
        WIN(i).parameter(k).std=NaN;
        WIN(i).parameter(k).allEl=temp.SPIKEZ.N;
        WIN(i).parameter(k).values=NaN;
        WIN(i).parameter(k).aeN=temp.SPIKEZ.aeN; % sum of all spikes
        WIN(i).parameter(k).pref='';
    end
    if any(strcmp('Amplitude',Selection))
        disp('Calculating: Amplitude')
        k=k+1;
        WIN(i).parameter(k).name='Amplitude /uV';
        if ~any(strcmp('Spikerate',Selection)); temp.SPIKEZ=SpikeFeaturesCalculation(WIN(i).SPIKEZ); end
        WIN(i).parameter(k).mean=temp.SPIKEZ.aeAMPmean;
        WIN(i).parameter(k).std=temp.SPIKEZ.aeAMPstd;
        WIN(i).parameter(k).allEl=temp.SPIKEZ.AMPmean;
        WIN(i).parameter(k).values=temp.SPIKEZ.AMP;
        WIN(i).parameter(k).pref='';
    end
    if any(strcmp('ActiveElectrodes',Selection))
        k=k+1;
        WIN(i).parameter(k).name='Active electrodes';
        if ~any(strcmp('Spikerate',Selection)); temp.SPIKEZ=SpikeFeaturesCalculation(WIN(i).SPIKEZ); end
        WIN(i).parameter(k).mean=temp.SPIKEZ.aeFRn;
        WIN(i).parameter(k).std=NaN;
        WIN(i).parameter(k).allEl=temp.SPIKEZ.N>0; % electrode is one if more than 0 spikes on it
        WIN(i).parameter(k).values=temp.SPIKEZ.aeFRn;
        WIN(i).parameter(k).pref='';
    end
    
    %% FEATURES: BURSTS
    if any(strcmp('BR_baker100',Selection))
        disp('Calculating: Burstdetection (Baker)')
        k=k+1;
        WIN(i).parameter(k).name='Burst rate /1/min [baker100]';
        pref.SIB_min=3; pref.ISI_max=0.1; pref.IBI_min=0;
        temp=burstdetection('baker',WIN(i).SPIKEZ.TS,time_win,pref); % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeBRmean;
        WIN(i).parameter(k).std=temp.aeBRstd;
        WIN(i).parameter(k).allEl=temp.BR;
        WIN(i).parameter(k).values=temp.BEG;
        WIN(i).parameter(k).pref=pref;
    end
    if any(strcmp('BD_baker100',Selection))
        k=k+1;
        WIN(i).parameter(k).name='BD /s [baker100]';
        pref.SIB_min=3; pref.ISI_max=0.1; pref.IBI_min=0;
        if ~any(strcmp('BR_baker100',Selection)); temp=burstdetection('baker',WIN(i).SPIKEZ.TS,time_win,pref); end % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeBDmean;
        WIN(i).parameter(k).std=temp.aeBDstd;
        WIN(i).parameter(k).allEl=temp.BDmean;
        WIN(i).parameter(k).values=temp.BD;
        WIN(i).parameter(k).pref=pref;
    end
    if any(strcmp('SIB_baker100',Selection))
        k=k+1;
        WIN(i).parameter(k).name='SIB [baker100]';
        pref.SIB_min=3; pref.ISI_max=0.1; pref.IBI_min=0;
        if ~any(strcmp('BR_baker100',Selection)); temp=burstdetection('baker',WIN(i).SPIKEZ.TS,time_win,pref); end % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeSIBmean;
        WIN(i).parameter(k).std=temp.aeSIBstd;
        WIN(i).parameter(k).allEl=temp.SIBmean;
        WIN(i).parameter(k).values=temp.SIB;
        WIN(i).parameter(k).pref=pref;
    end
    if any(strcmp('IBI_baker100',Selection))
        k=k+1;
        WIN(i).parameter(k).name='IBI [baker100]';
        pref.SIB_min=3; pref.ISI_max=0.1; pref.IBI_min=0;
        if ~any(strcmp('BR_baker100',Selection)); temp=burstdetection('baker',WIN(i).SPIKEZ.TS,time_win,pref); end % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeIBImean;
        WIN(i).parameter(k).std=temp.aeIBIstd;
        WIN(i).parameter(k).allEl=temp.IBImean;
        WIN(i).parameter(k).values=temp.IBI;
        WIN(i).parameter(k).pref=pref;
    end
    
    if any(strcmp('BR_baker200',Selection))
        disp('Calculating: Burstdetection (Baker)')
        k=k+1;
        WIN(i).parameter(k).name='Burst rate /1/min [baker200]';
        pref.SIB_min=3; pref.ISI_max=0.2; pref.IBI_min=0;
        temp=burstdetection('baker',WIN(i).SPIKEZ.TS,time_win,pref); % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeBRmean;
        WIN(i).parameter(k).std=temp.aeBRstd;
        WIN(i).parameter(k).allEl=temp.BR;
        WIN(i).parameter(k).values=temp.BEG;
        WIN(i).parameter(k).pref=pref;
    end
    if any(strcmp('BD_baker200',Selection))
        k=k+1;
        WIN(i).parameter(k).name='BD /s [baker200]';
        pref.SIB_min=3; pref.ISI_max=0.5; pref.IBI_min=0;
        if ~any(strcmp('BR_baker200',Selection)); temp=burstdetection('baker',WIN(i).SPIKEZ.TS,time_win,pref); end % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeBDmean;
        WIN(i).parameter(k).std=temp.aeBDstd;
        WIN(i).parameter(k).allEl=temp.BDmean;
        WIN(i).parameter(k).values=temp.BD;
        WIN(i).parameter(k).pref=pref;
    end
    if any(strcmp('SIB_baker200',Selection))
        k=k+1;
        WIN(i).parameter(k).name='SIB [baker200]';
        pref.SIB_min=3; pref.ISI_max=0.2; pref.IBI_min=0;
        if ~any(strcmp('BR_baker200',Selection)); temp=burstdetection('baker',WIN(i).SPIKEZ.TS,time_win,pref); end % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeSIBmean;
        WIN(i).parameter(k).std=temp.aeSIBstd;
        WIN(i).parameter(k).allEl=temp.SIBmean;
        WIN(i).parameter(k).values=temp.SIB;
        WIN(i).parameter(k).pref=pref;
    end
    if any(strcmp('IBI_baker200',Selection))
        k=k+1;
        WIN(i).parameter(k).name='IBI [baker200]';
        pref.SIB_min=3; pref.ISI_max=0.2; pref.IBI_min=0;
        if ~any(strcmp('BR_baker200',Selection)); temp=burstdetection('baker',WIN(i).SPIKEZ.TS,time_win,pref); end % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeIBImean;
        WIN(i).parameter(k).std=temp.aeIBIstd;
        WIN(i).parameter(k).allEl=temp.IBImean;
        WIN(i).parameter(k).values=temp.IBI;
        WIN(i).parameter(k).pref=pref;
    end
    
    if any(strcmp('BR_selinger',Selection))
        disp('Calculating: Burstdetection (Selinger)')
        k=k+1;
        WIN(i).parameter(k).name='Burst rate /1/min [Selinger]';
        pref.SIB_min=3; pref.ISI_max=0.1; pref.IBI_min=0;
        temp=burstdetection('selinger',WIN(i).SPIKEZ.TS,time_win,pref); % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeBRmean;
        WIN(i).parameter(k).std=temp.aeBRstd;
        WIN(i).parameter(k).allEl=temp.BR;
        WIN(i).parameter(k).values=temp.BEG;
        WIN(i).parameter(k).pref=pref;
    end
    if any(strcmp('BD_selinger',Selection))
        k=k+1;
        WIN(i).parameter(k).name='BD /s [Selinger]';
        pref.SIB_min=3; pref.ISI_max=0.1; pref.IBI_min=0;
        if ~any(strcmp('BR_selinger',Selection)); temp=burstdetection('selinger',WIN(i).SPIKEZ.TS,time_win,pref); end % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeBDmean;
        WIN(i).parameter(k).std=temp.aeBDstd;
        WIN(i).parameter(k).allEl=temp.BDmean;
        WIN(i).parameter(k).values=temp.BD;
        WIN(i).parameter(k).pref=pref;
    end
    if any(strcmp('SIB_selinger',Selection))
        k=k+1;
        WIN(i).parameter(k).name='SIB [Selinger]';
        pref.SIB_min=3; pref.ISI_max=0.1; pref.IBI_min=0;
        if ~any(strcmp('BR_selinger',Selection)); temp=burstdetection('selinger',WIN(i).SPIKEZ.TS,time_win,pref); end % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeSIBmean;
        WIN(i).parameter(k).std=temp.aeSIBstd;
        WIN(i).parameter(k).allEl=temp.SIBmean;
        WIN(i).parameter(k).values=temp.SIB;
        WIN(i).parameter(k).pref=pref;
    end
    if any(strcmp('IBI_selinger',Selection))
        k=k+1;
        WIN(i).parameter(k).name='IBI [Selinger]';
        pref.SIB_min=3; pref.ISI_max=0.1; pref.IBI_min=0;
        if ~any(strcmp('BR_selinger',Selection)); temp=burstdetection('selinger',WIN(i).SPIKEZ.TS,time_win,pref); end % (Name,SPIKES,rec_dur, [SIB_min, ISI_max, IBI_min])
        WIN(i).parameter(k).mean=temp.aeIBImean;
        WIN(i).parameter(k).std=temp.aeIBIstd;
        WIN(i).parameter(k).allEl=temp.IBImean;
        WIN(i).parameter(k).values=temp.IBI;
        WIN(i).parameter(k).pref=pref;
    end
    
    %% FEATURES: Networkbursts
    if any(strcmp('NBR_chiappalone',Selection))
        disp('Calculating: Networkburstdetection (Chiappalone)')
        k=k+1;
        WIN(i).parameter(k).name='Networkburst rate /1/min [Chiappalone]';
        temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.025,0.5,0,0); % (SPIKES,rec_dur,bin,idleTime,ThMode,fig)
        WIN(i).parameter(k).mean=temp.aeBRn/MERGED.PREF.rec_dur;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=NaN;
        WIN(i).parameter(k).values=temp.BEG;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('NBD_chiappalone',Selection))
        k=k+1;
        WIN(i).parameter(k).name='NBD /s [Chiappalone]';
        if ~any(strcmp('NBR_chiappalone',Selection)); temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.025,0.5,0,0); end % (SPIKES,rec_dur,bin,idleTime,ThMode,fig)
        WIN(i).parameter(k).mean=temp.aeBDmean;
        WIN(i).parameter(k).std=temp.aeBDstd;
        WIN(i).parameter(k).allEl=temp.BDmean;
        WIN(i).parameter(k).values=temp.BD;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('SINB_chiappalone',Selection))
        k=k+1;
        WIN(i).parameter(k).name='SINB [Chiappalone]';
        if ~any(strcmp('NBR_chiappalone',Selection)); temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.025,0.5,0,0); end
        WIN(i).parameter(k).mean=temp.aeSIBmean;
        WIN(i).parameter(k).std=temp.aeSIBstd;
        WIN(i).parameter(k).allEl=temp.SIBmean;
        WIN(i).parameter(k).values=temp.SIB;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('INBI_chiappalone',Selection))
        k=k+1;
        WIN(i).parameter(k).name='INBI [Chiappalone]';
        if ~any(strcmp('NBR_chiappalone',Selection)); temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.025,0.5,0,0); end
        WIN(i).parameter(k).mean=temp.aeIBImean;
        WIN(i).parameter(k).std=temp.aeIBIstd;
        WIN(i).parameter(k).allEl=temp.IBImean;
        WIN(i).parameter(k).values=temp.IBI;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    
    % ----------- Jimbo's definition -------------
    if any(strcmp('NBR_jimbo',Selection))
        disp('Calculating: Networkburstdetection (Jimbo)')
        k=k+1;
        WIN(i).parameter(k).name='Networkburst rate /1/min [Jimbo]';
        temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.1,0.5,1,0); % (SPIKES,rec_dur,bin,idleTime,ThMode,fig)
        WIN(i).parameter(k).mean=temp.aeBRn/MERGED.PREF.rec_dur;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=NaN;
        WIN(i).parameter(k).values=temp.BEG;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('NBD_jimbo',Selection))
        k=k+1;
        WIN(i).parameter(k).name='NBD /s [Jimbo]';
        if ~any(strcmp('NBR_jimbo',Selection)); temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.1,0.5,1,0); end % (SPIKES,rec_dur,bin,idleTime,ThMode,fig)
        WIN(i).parameter(k).mean=temp.aeBDmean;
        WIN(i).parameter(k).std=temp.aeBDstd;
        WIN(i).parameter(k).allEl=temp.BDmean;
        WIN(i).parameter(k).values=temp.BD;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('SINB_jimbo',Selection))
        k=k+1;
        WIN(i).parameter(k).name='SINB [Jimbo]';
        if ~any(strcmp('NBR_jimbo',Selection)); temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.1,0.5,1,0); end
        WIN(i).parameter(k).mean=temp.aeSIBmean;
        WIN(i).parameter(k).std=temp.aeSIBstd;
        WIN(i).parameter(k).allEl=temp.SIBmean;
        WIN(i).parameter(k).values=temp.SIB;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('INBI_jimbo',Selection))
        k=k+1;
        WIN(i).parameter(k).name='INBI [Jimbo]';
        if ~any(strcmp('NBR_jimbo',Selection)); temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.1,0.5,1,0); end
        WIN(i).parameter(k).mean=temp.aeIBImean;
        WIN(i).parameter(k).std=temp.aeIBIstd;
        WIN(i).parameter(k).allEl=temp.IBImean;
        WIN(i).parameter(k).values=temp.IBI;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    
    % ----------- MC's definition (Jimbo's threshold, but bin size from Spike-contrast) -------------
    if any(strcmp('NBR_MC',Selection))
        disp('Calculating: Networkburstdetection (MC)')
        k=k+1;
        WIN(i).parameter(k).name='Networkburst rate /1/min [MC]';
        temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.1,0.5,3,0); % (SPIKES,rec_dur,bin,idleTime,ThMode,fig)
        WIN(i).parameter(k).mean=temp.aeBRn/MERGED.PREF.rec_dur;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=NaN;
        WIN(i).parameter(k).values=temp.BEG;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('NBD_MC',Selection))
        k=k+1;
        WIN(i).parameter(k).name='NBD /s [MC]';
        if ~any(strcmp('NBR_MC',Selection)); temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.1,0.5,3,0); end % (SPIKES,rec_dur,bin,idleTime,ThMode,fig)
        WIN(i).parameter(k).mean=temp.aeBDmean;
        WIN(i).parameter(k).std=temp.aeBDstd;
        WIN(i).parameter(k).allEl=temp.BDmean;
        WIN(i).parameter(k).values=temp.BD;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('SINB_MC',Selection))
        k=k+1;
        WIN(i).parameter(k).name='SINB [MC]';
        if ~any(strcmp('NBR_MC',Selection)); temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.1,0.5,3,0); end
        WIN(i).parameter(k).mean=temp.aeSIBmean;
        WIN(i).parameter(k).std=temp.aeSIBstd;
        WIN(i).parameter(k).allEl=temp.SIBmean;
        WIN(i).parameter(k).values=temp.SIB;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('INBI_MC',Selection))
        k=k+1;
        WIN(i).parameter(k).name='INBI [MC]';
        if ~any(strcmp('NBR_MC',Selection)); temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.1,0.5,3,0); end
        WIN(i).parameter(k).mean=temp.aeIBImean;
        WIN(i).parameter(k).std=temp.aeIBIstd;
        WIN(i).parameter(k).allEl=temp.IBImean;
        WIN(i).parameter(k).values=temp.IBI;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    
    %% FEATURES: Synchrony
    if any(strcmp('Sync_CC_selinger',Selection))
        disp('Calculating: Synchrony CC Selinger')
        k=k+1;
        WIN(i).parameter(k).name='Cross-correlation [Selinger]';
        if isempty(binSize)
            binSize = 0.5; % 500 ms default
        end
        temp=SyncMeasure_Crosscorrelation_Selinger(WIN(i).SPIKEZ.TS,time_win,binSize,binSize,1); % (TS,rec_dur,bin,step,binary)
        WIN(i).parameter(k).mean=temp.mean_M;
        WIN(i).parameter(k).std=temp.std_M;
        WIN(i).parameter(k).allEl=temp.M;
        WIN(i).parameter(k).values=temp.M;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_STTC',Selection))
        disp('Calculating: Synchrony STTC')
        k=k+1;
        WIN(i).parameter(k).name='STTC';
        if isempty(binSize)
            binSize = 0.1; % 100 ms default
        end
        temp=SyncMeasure_STTC(WIN(i).SPIKEZ.TS,time_win,binSize); % (TS1, TS2, recdur, dt)
        WIN(i).parameter(k).mean=temp.mean_M;
        WIN(i).parameter(k).std=temp.std_M;
        WIN(i).parameter(k).allEl=temp.M;
        WIN(i).parameter(k).values=temp.M;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_MI1',Selection))
        disp('Calculating: Synchrony MI1')
        k=k+1;
        WIN(i).parameter(k).name='Mutual Information (norm1)';
        if isempty(binSize)
            binSize = 0.5; % 500 ms default
        end
        temp=SyncMeasure_MutualInformation(WIN(i).SPIKEZ.TS,time_win,binSize,binSize,1,1); % (TS,rec_dur,bin,step,binary,norm)
        WIN(i).parameter(k).mean=temp.mean_M;
        WIN(i).parameter(k).std=temp.std_M;
        WIN(i).parameter(k).allEl=temp.M;
        WIN(i).parameter(k).values=temp.M;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_MI2',Selection))
        disp('Calculating: Synchrony MI2')
        k=k+1;
        WIN(i).parameter(k).name='Mutual Information (norm2)';
        if isempty(binSize)
            binSize = 0.5; % 500 ms default
        end
        temp=SyncMeasure_MutualInformation(WIN(i).SPIKEZ.TS,time_win,binSize,binSize,1,2); % (TS,rec_dur,bin,step,binary,norm)
        WIN(i).parameter(k).mean=temp.mean_M;
        WIN(i).parameter(k).std=temp.std_M;
        WIN(i).parameter(k).allEl=temp.M;
        WIN(i).parameter(k).values=temp.M;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_PS',Selection))
        disp('Calculating: Synchrony PS')
        k=k+1;
        WIN(i).parameter(k).name='Phase sync.';
        temp=SyncMeasure_Phasesynchronization(WIN(i).SPIKEZ.TS,time_win,WIN(i).SPIKEZ.PREF.SaRa); % (TS,rec_dur,SaRa)
        WIN(i).parameter(k).mean=temp.S; % temp.S: scalar value, temp.M: matrix, attention! mean(temp.M) is not equal to temp.S
        WIN(i).parameter(k).std=NaN;
        WIN(i).parameter(k).allEl=temp.M;
        WIN(i).parameter(k).values=temp.M;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_PS_M',Selection))
        disp('Calculating: Synchrony PS_M')
        k=k+1;
        WIN(i).parameter(k).name='Phase sync. (M)';
        temp=SyncMeasure_Phasesynchronization(WIN(i).SPIKEZ.TS,time_win,WIN(i).SPIKEZ.PREF.SaRa); % (TS,rec_dur,SaRa)
        WIN(i).parameter(k).mean=mean(nonzeros(temp.M),'omitnan'); % temp.S: scalar value, temp.M: matrix, attention! mean(temp.M) is not equal to temp.S
        WIN(i).parameter(k).std=NaN;
        WIN(i).parameter(k).allEl=temp.M;
        WIN(i).parameter(k).values=temp.M;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_Contrast',Selection))
        disp('Calculating: Synchrony Contrast')
        k=k+1;
        WIN(i).parameter(k).name='Synchrony (Spike-contrast)';
        %temp=SyncMeasure_Contrast(WIN(i).SPIKEZ.TS,time_win,2); % old (TS,rec_dur,binStepFactor)
        [temp.S,temp.PREF] = SpikeContrast(WIN(i).SPIKEZ.TS,time_win, 0.01); % 0.01 s is the size of minimum bin (if not given, it will be calculated by the function)
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
        k=k+1;
        WIN(i).parameter(k).name='Time-scale large (Spike-contrast)';
        WIN(i).parameter(k).mean=temp.PREF.S_largeBin;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.PREF.S_largeBin;
        WIN(i).parameter(k).values=temp.PREF.S_largeBin;
        WIN(i).parameter(k).pref=temp.PREF;
        k=k+1;
        WIN(i).parameter(k).name='Time-scale small (Spike-contrast)';
        WIN(i).parameter(k).mean=temp.PREF.S_smallBin;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.PREF.S_smallBin;
        WIN(i).parameter(k).values=temp.PREF.S_smallBin;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_Contrast_1ms',Selection))
        disp('Calculating: Synchrony Contrast')
        k=k+1;
        WIN(i).parameter(k).name='Synchrony (Spike-contrast)';
        %temp=SyncMeasure_Contrast(WIN(i).SPIKEZ.TS,time_win,2); % old (TS,rec_dur,binStepFactor)
        [temp.S,temp.PREF] = SpikeContrast(WIN(i).SPIKEZ.TS,time_win, 0.001); % 0.01 s is the size of minimum bin (if not given, it will be calculated by the function)
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
        k=k+1;
        WIN(i).parameter(k).name='Time-scale large (Spike-contrast)';
        WIN(i).parameter(k).mean=temp.PREF.S_largeBin;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.PREF.S_largeBin;
        WIN(i).parameter(k).values=temp.PREF.S_largeBin;
        WIN(i).parameter(k).pref=temp.PREF;
        k=k+1;
        WIN(i).parameter(k).name='Time-scale small (Spike-contrast)';
        WIN(i).parameter(k).mean=temp.PREF.S_smallBin;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.PREF.S_smallBin;
        WIN(i).parameter(k).values=temp.PREF.S_smallBin;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_Contrast_fixed',Selection)) % fixed bin borders and number of spike trains -> used for MEA-Meeting to generate synchrony curve
        disp('Calculating: Synchrony Contrast_fixed')
        k=k+1;
        WIN(i).parameter(k).name='Synchrony (Spike-contrast fixed)';
        [temp.S,temp.PREF] = SpikeContrast_fixed(WIN(i).SPIKEZ.TS,time_win, 0.01, N); % 0.01 s is the size of minimum bin (if not given, it will be calculated by the function)
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
        k=k+1;
        WIN(i).parameter(k).name='Time-scale large (Spike-contrast fixed)';
        WIN(i).parameter(k).mean=temp.PREF.S_largeBin;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.PREF.S_largeBin;
        WIN(i).parameter(k).values=temp.PREF.S_largeBin;
        WIN(i).parameter(k).pref=temp.PREF;
        k=k+1;
        WIN(i).parameter(k).name='Time-scale small (Spike-contrast fixed)';
        WIN(i).parameter(k).mean=temp.PREF.S_smallBin;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.PREF.S_smallBin;
        WIN(i).parameter(k).values=temp.PREF.S_smallBin;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_ISIDistance',Selection))
        disp('Calculating: Synchrony ISI-distance')
        k=k+1;
        WIN(i).parameter(k).name='ISIDistance';
        WIN(i).SPIKEZ.TS(WIN(i).SPIKEZ.TS==0) = NaN; % NaN-Patting needed
        [temp] = SyncMeasure_ISIDistance(WIN(i).SPIKEZ.TS,time_win,1);
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_SpikeDistance',Selection))
        disp('Calculating: Synchrony SPIKE-distance')
        k=k+1;
        WIN(i).parameter(k).name='SpikeDistance';
        WIN(i).SPIKEZ.TS(WIN(i).SPIKEZ.TS==0) = NaN; % NaN-Patting needed
        [temp] = SyncMeasure_SpikeDistance(WIN(i).SPIKEZ.TS,time_win,1);
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_SpikeSynchronization',Selection))
        disp('Calculating: Synchrony SPIKE-synchronization')
        k=k+1;
        WIN(i).parameter(k).name='SpikeSync.';
        WIN(i).SPIKEZ.TS(WIN(i).SPIKEZ.TS==0) = NaN; % NaN-Patting needed
        [temp] = SyncMeasure_SpikeSynchronization(WIN(i).SPIKEZ.TS,time_win,1);
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_ASpikeSynchronization',Selection))
        disp('Calculating: Synchrony A-SPIKE-synchronization')
        k=k+1;
        WIN(i).parameter(k).name='ASpikeSync.';
        WIN(i).SPIKEZ.TS(WIN(i).SPIKEZ.TS==0) = NaN; % NaN-Patting needed
        [temp] = SyncMeasure_ASpikeSynchronization(WIN(i).SPIKEZ.TS,time_win,1);
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_AISIDistance',Selection))
        disp('Calculating: Synchrony A-ISI-distance')
        k=k+1;
        WIN(i).parameter(k).name='AISIDistance';
        WIN(i).SPIKEZ.TS(WIN(i).SPIKEZ.TS==0) = NaN; % NaN-Patting needed
        [temp] = SyncMeasure_AISIDistance(WIN(i).SPIKEZ.TS,time_win,1);
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_ASpikeDistance',Selection))
        disp('Calculating: Synchrony A-SPIKE-distance')
        k=k+1;
        WIN(i).parameter(k).name='ASpikeDistance';
        WIN(i).SPIKEZ.TS(WIN(i).SPIKEZ.TS==0) = NaN; % NaN-Patting needed
        [temp] = SyncMeasure_ASpikeDistance(WIN(i).SPIKEZ.TS,time_win,1);
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_RISpikeDistance',Selection))
        disp('Calculating: Synchrony RI-SPIKE-distance')
        k=k+1;
        WIN(i).parameter(k).name='RISpikeDistance';
        WIN(i).SPIKEZ.TS(WIN(i).SPIKEZ.TS==0) = NaN; % NaN-Patting needed
        [temp] = SyncMeasure_RISpikeDistance(WIN(i).SPIKEZ.TS,time_win,1);
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_RIASpikeDistance',Selection))
        disp('Calculating: Synchrony RIA-SPIKE-distance')
        k=k+1;
        WIN(i).parameter(k).name='RIASpikeDistance';
        WIN(i).SPIKEZ.TS(WIN(i).SPIKEZ.TS==0) = NaN; % NaN-Patting needed
        [temp] = SyncMeasure_RIASpikeDistance(WIN(i).SPIKEZ.TS,time_win,1);
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Sync_EarthMoversDistance',Selection))
        disp('Calculating: Earth Movers Distance')
        k=k+1;
        WIN(i).parameter(k).name='EarthMoversDistance';
        WIN(i).SPIKEZ.TS(WIN(i).SPIKEZ.TS==0) = NaN; % NaN-Patting needed
        [temp] = SyncMeasure_EarthMoversDistance(WIN(i).SPIKEZ.TS);
        WIN(i).parameter(k).mean=temp.S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=temp.S;
        WIN(i).parameter(k).values=temp.S;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    
    
    %% Connectivity
    
    if any(strcmp('Connectivity_TSPE',Selection))
        disp('Calculating: Connectivity (TSPE)')
        [TS_reduced, activeElIdx] = reduceTSsize(WIN(i).SPIKEZ.TS);
        % flag_waitbar=1;
        [C_w_d_sign,C_exh,C_inh]=TSPE_call(TS_reduced, WIN(i).SPIKEZ.PREF.rec_dur,flag_waitbar, flag_norm);
        nr_channel = size(WIN(i).SPIKEZ.TS,2);
        [C_w_d_sign,C_exh,C_inh] = rearrangeElectrodePosition(C_w_d_sign,C_exh,C_inh,activeElIdx,nr_channel);
        
        flag_binary=0; % use weighted matrix (not binary)
        S=getAllGraphParameter(C_w_d_sign,flag_binary);
        
        k=k+1;
        WIN(i).parameter(k).name='Mean node degree (TSPE)';
        WIN(i).parameter(k).mean=S.D;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=C_w_d_sign;
        WIN(i).parameter(k).CM=C_w_d_sign;
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Characteristic Path Length (TSPE)';
        WIN(i).parameter(k).mean=S.CP;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Global Efficiency (TSPE)';
        WIN(i).parameter(k).mean=S.E;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity out/in (TSPE)';
        WIN(i).parameter(k).mean=S.r1;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity in/out (TSPE)';
        WIN(i).parameter(k).mean=S.r2;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity out/out (TSPE)';
        WIN(i).parameter(k).mean=S.r3;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity in/in (TSPE)';
        WIN(i).parameter(k).mean=S.r4;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Betweenness Centrality (TSPE)';
        WIN(i).parameter(k).mean=S.BC;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Clustering Coefficient (TSPE)';
        WIN(i).parameter(k).mean=S.CC;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Community Louvain (TSPE)';
        WIN(i).parameter(k).mean=S.CL;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Diffusion Efficiency (TSPE)';
        WIN(i).parameter(k).mean=S.DE;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Edge Betweenness Centrality (TSPE)';
        WIN(i).parameter(k).mean=S.EBC;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean First Passage Time (TSPE)';
        WIN(i).parameter(k).mean=S.FPT;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Modularity (TSPE)';
        WIN(i).parameter(k).mean=S.Mod;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Participation Coefficient Out-Degree (TSPE)';
        WIN(i).parameter(k).mean=S.PC1;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Participation Coefficient In-Degree (TSPE)';
        WIN(i).parameter(k).mean=S.PC2;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Transitivity (TSPE)';
        WIN(i).parameter(k).mean=S.T;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        
    end
    
    if any(strcmp('Connectivity_TSPE_mean_2std',Selection))
        disp('Calculating: Connectivity (TSPE) with threshold of mean+2*std')
        [TS_reduced, activeElIdx] = reduceTSsize(WIN(i).SPIKEZ.TS);
        flag_waitbar=1;
        [C_w_d_sign,C_exh,C_inh]=TSPE_call(TS_reduced, WIN(i).SPIKEZ.PREF.rec_dur,flag_waitbar);
        nr_channel = size(WIN(i).SPIKEZ.TS,2);
        [C_w_d_sign,C_exh,C_inh] = rearrangeElectrodePosition(C_w_d_sign,C_exh,C_inh,activeElIdx,nr_channel);
        
        factor = 2; % threshold = mean + factor * std
        [C_w_d_sign,CM_exh,CM_inh]=applyEasyThresholdToCM(C_w_d_sign,factor);
        
        flag_binary=0; % use weighted matrix (not binary)
        S=getAllGraphParameter(C_w_d_sign,flag_binary);
        
        k=k+1;
        WIN(i).parameter(k).name='Mean node degree (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.D;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=C_w_d_sign;
        WIN(i).parameter(k).CM=C_w_d_sign;
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Characteristic Path Length (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.CP;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Global Efficiency (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.E;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity out/in (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.r1;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity in/out (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.r2;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity out/out (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.r3;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity in/in (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.r4;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Betweenness Centrality (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.BC;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Clustering Coefficient (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.CC;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Community Louvain (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.CL;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Diffusion Efficiency (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.DE;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Edge Betweenness Centrality (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.EBC;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean First Passage Time (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.FPT;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Modularity (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.Mod;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Participation Coefficient Out-Degree (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.PC1;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Participation Coefficient In-Degree (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.PC2;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Transitivity (TSPE mean+2std)';
        WIN(i).parameter(k).mean=S.T;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        
    end
    
    
    if any(strcmp('Connectivity_TSPE_withSurrogateThreshold',Selection))
        disp('Calculating: Connectivity (TSPE with surrogate threshold)')
        [TS_reduced, activeElIdx] = reduceTSsize(WIN(i).SPIKEZ.TS);
        flag_waitbar=1;
        [C_w_d_sign,CM_exh,CM_inh]=TSPE_withSurrogateThreshold_call(TS_reduced, WIN(i).SPIKEZ.PREF.rec_dur,flag_waitbar);
        nr_channel = size(WIN(i).SPIKEZ.TS,2);
        [C_w_d_sign,CM_exh,CM_inh] = rearrangeElectrodePosition(C_w_d_sign,CM_exh,CM_inh,activeElIdx,nr_channel);
        
        flag_binary=0; % use weighted matrix (not binary)
        S=getAllGraphParameter(C_w_d_sign,flag_binary);
        
        k=k+1;
        WIN(i).parameter(k).name='Mean node degree (TSPE surr)';
        WIN(i).parameter(k).mean=S.D;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=C_w_d_sign;
        WIN(i).parameter(k).CM=C_w_d_sign;
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Characteristic Path Length (TSPE surr)';
        WIN(i).parameter(k).mean=S.CP;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Global Efficiency (TSPE surr)';
        WIN(i).parameter(k).mean=S.E;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity out/in (TSPE surr)';
        WIN(i).parameter(k).mean=S.r1;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity in/out (TSPE surr)';
        WIN(i).parameter(k).mean=S.r2;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity out/out (TSPE surr)';
        WIN(i).parameter(k).mean=S.r3;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Assortativity in/in (TSPE surr)';
        WIN(i).parameter(k).mean=S.r4;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Betweenness Centrality (TSPE surr)';
        WIN(i).parameter(k).mean=S.BC;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Clustering Coefficient (TSPE surr)';
        WIN(i).parameter(k).mean=S.CC;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Community Louvain (TSPE surr)';
        WIN(i).parameter(k).mean=S.CL;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Diffusion Efficiency (TSPE surr)';
        WIN(i).parameter(k).mean=S.DE;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Edge Betweenness Centrality (TSPE surr)';
        WIN(i).parameter(k).mean=S.EBC;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean First Passage Time (TSPE surr)';
        WIN(i).parameter(k).mean=S.FPT;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Modularity (TSPE surr)';
        WIN(i).parameter(k).mean=S.Mod;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Participation Coefficient Out-Degree (TSPE surr)';
        WIN(i).parameter(k).mean=S.PC1;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Mean Participation Coefficient In-Degree (TSPE surr)';
        WIN(i).parameter(k).mean=S.PC2;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
        k=k+1;
        WIN(i).parameter(k).name='Transitivity (TSPE surr)';
        WIN(i).parameter(k).mean=S.T;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=[];
        WIN(i).parameter(k).values=[];
        WIN(i).parameter(k).pref=[];
    end
    
    %% FEATURES: Entropy
    if any(strcmp('Entropy_bin100',Selection))
        disp('Calculating: Entropy')
        k=k+1;
        WIN(i).parameter(k).name='Entropy (bin100ms)';
        temp=Entropy_call(WIN(i).SPIKEZ.TS,time_win,time_win,0.1,0.1,false); % (TS,rec_dur,win,bin,step,binary)
        WIN(i).parameter(k).mean=temp.mean;
        WIN(i).parameter(k).std=temp.std;
        WIN(i).parameter(k).allEl=temp.mean;
        WIN(i).parameter(k).values=temp.mean;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    if any(strcmp('Entropy_capurro',Selection))
        disp('Calculating: Entropy (Capurro)')
        k=k+1;
        WIN(i).parameter(k).name='Entropy [Capurro]';
        temp=Entropy_call(WIN(i).SPIKEZ.TS,time_win,time_win,0.05,0.001,false); % (TS,rec_dur,win,bin,step,binary) % Capurro et al. bin=0.05 step=0.001
        WIN(i).parameter(k).mean=temp.mean;
        WIN(i).parameter(k).std=temp.std;
        WIN(i).parameter(k).allEl=temp.mean;
        WIN(i).parameter(k).values=temp.mean;
        WIN(i).parameter(k).pref=temp.PREF;
    end
    
    %% FEATURES: Cardio
    if any(strcmp('Cardio - Propagation Velocity',Selection))
        disp('Calculating: Propagation Velocity')
        
        numSpikeColumns = size(WIN(i).SPIKEZ.TS,1);
        [velocity_airline,velocity_min_mean,velocity_max_mean,velocity_mean_mean] = cardioCalculateSpeed(WIN(i).SPIKEZ, numSpikeColumns, flag_60HDMEA);
        
        k=k+1;
        WIN(i).parameter(k).name='Velocity (airline) in m/s'; 
        WIN(i).parameter(k).mean=mean(velocity_airline,'omitnan');
        WIN(i).parameter(k).std=std(velocity_airline,'omitnan');
        WIN(i).parameter(k).allEl=velocity_airline;
        WIN(i).parameter(k).values=velocity_airline;
        WIN(i).parameter(k).pref=NaN;
        
        k=k+1;
        WIN(i).parameter(k).name='Velocity min (neighbor) in m/s'; 
        WIN(i).parameter(k).mean=mean(velocity_min_mean,'omitnan');
        WIN(i).parameter(k).std=std(velocity_min_mean,'omitnan');
        WIN(i).parameter(k).allEl=velocity_min_mean;
        WIN(i).parameter(k).values=velocity_min_mean;
        WIN(i).parameter(k).pref=NaN;
        
        k=k+1;
        WIN(i).parameter(k).name='Velocity max (neighbor) in m/s'; 
        WIN(i).parameter(k).mean=mean(velocity_max_mean,'omitnan');
        WIN(i).parameter(k).std=std(velocity_max_mean,'omitnan');
        WIN(i).parameter(k).allEl=velocity_max_mean;
        WIN(i).parameter(k).values=velocity_max_mean;
        WIN(i).parameter(k).pref=NaN;
        
        k=k+1;
        WIN(i).parameter(k).name='Velocity mean (neighbor) in m/s'; 
        WIN(i).parameter(k).mean=mean(velocity_mean_mean,'omitnan');
        WIN(i).parameter(k).std=std(velocity_mean_mean,'omitnan');
        WIN(i).parameter(k).allEl=velocity_mean_mean;
        WIN(i).parameter(k).values=velocity_mean_mean;
        WIN(i).parameter(k).pref=NaN;
    end
    
    if any(strcmp('Cardio - Beat Rate',Selection))
        disp('Calculating: Beat Rate')
        
        
        [BR,meanBR,stdBR,meanBR_ISI,stdBR_ISI,meanISI,stdISI,AMPmin,AMPmax] =calcBeatrate(WIN(i).SPIKEZ);
        
        k=k+1;
        WIN(i).parameter(k).name='Mean Beat Rate in Hz (#Spikes/T)'; 
        WIN(i).parameter(k).mean=meanBR;
        WIN(i).parameter(k).std=stdBR;
        WIN(i).parameter(k).allEl=BR;
        WIN(i).parameter(k).values=BR;
        WIN(i).parameter(k).pref=NaN;     
        
        k=k+1;
        WIN(i).parameter(k).name='Mean Beat Rate in Hz (1/ISI)'; 
        WIN(i).parameter(k).mean=meanBR_ISI;
        WIN(i).parameter(k).std=stdBR_ISI;
        WIN(i).parameter(k).allEl=1./meanISI;
        WIN(i).parameter(k).values=1./meanISI;
        WIN(i).parameter(k).pref=NaN; 
        
        k=k+1;
        WIN(i).parameter(k).name='Mean ISI in s'; 
        WIN(i).parameter(k).mean=mean(meanISI,'omitnan');
        WIN(i).parameter(k).std=std(meanISI,'omitnan');
        WIN(i).parameter(k).allEl=meanISI;
        WIN(i).parameter(k).values=meanISI;
        WIN(i).parameter(k).pref=NaN;
        
        k=k+1;
        WIN(i).parameter(k).name='Std ISI in s'; 
        WIN(i).parameter(k).mean=mean(stdISI,'omitnan');
        WIN(i).parameter(k).std=std(stdISI,'omitnan');
        WIN(i).parameter(k).allEl=stdISI;
        WIN(i).parameter(k).values=stdISI;
        WIN(i).parameter(k).pref=NaN;
        
%         k=k+1;
%         WIN(i).parameter(k).name='Mean Amp min in uV'; 
%         WIN(i).parameter(k).mean=mean(AMPmin,'omitnan');
%         WIN(i).parameter(k).std=std(AMPmin,'omitnan');
%         WIN(i).parameter(k).allEl=AMPmin;
%         WIN(i).parameter(k).values=AMPmin;
%         WIN(i).parameter(k).pref=NaN;
%         
%         k=k+1;
%         WIN(i).parameter(k).name='Std Amp min in uV'; 
%         WIN(i).parameter(k).mean=std(AMPmin,'omitnan');
%         WIN(i).parameter(k).std=0;
%         WIN(i).parameter(k).allEl=AMPmin;
%         WIN(i).parameter(k).values=AMPmin;
%         WIN(i).parameter(k).pref=NaN;
%         
%         k=k+1;
%         WIN(i).parameter(k).name='Mean Amp max in uV'; 
%         WIN(i).parameter(k).mean=mean(AMPmax,'omitnan');
%         WIN(i).parameter(k).std=std(AMPmax,'omitnan');
%         WIN(i).parameter(k).allEl=AMPmax;
%         WIN(i).parameter(k).values=AMPmax;
%         WIN(i).parameter(k).pref=NaN;
%         
%         k=k+1;
%         WIN(i).parameter(k).name='Std Amp max in uV'; 
%         WIN(i).parameter(k).mean=std(AMPmax,'omitnan');
%         WIN(i).parameter(k).std=0;
%         WIN(i).parameter(k).allEl=AMPmax;
%         WIN(i).parameter(k).values=AMPmax;
%         WIN(i).parameter(k).pref=NaN;
    end
    
    if any(strcmp('Cardio - Spike-contrast',Selection))
        disp('Calculating: Cardio Spike-contrast')
        
        TS = WIN(i).SPIKEZ.TS;
        T = WIN(i).SPIKEZ.PREF.rec_dur;
        minBin = 0.001;
        [S,PREF]=SpikeContrast(TS,T,minBin);
        maxBin_S1 = PREF.S_largeBin; % maximal bin size at synchrony level  of 1
        minBin_S1 = PREF.S_smallBin; % minimal bin size at synchrony level of 1
        minBin_S05 = NaN; % minimal bin size at synchrony level of 0.5
        
        binsFlipped = flip(PREF.bins); % bins from large to small, flip to inverse to small to large bin sizes 
        sFlipped = flip(PREF.s); % also flip synchrony curve
        idx=find(sFlipped>0.4 & sFlipped<0.6); % get all indices where synchrony is between 0.4 and 0.6 (ideally here we want 0.5)
        
        if ~isempty(idx)
            minBin_S05 = binsFlipped(idx(1)); % use the first bin
        end
        
        
        % calc arrhytmia index
        TS(TS==0)=NaN; % force NaN patting (Note: not correct if spike time stamp is exactly zero seconds)
        TS=sort(TS);  
        bin = PREF.S_largeBin;
        ISI=diff(TS);
        ISImin= min(min(ISI));
        time_start = -ISImin;
        time_end = T+ISImin;
        [Theta_k,n_k]=f_SC_get_Theta_and_n_perBin(TS,time_start,time_end,bin);
        tmp = xcorr(Theta_k,'coeff'); % autocorrelation -> how periodic is the histogram?
        tmp(tmp==1)=0; % delete first maximum, so we only consider correlations of shifted versions
        rhythmia_idx = max(tmp); % use second maximum as index
        arrhythmia_idx = 1 - rhythmia_idx;
        %rhythmia_idx = sum(abs(diff(Theta_k))/max(abs(Theta_k)))/(length(Theta_k));
        %arrhytmia_idx = 1 - rhythmia_idx;
        
        % use "stationarity idx" to quantify periodicity
        if 0
        force = 2; % minimum spikes per spike train
        plot_bool = true;
        RES=test_nonstationarity(sort(nonzeros(TS(:))),force,T,plot_bool);
        rhythmia_idx = RES.SP_val;
        end
        
        k=k+1;
        WIN(i).parameter(k).name='Synchrony (Spike-contrast)'; 
        WIN(i).parameter(k).mean=S;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=NaN;
        WIN(i).parameter(k).values=NaN;
        WIN(i).parameter(k).pref=NaN;
        
        k=k+1;
        WIN(i).parameter(k).name='max bin size @ S=1'; 
        WIN(i).parameter(k).mean=maxBin_S1;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=NaN;
        WIN(i).parameter(k).values=NaN;
        WIN(i).parameter(k).pref=NaN;
        
        k=k+1;
        WIN(i).parameter(k).name='min bin size @ S=1'; 
        WIN(i).parameter(k).mean=minBin_S1;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=NaN;
        WIN(i).parameter(k).values=NaN;
        WIN(i).parameter(k).pref=NaN;
        
        k=k+1;
        WIN(i).parameter(k).name='min bin size @ S=0.5'; 
        WIN(i).parameter(k).mean=minBin_S05;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=NaN;
        WIN(i).parameter(k).values=NaN;
        WIN(i).parameter(k).pref=NaN;
        
        k=k+1;
        WIN(i).parameter(k).name='Arrhythmia index (beta)'; 
        WIN(i).parameter(k).mean=arrhythmia_idx;
        WIN(i).parameter(k).std=0;
        WIN(i).parameter(k).allEl=NaN;
        WIN(i).parameter(k).values=Theta_k;
        WIN(i).parameter(k).pref=NaN;
        
    end

end
end
