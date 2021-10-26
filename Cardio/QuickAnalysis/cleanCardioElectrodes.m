% --- Clean Cardio electrodes
% 1) delte all spikes which occur at the same time (=artefacts)
% 2) delete all electrodes with less then 3 spikes per minute
% 3) delete non-median electrodes (e.g. if most electrodes show 50 spikes
% per minute, delete all electrodes with a different number of spikes per minute)
% 4) delete all spike trains which are not synchronous to other spike trains

function [SPIKEZ]=cleanCardioElectrodes(SPIKEZ)

rec_dur = SPIKEZ.PREF.rec_dur;

% zero padding
[SPIKEZ.TS,SPIKEZ.AMP] = zeroPadding(SPIKEZ.TS,SPIKEZ.AMP);

% 1) Delete Artefacts that occur "at the same time" (if delta t <= 0.0002 s)
%dt = 0.0002;
%[SPIKEZ.TS,SPIKEZ.AMP] = cardioDeleteSameTime(SPIKEZ.TS,SPIKEZ.AMP,dt);

% 2) Delte low FR
minFR=3;
[SPIKEZ.TS,SPIKEZ.AMP] = cardioDeleteLowFR(SPIKEZ.TS,SPIKEZ.AMP,SPIKEZ.PREF.rec_dur,minFR);

% 3) Delete non-median electrodes
[SPIKEZ.TS,SPIKEZ.AMP,numSpikes] = cardioDeleteNonMedianElectrodes(SPIKEZ.TS,SPIKEZ.AMP);

% 4) Delete non-synchronous electrodes
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