%% in this function all parameter like Spikerate, Burstrate, Networkbursts, Crosscorrelation ect. are calculated
% input:    MERGED:                 structure conainting all TS files merged together
%           MERGED.PREF.rec_dur:    duration of merged TS file in seconds
%           MERGED.PREF.SaRa:       sample rate used to record raw signals in Hz
%           MERGED.TS:              time stamps of all TS files in seconds
%           MERGED.AMP:             amplitudes of all TS files in uV
%
%           Selection:              cell array conainting names of parameters that has to be calculated              
%           time_win:               window length in seconds (if duration of all TS files is 300 s and parameter shall be calculated for every 60 s, set time_win=60)  
%           FR_min:                 minimum firing rate (aka spike rate) in spikes/minute to be active (e.g. FR_min=6, all electrodes are cleared that contains less than 6 spikes per minute)
%           N:                      number of active electrodes (only needed for function "Sync_Contrast_fixed")
%           binSize:                specify binSize (default = 500 ms)
%
%
% output:   WIN:                    structure containing all parameter for each time_win
%           MERGED:                 same as input but with x values
%
% NOTE: use function PARAMETER=unpackWIN2PARAMETER(WIN) to calculate electrdoe wise parameter and unpack WIN into a more handy structure

function [WIN,MERGED]=CalcParameter_function(MERGED,Selection,time_win,FR_min,N,binSize)
    
    if nargin == 4
       N = 60; % set number of electrodes to a fixed value (only needed for 'Sync_Contrast_fixed')
       binSize = [];
    end

    % calculate number of windows and X Values:
    k=fix(MERGED.PREF.rec_dur/time_win); % k: number of windows
    MERGED.x=(0:time_win:time_win*k-time_win)./60; % save time in minutes 


    % Fill Timestamps and Amplitudes in new array of size "time_win": 
    win_beg=0;
    win_end=time_win;
    WIN(k)=struct(); % init
    for i=1:k % loop through all loaded files
        %disp(['Seperating spikes into windows: file #' num2str(i)])
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

        
        %% PARAMETER: SPIKES/Amplitudes
        if any(strcmp('Spikerate',Selection))
            k=k+1;
            WIN(i).parameter(k).name='Spike rate /1/min';  
            temp.SPIKEZ=SpikeParameterCalculation(WIN(i).SPIKEZ); 
            WIN(i).parameter(k).mean=temp.SPIKEZ.aeFRmean;
            WIN(i).parameter(k).std=temp.SPIKEZ.aeFRstd;
            WIN(i).parameter(k).allEl=temp.SPIKEZ.FR;
            WIN(i).parameter(k).values=WIN(i).SPIKEZ.TS;
            WIN(i).parameter(k).aeN=temp.SPIKEZ.aeN; % sum of all spikes
            WIN(i).parameter(k).pref='';   
        end
         if any(strcmp('Amplitude',Selection))   
            k=k+1;
            WIN(i).parameter(k).name='Amplitude /uV';   
            if ~any(strcmp('Spikerate',Selection)); temp.SPIKEZ=SpikeParameterCalculation(WIN(i).SPIKEZ); end 
            WIN(i).parameter(k).mean=temp.SPIKEZ.aeAMPmean;
            WIN(i).parameter(k).std=temp.SPIKEZ.aeAMPstd;
            WIN(i).parameter(k).allEl=temp.SPIKEZ.AMP;
            WIN(i).parameter(k).values=WIN(i).SPIKEZ.AMP;
            WIN(i).parameter(k).pref='';  
         end
         if any(strcmp('ActiveElectrodes',Selection))
            k=k+1;
            WIN(i).parameter(k).name='Active electrodes';  
            if ~any(strcmp('Spikerate',Selection)); temp.SPIKEZ=SpikeParameterCalculation(WIN(i).SPIKEZ); end
            WIN(i).parameter(k).mean=temp.SPIKEZ.aeFRn;
            WIN(i).parameter(k).std=0;
            WIN(i).parameter(k).allEl=temp.SPIKEZ.N>0; % electrode is one if more than 0 spikes on it
            WIN(i).parameter(k).values=temp.SPIKEZ.N>0;
            WIN(i).parameter(k).pref='';
        end

        %% PARAMETER: BURSTS
        if any(strcmp('BR_baker100',Selection))
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

        if any(strcmp('BR_selinger',Selection))
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

        %% PARAMETER: Networkbursts
        if any(strcmp('NBR_chiappalone',Selection))
            k=k+1;
            WIN(i).parameter(k).name='Networkburst rate /1/min [Chiappalone]'; 
            temp=networkburstdetection_chiappalone(WIN(i).SPIKEZ.TS,time_win,0.025,0.5,0,0); % (SPIKES,rec_dur,bin,idleTime,ThMode,fig)
            WIN(i).parameter(k).mean=temp.aeBRmean;
            WIN(i).parameter(k).std=temp.aeBRstd;
            WIN(i).parameter(k).allEl=temp.BR; 
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

        %% PARAMETER: Synchrony
        if any(strcmp('Sync_CC_selinger',Selection))
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
            k=k+1;
            WIN(i).parameter(k).name='Contrast'; 
            %temp=SyncMeasure_Contrast(WIN(i).SPIKEZ.TS,time_win,2); % old (TS,rec_dur,binStepFactor)
            [temp.S,temp.PREF] = SpikeContrast(WIN(i).SPIKEZ.TS,time_win, 0.01); % 0.01 s is the size of minimum bin (if not given, it will be calculated by the function)
            WIN(i).parameter(k).mean=temp.S;
            WIN(i).parameter(k).std=0;
            WIN(i).parameter(k).allEl=temp.S;
            WIN(i).parameter(k).values=temp.S;
            WIN(i).parameter(k).pref=temp.PREF;
        end
        if any(strcmp('Sync_Contrast_fixed',Selection)) % fixed bin borders and number of spike trains -> used for MEA-Meeting to generate synchrony curve
            k=k+1;
            WIN(i).parameter(k).name='Contrast_fixed'; 
            [temp.S,temp.PREF] = SpikeContrast_fixed(WIN(i).SPIKEZ.TS,time_win, 0.01, N); % 0.01 s is the size of minimum bin (if not given, it will be calculated by the function)
            WIN(i).parameter(k).mean=temp.S;
            WIN(i).parameter(k).std=0;
            WIN(i).parameter(k).allEl=temp.S;
            WIN(i).parameter(k).values=temp.S;
            WIN(i).parameter(k).pref=temp.PREF;
        end
        if any(strcmp('Sync_ISIDistance',Selection))
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
        

        %% PARAMETER: Entropy
        if any(strcmp('Entropy_bin100',Selection))
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
            k=k+1;
            WIN(i).parameter(k).name='Entropy [Capurro]'; 
            temp=Entropy_call(WIN(i).SPIKEZ.TS,time_win,time_win,0.05,0.001,false); % (TS,rec_dur,win,bin,step,binary) % Capurro et al. bin=0.05 step=0.001
            WIN(i).parameter(k).mean=temp.mean;
            WIN(i).parameter(k).std=temp.std;
            WIN(i).parameter(k).allEl=temp.mean;
            WIN(i).parameter(k).values=temp.mean;
            WIN(i).parameter(k).pref=temp.PREF;
        end

    end
end