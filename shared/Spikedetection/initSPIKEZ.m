% --- Initialize structure SPIKEZ (MC)
    function [SPIKEZ]=initSPIKEZ(SPIKEZ,RAW)
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
        

        SPIKEZ.PREF.rec_dur=RAW.rec_dur;
        SPIKEZ.PREF.SaRa=RAW.SaRa;
        SPIKEZ.PREF.EL_NAMES=RAW.EL_NAMES;
        SPIKEZ.PREF.EL_NUMS=RAW.EL_NUMS;
        SPIKEZ.PREF.nr_channel=RAW.nr_channel;
        SPIKEZ.PREF.Date=RAW.Date;
        SPIKEZ.PREF.Time=RAW.Time;
        SPIKEZ.PREF.fileinfo=RAW.fileinfo;
  
        SPIKEZ.TS=[];
        SPIKEZ.AMP=[];
        SPIKEZ.N=[];
        SPIKEZ.FR=[];
        SPIKEZ.aeFRmean=[];
        SPIKEZ.aeFRstd=[];
        SPIKEZ.aeN_FR=[];
        SPIKEZ.SNR=[];
        
        SPIKEZ.neg.TS=[];
        SPIKEZ.neg.AMP=[];
        SPIKEZ.neg.N=[];
        SPIKEZ.neg.SNR=[];
        
        SPIKEZ.pos.TS=[];
        SPIKEZ.pos.AMP=[];
        SPIKEZ.pos.N=[];
        SPIKEZ.pos.SNR=[];
        
    end
