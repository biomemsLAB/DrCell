function [TS,AMP] = cardioDeleteLowFR(TS,AMP,rec_dur,minFR)

        [TS, AMP, numDeletedElectrodes]=deleteLowFiringRateSpiketrains(TS,AMP,rec_dur,minFR);
        disp([num2str(numDeletedElectrodes) ' electrodes deleted because less than ' num2str(minFR) ' spikes per minute'])
    
        %[SPIKEZ,SPIKES,AMPLITUDES,NR_SPIKES]=cardioCopySpikesIntoOldStructure(SPIKEZ);
    end