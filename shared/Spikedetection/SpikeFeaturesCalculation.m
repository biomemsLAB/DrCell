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

function SPIKEZ=SpikeFeaturesCalculation(SPIKEZ)
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


rec_dur = SPIKEZ.PREF.rec_dur;
[SPIKEZ]=getSpikeFeatures(SPIKEZ,rec_dur);
[SPIKEZ.neg]=getSpikeFeatures(SPIKEZ.neg,rec_dur);
[SPIKEZ.pos]=getSpikeFeatures(SPIKEZ.pos,rec_dur);



%% Nested Function

    function [SPIKEZ]=getSpikeFeatures(SPIKEZ,rec_dur)
        
        if isfield(SPIKEZ,'TS')
            
            % Convert into "zero padding" (NaN's are converted to zeros)
            SPIKEZ.AMP(isnan(SPIKEZ.TS))=0;
            SPIKEZ.TS(isnan(SPIKEZ.TS))=0;
            
            % init:
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
                    SPIKEZ.FR(n) = SPIKEZ.N(n)/(rec_dur)*60; % *60 -> spikes per minute
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
            end
            
        end
        
    end


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