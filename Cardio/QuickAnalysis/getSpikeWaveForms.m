% save for each spike, the raw data (=WaveForm) at spike time +- timeWindow
% (timeWindow in seconds)
% 
% (MC)

function [SPIKEZ]=getSpikeWaveForms(RAW,SPIKEZ,timeWindow)

    T=RAW.T;
    SaRa = RAW.SaRa;
    timeWindow_idx = timeWindow*SaRa;

    % save the waveform of each spike
    for el=1:size(SPIKEZ.TS,2) % for all electrodes
       for i=1:length(nonzeros(SPIKEZ.TS(:,el)))
           idx=find(T==SPIKEZ.TS(i,el));
           a = max([1, idx-timeWindow_idx]);
           b = min([length(RAW.M(:,el)), idx+timeWindow_idx]);
           WAVEFORM.WaveForms{i,el} = RAW.M(a:b,el);
       end
    end
    
    % get amplitude values of minimum and maximum and the time between 
    for el=1:size(SPIKEZ.TS,2)
        for i=1:length(nonzeros(SPIKEZ.TS(:,el)))
            [ampMax, idxMax] = max(WAVEFORM.WaveForms{i,el});
            [ampMin, idxMin] = min(WAVEFORM.WaveForms{i,el});
            deltaIdx = abs(idxMax - idxMin);
            deltaTime = deltaIdx / SaRa;
            deltaAmp = ampMax - ampMin;
            
            SPIKEZ.WAVEFORM.maxAmp(i,el) = ampMax;
            SPIKEZ.WAVEFORM.minAmp(i,el) = ampMin;
            SPIKEZ.WAVEFORM.deltaTime(i,el) = deltaTime;
            SPIKEZ.WAVEFORM.deltaAmp(i,el) = deltaAmp;
        end
    end

end