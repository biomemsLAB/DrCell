function [SPIKEZ] = cardioSpikedetection(RAW,SPIKEZ)
        disp('Start spikedetection')
        
        SaRa = RAW.SaRa;
        
        % init structure SPIKEZ
        SPIKEZ=initSPIKEZ(SPIKEZ,RAW);
        
        % detect negative and/or positve spikes?
        %SPIKEZ.neg.flag = 1; % already set by GUI
        %SPIKEZ.pos.flag = 0;

        % save idleTime
        SPIKEZ.PREF.idleTime=200/1000; % idle time of 200 ms
        
        % call spikedetection function
        [SPIKEZ]=spikedetection(RAW,SPIKEZ); % detect spikes
        %[SPIKEZ]=combinedSpikeDetection(RAW,SPIKEZ); % spikedetection according to Lieb et al. (2017)
        
        % apply Refractory time
        [SPIKEZ]=applyRefractoryAndGetAmplitudes(RAW,SPIKEZ);
                
        % delete unregular electrodes
        [SPIKEZ]=cleanCardioElectrodes(SPIKEZ);
        
        % get the waveform of each spike
        timeWindow = 0.05; % +- 50 ms for each spike
        [SPIKEZ]=getSpikeWaveForms(RAW,SPIKEZ,timeWindow); 
        
        % calculate spike features like mean firing rate ect.
        SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
        SPIKEZ=calc_snr_fast(SPIKEZ, SPIKEZ.PREF.COL_RMS, SPIKEZ.PREF.COL_SDT);

        disp('')
        disp('------------------------------')
        disp('')

        

    end