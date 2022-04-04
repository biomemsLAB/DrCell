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



function [SPIKEZ]=spikedetection(raw,SPIKEZ) %SH.KH


M=raw.M;
T=raw.T;
SaRa=raw.SaRa;

% init
SPIKES = zeros(1,size(raw.M,2));
SPIKES_pos = [];
SPIKES_neg = [];
SPIKEZ.NR  = [];
flag_M_is_converted = false;            % flag is set if M is converted by digital2analog_sh
flag_isHDMEAmode = SPIKEZ.PREF.flag_isHDMEAmode;      % true: HDMEAmode, false: non-HDMEAmode

negSpike_Box=SPIKEZ.neg.flag;
posSpike_Box=SPIKEZ.pos.flag;
%idleTime=SPIKEZ.PREF.idleTime;

% load negative thresholds
if negSpike_Box==1
    if size(SPIKEZ.neg.THRESHOLDS.Th,1)==1 % if threshold consists only of one value
        SPIKEZ.PREF.dyn_TH=0;
        THRESHOLDS=SPIKEZ.neg.THRESHOLDS.Th;
    else % interpolate dynamic threshold
        SPIKEZ.PREF.dyn_TH=1;
        THRESHOLDS=zeros(size(M));
        for n=1:size(SPIKEZ.neg.THRESHOLDS.Th,2)
            x=T(1,1):size(T,2)/size(SPIKEZ.neg.THRESHOLDS.Th,1):size(T,2)-1; % 0 : 1000 : 599000
            y=SPIKEZ.neg.THRESHOLDS.Th(:,n); % -7.12 -9.22 ..... size=600x60
            xq=0:1:size(T,2)-1; % 0 : 1 : 599999
            THRESHOLDS(:,n)=interp1(x,y,xq);
        end
    end
    THRESHOLDS(THRESHOLDS==10000)=NaN; % replace non-valid threshold values (by default: 10000) with NaN. Otherwise 1 spike will be detected on non-valid electrodes 
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
            x=T(1,1):size(T,2)/size(SPIKEZ.pos.THRESHOLDS.Th,1):size(T,2)-1;
            y=SPIKEZ.pos.THRESHOLDS.Th(:,n);
            xq=0:1:size(T,2)-1;
            THRESHOLDS_pos(:,n)=interp1(x,y,xq);
        end
    end
    THRESHOLDS_pos(THRESHOLDS_pos==10000)=NaN; % replace non-valid threshold values (by default: 10000) with NaN. Otherwise 1 spike will be detected on non-valid electrodes
end



% detect negative spikes
if negSpike_Box==1
    SPIKES_neg=zeros(1,size(M,2));
    SPIKEZ.neg.AMP=zeros(1,size(M,2));
    
    flag_enoughMemory = testMemory();
    if flag_enoughMemory % if enoughMemory
        M2 = zeros(size(M,1),size(M,2));
        %             if SPIKEZ.PREF.dyn_TH==0
        if flag_isHDMEAmode && ~flag_M_is_converted
            M = digital2analog_sh(M,raw);
            flag_M_is_converted = true;
        end
        if SPIKEZ.PREF.dyn_TH==0
            M2 = M-THRESHOLDS;
        end
        if SPIKEZ.PREF.dyn_TH==1
            for nn = 1:size(M,2)
                M2(:,nn) = {M(:,nn)-THRESHOLDS(:,nn)};
            end
        end
        M2=(M2<0);
        if size(M,2)>60
            M2(:,1)=0;
        end
        %             end
    else % When the memory is low
        %             if SPIKEZ.PREF.dyn_TH==0
        M2 = {[]};
        for n = 1:size(M,2)
            if flag_isHDMEAmode
                el=digital2analog_sh(M(:,n),raw);
            else
                el=M(:,n);
            end
            if SPIKEZ.PREF.dyn_TH==0
                el=el-THRESHOLDS(1,n);
            end
            if SPIKEZ.PREF.dyn_TH==1
                el=el-THRESHOLDS(:,n);
            end
            el=(el<0);
            M2(1,n)=find(el);
            el=0;
        end
        if flag_isHDMEAmode
            M2(1,n)={[]};
        end
        %             end
    end
    %         if SPIKEZ.PREF.dyn_TH==1
    %             for n = 1:size(M,2)
    %                 M2(:,n) = {M(:,n)-THRESHOLDS(:,n)};
    %             end
    %         end
    
    
    for n = 1:size(M2,2)                        % n: current collum in M2 and SPIKES
        k = 0;                                  % k: current row in SPIKES
        m = 1;                                  % m: current row in M2
        if iscell(M2)
            K=cell2mat(M2(1,n));
            if ~isempty(K)
                el=digital2analog_sh(M(:,n),raw);
            end
        else
            K=find(M2(:,n));
            el=(M(:,n));
        end
        
        while m <= size(K,1)
            %beginning of spikes
            potspikebeg = K(m);
            %End of Spikes
            while  m <= size(K,1)-1 && K(m+1)==K(m)+1
                m=m+1;
            end
            potspikeend = K(m);
            %Peak
            k=k+1;
            if  potspikeend == potspikebeg
                Amp=el(potspikebeg);
                SPIKES_neg(k,n) = T(potspikebeg);
            else
                SEARCH = el(potspikebeg:potspikeend);
                [Amp,I]= min(SEARCH); % search for negative peak (-> min)
                SPIKES_neg(k,n) = T((potspikebeg-1+I));
            end
            
            SPIKEZ.neg.AMP(k,n)=Amp;
            m = m + 1;
        end
    end
end

% detect positive spikes
if posSpike_Box==1
    SPIKES_pos=zeros(1,size(M,2));
    SPIKEZ.pos.AMP=zeros(1,size(M,2));
    THRESHOLDS_pos=SPIKEZ.pos.THRESHOLDS.Th; %Sh.Kh
    if size(THRESHOLDS_pos,2)==size(M,2)
        flag_enoughMemory = testMemory();
        if flag_enoughMemory % if enoughMemory
            M2 = zeros(size(M,1),size(M,2));
            if SPIKEZ.PREF.dyn_TH==0
                if flag_isHDMEAmode && ~flag_M_is_converted
                    M = digital2analog_sh(M,raw);
                end
                M2 = M-THRESHOLDS_pos;
                M2 =(M2>0);
                if flag_isHDMEAmode
                    M2(:,1)=0;
                end
            end
        else % When the memory is low
            %if SPIKEZ.PREF.dyn_TH==0
            M2 = {[]};
            for n = 1:size(M,2)
                if flag_isHDMEAmode
                    el=digital2analog_sh(M(:,n),raw);
                else
                    el=M(:,n);
                end
                if SPIKEZ.PREF.dyn_TH==0
                    el=el-THRESHOLDS_pos(1,n);
                end
                if SPIKEZ.PREF.dyn_TH==1
                    el=el-THRESHOLDS_pos(:,n);
                end
                el=(el>0);
                M2(1,n)=find(el);
                el=0;
            end
            if flag_isHDMEAmode
                M2(1,n)={[]};
            end
            %end
        end
        if SPIKEZ.PREF.dyn_TH==1 %  eslah shavad behine shavad shiva
            for n = 1:size(M2,2)
                M2(:,n) = M(:,n)-THRESHOLDS_pos(:,n);
            end
        end
        for n = 1:size(M2,2)                        % n: current collum in M2 and SPIKES
            k = 0;                                  % k: current row in SPIKES
            m = 1;                                  % m: current row in M2
            if iscell(M2)
                K=cell2mat(M2(1,n));
                if ~isempty(K)
                    el=digital2analog_sh(M(:,n),raw);
                end
            else
                K=find(M2(:,n));
                el=(M(:,n));
            end
            while m <= size(K,1)
                %beginning of spikes
                potspikebeg = K(m);
                %End of Spikes
                while  m <= size(K,1)-1 && K(m+1)==K(m)+1
                    m=m+1;
                end
                potspikeend = K(m);
                % = Peak
                k=k+1;
                if  potspikeend == potspikebeg
                    Amp=el(potspikebeg);
                    SPIKES_pos(k,n) = T(potspikebeg);
                else
                    SEARCH = M(potspikebeg:potspikeend,n);
                    [Amp,I]= max(SEARCH); % search for positive peak (->max)
                    SPIKES_pos(k,n) = T(potspikebeg-1+I);
                end
                SPIKEZ.pos.AMP(k,n)=Amp;
                m = m + 1;
            end
        end
    end
    
end

%---- detect positive spikes (old codes)
%         if size(THRESHOLDS_pos,2)==size(M,2)
%             M2 = zeros(size(M,1),size(M,2));
%
%             if SPIKEZ.PREF.dyn_TH==0
%                 for n = 1:size(M2,2)
%                     M2(:,n) = M(:,n)-THRESHOLDS_pos(1,n);
%                 end
%             end
%
%             if SPIKEZ.PREF.dyn_TH==1
%                 for n = 1:size(M2,2)
%                     M2(:,n) = M(:,n)-THRESHOLDS_pos(:,n);
%                 end
%             end

%            M2 = (M2>0);
%             for n = 1:size(M2,2)                        % n: current collum in M2 and SPIKES
%                 k = 0;                                  % k: current row in SPIKES
%                 m = 1;                                  % m: current row in M2
%                 K=find(M2(:,n));
%                 while m <= size(K,1)
%                     %beginning of spikes
%                     potspikebeg = K(m);
%                     %End of Spikes
%                     while  m <= size(K,1)-1 && K(m+1)==K(m)+1
%                         m=m+1;
%                     end
%                     potspikeend = K(m);
%                     % = Peak
%                     k=k+1;
%                     if  potspikeend == potspikebeg
%                         Amp=M(potspikebeg,n);
%                         SPIKES_pos(k,n) = T(potspikebeg);
%                     else
%                         SEARCH = M(potspikebeg:potspikeend,n);
%                         [Amp,I]= max(SEARCH); % search for positive peak (->max)
%                         SPIKES_pos(k,n) = T(potspikebeg-1+I);
%                     end

%                     SPIKEZ.pos.AMP(k,n)=Amp;
%                     m = m + 1;
%                 end
%                 SPIKEZ.NR(n) = length(find(SPIKES_pos(:,n))); % number of spikes per electrode
%             end
%         end
%     end


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

% save timestamps to structure SPIKEZ
SPIKEZ.TS=SPIKES;
SPIKEZ.pos.TS=SPIKES_pos;
SPIKEZ.neg.TS=SPIKES_neg;
SPIKES=sparse(SPIKES);
SPIKEZ.TSC = num2cell(SPIKES,1);



end