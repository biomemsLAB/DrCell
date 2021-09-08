% --- Clean Cardio electrodes 
% 1) delete all electrodes with less then 3 spikes per minute
% 2) delete non-median electrodes (e.g. if most electrodes show 50 spikes
% per minute, delete all electrodes with a different number of spikes per minute)

function [SPIKEZ]=cleanCardioElectrodes(SPIKEZ)

rec_dur = SPIKEZ.PREF.rec_dur;

% zero padding
[SPIKEZ.TS,SPIKEZ.AMP] = zeroPadding(SPIKEZ.TS,SPIKEZ.AMP);

% Delte low FR
minFR=3;
[SPIKEZ.TS,SPIKEZ.AMP] = cardioDeleteLowFR(SPIKEZ.TS,SPIKEZ.AMP,SPIKEZ.PREF.rec_dur,minFR);

% Delete non-median electrodes
[SPIKEZ.TS,SPIKEZ.AMP,numSpikes] = cardioDeleteNonMedianElectrodes(SPIKEZ.TS,SPIKEZ.AMP);

% Delete non-synchronous electrodes
synchrony_matrix=cardioPairwiseSynchrony(SPIKEZ,rec_dur);
%cardioDetectCluster(synchrony_matrix)
[SPIKEZ.TS,SPIKEZ.AMP] = cardioDeleteNonSynchronousElectrodes(SPIKEZ.TS,SPIKEZ.AMP,synchrony_matrix);

% call zero padding again (for sorting and deleting emtpy rows)
[SPIKEZ.TS,SPIKEZ.AMP] = zeroPadding(SPIKEZ.TS,SPIKEZ.AMP);

SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
disp(['Number of active electrodes: ' num2str(SPIKEZ.aeFRn)])

% Check if spiketrain is clear (S=1)
[S,PREF] = SpikeContrast(SPIKEZ.TS,rec_dur, 0.1);
SPIKEZ.S=S;
disp(['Spike-contrast: ' num2str(S)])

end