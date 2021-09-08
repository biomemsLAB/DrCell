function [BR,meanBR,stdBR,meanBR_ISI,stdBR_ISI,meanISI,stdISI,AMPmin,AMPmax]=calcBeatrate(SPIKEZ)

    SPIKEZ.TS(SPIKEZ.TS==0)=NaN;
    SPIKEZ.AMP(SPIKEZ.AMP==0)=NaN;

    % BeatRate (BR)
    for n = 1:size(SPIKEZ.TS,2)
        BR(n) = sum(~isnan(SPIKEZ.TS(:,n)))/SPIKEZ.PREF.rec_dur;
    end
    meanBR = mean(nonzeros(BR));
    stdBR = std(nonzeros(BR));
    
    % Interspikeinterval (ISI)
    for n = 1:size(SPIKEZ.TS,2)
        meanISI(n) = mean(diff(SPIKEZ.TS(:,n)));
    end
    for n = 1:size(SPIKEZ.TS,2)
        stdISI(n) = std(diff(SPIKEZ.TS(:,n)));
    end
    
    meanBR_ISI = mean(1./meanISI,'omitnan');
    stdBR_ISI = std(1./meanISI,'omitnan');
    
%     % Amplitude (Amp)
%     for n = 1:size(SPIKEZ.AMP,2)
%         AMPmin(n) = min(SPIKEZ.AMP(:,n),[],'omitnan');
%         AMPmax(n) = max(SPIKEZ.AMP(:,n),[],'omitnan');
%     end
    %AMPmin = SPIKEZ.WAVEFORM;
    
    AMPmin = NaN;
    AMPmax = NaN; % TODO!!! (Using SPIKEZ.WAVEFORMS)


end