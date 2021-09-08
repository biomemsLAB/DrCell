% SPIKEZ (structure)
% SPIKEZ.TS:                            Timestamps of spikes
% SPIKEZ.AMP:                           Amplitude of each spike
% SPIKEZ.N:                             number of spikes per el.
% SPIKEZ.FR:                            firing rate per el.
% SPIKEZ.aeFRmean:                      mean firing rate
% SPIKEZ.aeFRstd:                       st. deviation of firing rate
% SPIKEZ.aeN_FR:                        number of firing rates =
% number of active electrodes
%
% SPIKEZ.FILTER.Name:                   band-low-highpass/stop
% SPIKEZ.FILTER.f_edge:                 edge frequency/ies
%
% SPIKEZ.PREF.fileinfo:                 manually written comment
% SPIKEZ.PREF.Time:                     Time of recording
% SPIKEZ.PREF.Date:                     Date of recording
% SPIKEZ.PREF.SaRa:                     Sample rate 
% SPIKEZ.PREF.rec_dur:                  recording duration in seconds
% SPIKEZ.PREF.EL_NUMS:                  Electrode numbers
% SPIKEZ.PREF.EL_NAMES:                 Electrode names
% SPIKEZ.PREF.idleTime:                 apllied idle time
% SPIKEZ.PREF.minFR:                    minimum FR to be active el.
% SPIKEZ.PREF.CLEL:                     cleared electrodes
% SPIKEZ.PREF.Invert_M:                 inverted electrodes
% SPIKEZ.PREF.dyn_TH:                   1: threshold is dynamic, 0 or not
% existing: threshold is constant
%         
% SPIKEZ.SNR.SNR:                       signal to noise ratio /el
% SPIKEZ.SNR.SNR_dB:                    signal to noise in dB /el
% SPIKEZ.SNR.Mean_SNR_dB:               mean snr value over all el
%
% SPIKEZ.pos.flag:                      0/1: de/activate pos spike detection
% SPIKEZ.pos.TS:                        positive spikes
% SPIKEZ.pos.AMP:                       positive amplitudes
% SPIKEZ.pos.N:                         number of pos. spikes
% SPIKEZ.pos.THRESHOLDS.Th:             positive thresholds
% SPIKEZ.pos.THRESHOLDS.Multiplier:     positive th.calc. parameter1
% SPIKEZ.pos.THRESHOLDS.Std_noizewindow: positive th.calc. parameter2
% SPIKEZ.pos.THRESHOLDS.Size_noizewindow: positive th.calc. parameter3
% SPIKEZ.pos.SNR.SNR:                   signal to noise ratio /el
% SPIKEZ.pos.SNR.SNR_dB:                signal to noise in dB /el
% SPIKEZ.pos.SNR.Mean_SNR_dB:           mean snr value over all el
%
% SPIKEZ.neg.flag:                      0/1: de/activate neg spike detection
% SPIKEZ.neg.TS:                        negative spikes
% SPIKEZ.neg.AMP:                       negative amplitudes
% SPIKEZ.neg.N:                         number of neg. spikes
% SPIKEZ.neg.THRESHOLDS.Th:             negative thresholds
% SPIKEZ.neg.THRESHOLDS.Multiplier:     negative th.calc. parameter1
% SPIKEZ.neg.THRESHOLDS.Std_noizewindow: neg. th.calc. parameter2
% SPIKEZ.neg.THRESHOLDS.Size_noizewindow: neg. th.calc. parameter3
% SPIKEZ.neg.SNR.SNR:                   signal to noise ratio /el
% SPIKEZ.neg.SNR.SNR_dB:                signal to noise in dB /el
% SPIKEZ.neg.SNR.Mean_SNR_dB:           mean snr value over all el

function [SPIKEZ]=spikedetection(raw,SPIKEZ)
 

    M=raw.M;
    T=raw.T;
    SaRa=raw.SaRa;
    clear raw
    
    
    
    % init 
    SPIKES = zeros(1,size(M,2)); 
    
    SPIKES_pos = [];
    SPIKES_neg = [];


    negSpike_Box=SPIKEZ.neg.flag;
    posSpike_Box=SPIKEZ.pos.flag;    
    idleTime=SPIKEZ.PREF.idleTime;
    
    % load negative thresholds
    if negSpike_Box==1
        if size(SPIKEZ.neg.THRESHOLDS.Th,1)==1 % if threshold consists only of one value
            SPIKEZ.PREF.dyn_TH=0;
            THRESHOLDS=SPIKEZ.neg.THRESHOLDS.Th;
        else % interpolate dynamic threshold
            SPIKEZ.PREF.dyn_TH=1;
            THRESHOLDS=zeros(size(M));
            for n=1:size(SPIKEZ.neg.THRESHOLDS.Th,2)
                x=[T(1,1):size(T,2)/size(SPIKEZ.neg.THRESHOLDS.Th,1):size(T,2)-1]; % 0 : 1000 : 599000
                y=SPIKEZ.neg.THRESHOLDS.Th(:,n); % -7.12 -9.22 ..... size=600x60
                xq=[0:1:size(T,2)-1]; % 0 : 1 : 599999
               THRESHOLDS(:,n)=interp1(x,y,xq); 
            end
        end
    end
    % load positive thresholds
    if posSpike_Box==1
        if size(SPIKEZ.pos.THRESHOLDS.Th,1)==1 % if threshold consists only of one value
            SPIKEZ.PREF.dyn_TH=0;
            THRESHOLDS_pos=SPIKEZ.pos.THRESHOLDS.Th;
        else % interpolate dynamic threshold
            SPIKEZ.PREF.dyn_TH=1;
            THRESHOLDS_pos=zeros(size(M));
            for n=1:size(SPIKEZ.pos.THRESHOLDS.Th,2)
                x=[T(1,1):size(T,2)/size(SPIKEZ.pos.THRESHOLDS.Th,1):size(T,2)-1];
                y=SPIKEZ.pos.THRESHOLDS.Th(:,n);
                xq=[0:1:size(T,2)-1];
               THRESHOLDS_pos(:,n)=interp1(x,y,xq); 
            end
        end
    end
    
    
            
   % detect negative spikes
   if negSpike_Box==1
        SPIKES_neg=zeros(1,size(M,2));
        SPIKEZ.neg.AMP=zeros(1,size(M,2));
        M2 = zeros(size(M,1),size(M,2));
        
        if SPIKEZ.PREF.dyn_TH==0
            for n = 1:size(M2,2)
                M2(:,n) = M(:,n)-THRESHOLDS(1,n);
            end
        end
        
        if SPIKEZ.PREF.dyn_TH==1
            for n = 1:size(M2,2)
                M2(:,n) = M(:,n)-THRESHOLDS(:,n);
            end
        end
        
        M2 = (M2<0);
        for n = 1:size(M2,2)                        % n: current collum in M2 and SPIKES
            k = 0;                                  % k: current row in SPIKES
            m = 2;                                  % m: current row in M2
            potspikebeg = 0;
            potspikeend = 0;            
            while m <= size(M2,1)
                %beginning of spikes
                if M2(m,n)>M2(m-1,n)
                    potspikebeg = m;
                end
                %End of Spikes
                if (M2(m,n)<M2(m-1,n) && (potspikebeg ~= 0))
                    potspikeend = m;
                end
                % = Peak
                if potspikeend ~= 0
                    SEARCH = M(potspikebeg:potspikeend,n);
                    k=k+1;
                    [Amp,I]= min(SEARCH); % search for negative peak (-> min)
                    SPIKES_neg(k,n) = T((m-size(SEARCH,1)+I));
                    SPIKEZ.neg.AMP(k,n)=Amp;
                    potspikebeg = 0;
                    potspikeend = 0;
                end
                m = m + 1;
            end  
        end
   end

    % detect positive spikes
    if posSpike_Box==1
        SPIKES_pos=zeros(1,size(M,2));
        SPIKEZ.pos.AMP=zeros(1,size(M,2));
        if size(THRESHOLDS_pos,2)==size(M,2)
            M2 = zeros(size(M,1),size(M,2));
            
            if SPIKEZ.PREF.dyn_TH==0
                for n = 1:size(M2,2)
                    M2(:,n) = M(:,n)-THRESHOLDS_pos(1,n);
                end
            end

            if SPIKEZ.PREF.dyn_TH==1
                for n = 1:size(M2,2)
                    M2(:,n) = M(:,n)-THRESHOLDS_pos(:,n);
                end
            end
            
            M2 = (M2>0);
            for n = 1:size(M2,2)                        % n: current collum in M2 and SPIKES
                k = 0;                                  % k: current row in SPIKES
                m = 2;                                  % m: current row in M2
                potspikebeg = 0;
                potspikeend = 0;            
                while m <= size(M2,1)
                    %beginning of spikes
                    if M2(m,n)>M2(m-1,n)
                        potspikebeg = m;
                    end
                    %End of Spikes
                    if (M2(m,n)<M2(m-1,n) && (potspikebeg ~= 0))
                        potspikeend = m;
                    end
                    % = Peak
                    if potspikeend ~= 0
                        SEARCH = M(potspikebeg:potspikeend,n);
                        k=k+1;
                        [Amp,I]= max(SEARCH); % search for positive peak (->max)
                        SPIKES_pos(k,n) = T((m-size(SEARCH,1)+I));
                        SPIKEZ.pos.AMP(k,n)=Amp;
                        potspikebeg = 0;
                        potspikeend = 0;
                    end
                    m = m + 1;
                end  
            end
        end
    end


   % use only negative or positive or negative+positive spikes for
   % further analysis (main-array: SPIKES)

    if negSpike_Box==1 
        SPIKES=SPIKES_neg;
    end

    if posSpike_Box==1
        SPIKES=SPIKES_pos;
    end

    if negSpike_Box==1 && posSpike_Box==1
        SPIKES=[SPIKES_neg;SPIKES_pos];
        for n=1:size(SPIKES,2)  % SPIKES=nonzeros(SPIKES) would delete columns with only zero-values
            if max(SPIKES(:,n))~=0 % if electrode has spikes, then copy and sort, else fill with zero to sustain number of electrodes
               SPIKES_temp=nonzeros(SPIKES(:,n));
               SPIKES_temp=sort(SPIKES_temp); % sort array ...
               SPIKES(:,n)=0;
               SPIKES(1:size(SPIKES_temp),n)=SPIKES_temp; % ...but leave zeros at the end 
            else
                SPIKES(:,n)=0;
            end
        end
    end

    % Refractory time 
    SPIKES=idle_time(SPIKES,idleTime);
    SPIKES_neg=idle_time(SPIKES_neg,idleTime);
    SPIKES_pos=idle_time(SPIKES_pos,idleTime);
    
    % delete all rows that only contain zeros:
    SPIKES=SPIKES(any(SPIKES,2),:);
    SPIKES_neg=SPIKES_neg(any(SPIKES_neg,2),:);
    SPIKES_pos=SPIKES_pos(any(SPIKES_pos,2),:);
    
    % get amplitude for each spike (Note: amplitudes for negative and
    % positve spikes have been already calculated above, here the
    % amplitudes of variable "SPIKES" are calculated
    [SPIKEZ.AMP]=getSpikeAmplitudes(M,SPIKES,SaRa);
    [SPIKEZ.neg.AMP]=getSpikeAmplitudes(M,SPIKES_neg,SaRa);
    [SPIKEZ.pos.AMP]=getSpikeAmplitudes(M,SPIKES_pos,SaRa);

    % save timestamps to structure SPIKEZ
    SPIKEZ.TS=SPIKES;
    SPIKEZ.pos.TS=SPIKES_pos;
    SPIKEZ.neg.TS=SPIKES_neg;


end