% --- apply ref time and get amplitudes --------------------------
function [SPIKEZ]=applyRefractoryAndGetAmplitudes(RAW,SPIKEZ)
% apply Refractory time
SPIKEZ.TS=idle_time(SPIKEZ.TS,SPIKEZ.PREF.idleTime);
SPIKEZ.neg.TS=idle_time(SPIKEZ.neg.TS,SPIKEZ.PREF.idleTime);
SPIKEZ.pos.TS=idle_time(SPIKEZ.pos.TS,SPIKEZ.PREF.idleTime); 

% delete all rows that only contain zeros:
SPIKEZ.TS=SPIKEZ.TS(any(SPIKEZ.TS,2),:);
SPIKEZ.neg.TS=SPIKEZ.neg.TS(any(SPIKEZ.neg.TS,2),:); 
SPIKEZ.pos.TS=SPIKEZ.pos.TS(any(SPIKEZ.pos.TS,2),:); 
 
% get amplitudes
[SPIKEZ.TS, SPIKEZ.AMP]=getSpikeAmplitudes(RAW,SPIKEZ.TS,SPIKEZ.PREF.SaRa,SPIKEZ.PREF.flag_isHDMEAmode); % for all current spikes
[SPIKEZ.neg.TS, SPIKEZ.neg.AMP]=getSpikeAmplitudes(RAW,SPIKEZ.neg.TS,SPIKEZ.PREF.SaRa,SPIKEZ.PREF.flag_isHDMEAmode); 
[SPIKEZ.pos.TS, SPIKEZ.pos.AMP]=getSpikeAmplitudes(RAW,SPIKEZ.pos.TS,SPIKEZ.PREF.SaRa,SPIKEZ.PREF.flag_isHDMEAmode); 

% nan padding and sorting
[SPIKEZ.TS,SPIKEZ.AMP] = nanPadding(SPIKEZ.TS,SPIKEZ.AMP);
[SPIKEZ.neg.TS,SPIKEZ.neg.AMP] = nanPadding(SPIKEZ.neg.TS,SPIKEZ.neg.AMP);
[SPIKEZ.pos.TS,SPIKEZ.pos.AMP] = nanPadding(SPIKEZ.pos.TS,SPIKEZ.pos.AMP);
end