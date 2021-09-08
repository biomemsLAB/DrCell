% --- SpikeParameterCalculation (MC)
% this functions need those parameter as input:
% SPIKEZ.TS
% SPIKEZ.PREF.rec_dur
% 
% if SPIKEZ.pos.flag == 1:
% SPIKEZ.pos.TS
%
% if SPIKEZ.neg.flag == 1:
% SPIKEZ.neg.TS

    function SPIKEZ=SpikeParameterCalculation(SPIKEZ)
% SPIKEZ (entire structure)
% SPIKEZ.TS:                            Timestamps of spikes
% SPIKEZ.AMP:                           Amplitude of each spike
% SPIKEZ.AMPmean:                       mean Amp per el
% SPIKEZ.AMPstd:                        std Amp per el
% SPIKEZ.AMPn:                          number of Amps per el
% SPIKEZ.aeAMPmean:                     mean Amp of chip
% SPIKEZ.aeAMPstd:                      std Amp of chip
% SPIKEZ.aeAMPn:                        number of Amps of chip
% SPIKEZ.N:                             number of spikes per el.
% SPIKEZ.aeN:                           number of all spikes per chip
% SPIKEZ.FR:                            firing rate per el.
% SPIKEZ.aeFRmean:                      mean firing rate
% SPIKEZ.aeFRstd:                       st. deviation of firing rate
% SPIKEZ.aeFRn:                         number of firing rates =
% number of active electrodes
%
% SPIKEZ.FILTER.Name:                   band-low-highpass/stop
% SPIKEZ.FILTER.f_edge:                 edge frequency/ies
%
% SPIKEZ.THRESHOLDS.Th:                 Thresholds for spikedetection
% SPIKEZ.THRESHOLDS.CLEL:               cleared electrodes
% SPIKEZ.THRESHOLDS.Invert_M:           inverted electrodes
% SPIKEZ.THRESHOLDS.Multiplier:         threshold calc. parameter1
% SPIKEZ.THRESHOLDS.Std_noisewindow:    threshold calc. parameter2
% SPIKEZ.THRESHOLDS.Size_noisewindow:   threshold calc. parameter3
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
%         
% SPIKEZ.SNR.SNR:                       signal to noise ratio /el
% SPIKEZ.SNR.SNR_dB:                    signal to noise in dB /el
% SPIKEZ.SNR.Mean_SNR_dB:               mean snr value over all el
%
% SPIKEZ.pos.flag:                      0/1: de/activate pos spike detection
% SPIKEZ.pos.TS:                        positive spikes
% SPIKEZ.pos.AMP:                       positive amplitudes
% SPIKEZ.pos.AMPmean:                   mean Amp per el
% SPIKEZ.pos.AMPstd:                    std Amp per el
% SPIKEZ.pos.AMPn:                      number of Amps per el
% SPIKEZ.pos.aeAMPmean:                 mean Amp of chip
% SPIKEZ.pos.aeAMPstd:                  std Amp of chip
% SPIKEZ.pos.aeAMPn:                    number of Amps of chip
% SPIKEZ.pos.N:                         number of pos. spikes
% SPIKEZ.pos.aeN:                       number of all spikes per chip
% SPIKEZ.pos.THRESHOLDS.Th:             positive thresholds
% SPIKEZ.pos.THRESHOLDS.Multiplier:     positive th.calc. parameter1
% SPIKEZ.pos.THRESHOLDS.Std_noizewindow: positive th.calc. parameter2
% SPIKEZ.pos.THRESHOLDS.Size_noizewindow: positive th.calc. parameter3
% SPIKEZ.pos.SNR.SNR:                   signal to noise ratio /el
% SPIKEZ.pos.SNR.SNR_dB:                signal to noise in dB /el
% SPIKEZ.pos.SNR.Mean_SNR_dB:           mean snr value over all el
% SPIKEZ.pos.FR:                        firing rate per el.
% SPIKEZ.pos.aeFRmean:                  mean firing rate
% SPIKEZ.pos.aeFRstd:                   st. deviation of firing rate
% SPIKEZ.pos.aeFRn:                     number of firing rates =
% number of active electrodes
%
% SPIKEZ.neg.flag:                      0/1: de/activate neg spike detection
% SPIKEZ.neg.TS:                        negative spikes
% SPIKEZ.neg.AMP:                       negative amplitudes
% SPIKEZ.neg.AMPmean:                   mean Amp per el
% SPIKEZ.neg.AMPstd:                    std Amp per el
% SPIKEZ.neg.AMPn:                      number of Amps per el
% SPIKEZ.neg.aeAMPmean:                 mean Amp of chip
% SPIKEZ.neg.aeAMPstd:                  std Amp of chip
% SPIKEZ.neg.aeAMPn:                    number of Amps of chip
% SPIKEZ.neg.N:                         number of neg. spikes
% SPIKEZ.neg.aeN:                       number of all spikes per chip
% SPIKEZ.neg.THRESHOLDS.Th:             negative thresholds
% SPIKEZ.neg.THRESHOLDS.Multiplier:     negative th.calc. parameter1
% SPIKEZ.neg.THRESHOLDS.Std_noizewindow: neg. th.calc. parameter2
% SPIKEZ.neg.THRESHOLDS.Size_noizewindow: neg. th.calc. parameter3
% SPIKEZ.neg.SNR.SNR:                   signal to noise ratio /el
% SPIKEZ.neg.SNR.SNR_dB:                signal to noise in dB /el
% SPIKEZ.neg.SNR.Mean_SNR_dB:           mean snr value over all el
% SPIKEZ.neg.FR:                        firing rate per el.
% SPIKEZ.neg.aeFRmean:                  mean firing rate
% SPIKEZ.neg.aeFRstd:                   st. deviation of firing rate
% SPIKEZ.neg.aeFRn:                     number of firing rates =
% number of active electrodes
        
        %% init:
        SPIKEZ.N=zeros(1,size(SPIKEZ.TS,2));        % number of spikes per electrode
        SPIKEZ.FR=zeros(1,size(SPIKEZ.TS,2));       % firing rate per electrode 
        SPIKEZ.aeN=0;                               % number of all spikes per chip
        SPIKEZ.aeFRn=0;                             % number of active electrodes
        SPIKEZ.aeFRmean=0;                          % mean firing rate of all electrodes
        SPIKEZ.aeFRstd=0;                           % std firing rate of all electrodes
        
        SPIKEZ.AMPmean=zeros(1,size(SPIKEZ.TS,2));  % mean amplitude per electrode
        SPIKEZ.AMPstd=zeros(1,size(SPIKEZ.TS,2));   % std amplitude per electrode
        SPIKEZ.AMPn=zeros(1,size(SPIKEZ.TS,2));     % number of amplitudes per electrode
        SPIKEZ.aeAMPn=0;                            % number of amplitudes of all electrodes 
        SPIKEZ.aeAMPmean=0;                         % mean amplitude of all electrodes
        SPIKEZ.aeAMPstd=0;                          % std amplitude of all electrodes
        
        
        
        
        if ~isempty(nonzeros(SPIKEZ.TS))

            % --------- Parameter for current spikes --------
            % Number of Spikes per electrode
            for n = 1:(size(SPIKEZ.TS,2))
                SPIKEZ.N(n) = length(find(SPIKEZ.TS(:,n)));        % number of spikes per electrode
            end
            SPIKEZ.aeN=length(nonzeros(SPIKEZ.TS(:))); % number of all spikes per chip
            SPIKEZ.N(isnan(SPIKEZ.N))=0;
            SPIKEZ.aeN(isnan(SPIKEZ.aeN))=0;
            

            % Number of Spikes per minute (FR=Firingrate=Spikerate)
            for n=1:size(SPIKEZ.TS,2)
                    SPIKEZ.FR(n) = SPIKEZ.N(n)/(SPIKEZ.PREF.rec_dur)*60; % *60 -> spikes per minute   
            end
            SPIKEZ.aeFRn=length(nonzeros(SPIKEZ.FR)); % number of active electrodes
            SPIKEZ.aeFRmean=mean(nonzeros(SPIKEZ.FR));
            SPIKEZ.aeFRstd=std(nonzeros(SPIKEZ.FR)); 
            SPIKEZ.FR(isnan(SPIKEZ.FR))=0;
            SPIKEZ.aeFRn(isnan(SPIKEZ.aeFRn))=0;
            SPIKEZ.aeFRmean(isnan(SPIKEZ.aeFRmean))=0;
            SPIKEZ.aeFRstd(isnan(SPIKEZ.aeFRstd))=0;
            

            % amplitude
            for n=1:size(SPIKEZ.AMP,2)
               SPIKEZ.AMPmean(n)=mean(abs(nonzeros(SPIKEZ.AMP(:,n)))); 
               SPIKEZ.AMPstd(n)=std(abs(nonzeros(SPIKEZ.AMP(:,n)))); 
               SPIKEZ.AMPn(n)=length(abs(nonzeros(SPIKEZ.AMP(:,n)))); 
            end
            [SPIKEZ.aeAMPmean,SPIKEZ.aeAMPstd,SPIKEZ.aeAMPn]=CollectiveVariance(SPIKEZ.AMPmean,SPIKEZ.AMPstd,SPIKEZ.AMPn); 
            SPIKEZ.AMP(isnan(SPIKEZ.AMP))=0;
            SPIKEZ.aeAMPn(isnan(SPIKEZ.aeAMPn))=0;
            SPIKEZ.aeAMPmean(isnan(SPIKEZ.aeAMPmean))=0;
            SPIKEZ.aeAMPstd(isnan(SPIKEZ.aeAMPstd))=0;


            % --------- Parameter for positive spikes --------
            if SPIKEZ.pos.flag
                % Number of Spikes per electrode
                for n = 1:(size(SPIKEZ.pos.TS,2))
                    SPIKEZ.pos.N(n) = length(find(SPIKEZ.pos.TS(:,n)));        % number of spikes per electrode
                end
                SPIKEZ.pos.aeN=length(nonzeros(SPIKEZ.pos.TS(:))); % number of all spikes per chip
                SPIKEZ.pos.N(isnan(SPIKEZ.pos.N))=0;
                SPIKEZ.pos.aeN(isnan(SPIKEZ.pos.aeN))=0;

                % Number of Spikes per minute (FR=Firingrate=Spikerate)
                for n=1:size(SPIKEZ.pos.TS,2)
                        SPIKEZ.pos.FR(n) = SPIKEZ.pos.N(n)/(SPIKEZ.PREF.rec_dur)*60; % *60 -> spikes per minute   
                end
                SPIKEZ.pos.aeFRn=length(nonzeros(SPIKEZ.pos.FR)); % number of active electrodes
                SPIKEZ.pos.aeFRmean=mean(nonzeros(SPIKEZ.pos.FR));
                SPIKEZ.pos.aeFRstd=std(nonzeros(SPIKEZ.pos.FR)); 
                SPIKEZ.pos.FR(isnan(SPIKEZ.pos.FR))=0;
                SPIKEZ.pos.aeFRn(isnan(SPIKEZ.pos.aeFRn))=0;
                SPIKEZ.pos.aeFRmean(isnan(SPIKEZ.pos.aeFRmean))=0;
                SPIKEZ.pos.aeFRstd(isnan(SPIKEZ.pos.aeFRstd))=0;

                % Mean amplitude
                for n=1:size(SPIKEZ.pos.AMP,2)
                   SPIKEZ.pos.AMPmean(n)=mean(abs(nonzeros(SPIKEZ.pos.AMP(:,n)))); 
                   SPIKEZ.pos.AMPstd(n)=std(abs(nonzeros(SPIKEZ.pos.AMP(:,n)))); 
                   SPIKEZ.pos.AMPn(n)=length(abs(nonzeros(SPIKEZ.pos.AMP(:,n)))); 
                end
                [SPIKEZ.pos.aeAMPmean,SPIKEZ.pos.aeAMPstd,SPIKEZ.pos.aeAMPn]=CollectiveVariance(SPIKEZ.pos.AMPmean,SPIKEZ.pos.AMPstd,SPIKEZ.pos.AMPn); 
                SPIKEZ.pos.AMP(isnan(SPIKEZ.pos.AMP))=0;
                SPIKEZ.pos.aeAMPn(isnan(SPIKEZ.pos.aeAMPn))=0;
                SPIKEZ.pos.aeAMPmean(isnan(SPIKEZ.pos.aeAMPmean))=0;
                SPIKEZ.pos.aeAMPstd(isnan(SPIKEZ.pos.aeAMPstd))=0;
            end


            % --------- Parameter for negative spikes --------
            if SPIKEZ.neg.flag
                % Number of Spikes per electrode
                for n = 1:(size(SPIKEZ.neg.TS,2))
                    SPIKEZ.neg.N(n) = length(find(SPIKEZ.neg.TS(:,n)));        % number of spikes per electrode
                end
                SPIKEZ.neg.aeN=length(nonzeros(SPIKEZ.neg.TS(:))); % number of all spikes per chip
                SPIKEZ.neg.N(isnan(SPIKEZ.neg.N))=0;
                SPIKEZ.neg.aeN(isnan(SPIKEZ.neg.aeN))=0;
                

                % Number of Spikes per minute (FR=Firingrate=Spikerate)
                for n=1:size(SPIKEZ.neg.TS,2)
                        SPIKEZ.neg.FR(n) = SPIKEZ.neg.N(n)/(SPIKEZ.PREF.rec_dur)*60; % *60 -> spikes per minute   
                end
                SPIKEZ.neg.aeFRn=length(nonzeros(SPIKEZ.neg.FR)); % number of active electrodes
                SPIKEZ.neg.aeFRmean=mean(nonzeros(SPIKEZ.neg.FR));
                SPIKEZ.neg.aeFRstd=std(nonzeros(SPIKEZ.neg.FR));
                SPIKEZ.neg.FR(isnan(SPIKEZ.neg.FR))=0;
                SPIKEZ.neg.aeFRn(isnan(SPIKEZ.neg.aeFRn))=0;
                SPIKEZ.neg.aeFRmean(isnan(SPIKEZ.neg.aeFRmean))=0;
                SPIKEZ.neg.aeFRstd(isnan(SPIKEZ.neg.aeFRstd))=0;

                % Mean amplitude
                if ~isempty(SPIKEZ.AMP) % for HDMEA Spiketrain Data
                    for n=1:size(SPIKEZ.neg.AMP,2)
                       SPIKEZ.neg.AMPmean(n)=mean(abs(nonzeros(SPIKEZ.neg.AMP(:,n)))); 
                       SPIKEZ.neg.AMPstd(n)=std(abs(nonzeros(SPIKEZ.neg.AMP(:,n)))); 
                       SPIKEZ.neg.AMPn(n)=length(abs(nonzeros(SPIKEZ.neg.AMP(:,n)))); 
                    end
                    [SPIKEZ.neg.aeAMPmean,SPIKEZ.neg.aeAMPstd,SPIKEZ.neg.aeAMPn]=CollectiveVariance(SPIKEZ.neg.AMPmean,SPIKEZ.neg.AMPstd,SPIKEZ.neg.AMPn); 
                    SPIKEZ.neg.AMP(isnan(SPIKEZ.neg.AMP))=0;
                    SPIKEZ.neg.aeAMPn(isnan(SPIKEZ.neg.aeAMPn))=0;
                    SPIKEZ.neg.aeAMPmean(isnan(SPIKEZ.neg.aeAMPmean))=0;
                    SPIKEZ.neg.aeAMPstd(isnan(SPIKEZ.neg.aeAMPstd))=0;
                end
            end
            
            %% Set NaNs to zero
            
            
            
        end
        
        
        
    % Nested Function
        % --- Variance -----------------------------------------------------
        function [x,stdges,n]=CollectiveVariance(xj,sj,nj) 
            % xj: mean value of each electrode
            % sj: std value of each electrode
            % nj: number of elements of each electrode

            n = sum(nj,'omitnan'); % number of elements of entire chip
            if n>1
                %x = 1/n * sum(nj.*xj,'omitnan'); % mean value of entire chip
                x = mean(nonzeros(xj),'omitnan');
                varint = 1/(n-1) * sum(nj.*(sj.^2),'omitnan'); 
                varext = 1/(n-1) * sum(nj.*((xj-x).^2),'omitnan');
                varges = varint + varext; % variance of entire chip
            else
               x=xj(1);
               varges=0;
               n=nj(1);
            end

            stdges = sqrt(varges); % standard deviation of entire chip
        end

    end