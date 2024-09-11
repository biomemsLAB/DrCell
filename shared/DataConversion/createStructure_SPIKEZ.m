% creates the structure SPIKEZ which contains the spike time stamp matrix
% TS and the spike amplitude matrix AMP.
% 
% Input: 
% TS: Matrix containing time stamps in seconds (time stamp x electrode)
% AMP: Matrix containing amplitudes in micro volt (amplitude x electrode)
% rec_dur: recording duration in seconds
% fileinfo: string comment
% nr_channel: number of electrodes 
%
% Output:
% SPIKEZ: structure containing fields related to spikes and amplitudes.
% See function "initSPIKEZ.m" for more infos.

function SPIKEZ = createStructure_SPIKEZ(TS,AMP,SaRa,rec_dur,fileinfo,nr_channel,Time,Date,EL_NAMES,EL_NUMS)

    % force correct format
    if ~iscell(fileinfo)
        fileinfo = {fileinfo};
    end
    %if ~iscell(Date)
    %    Date = {Date};
    %end

    SPIKEZ.TS=TS;
    
    for n=1:size(SPIKEZ.TS,2)
        NR_SPIKES(n)=length(nonzeros(SPIKEZ.TS(:,n)));
    end

    SPIKEZ.N=NR_SPIKES;
    SPIKEZ.PREF.SaRa = SaRa;
    SPIKEZ.PREF.rec_dur=rec_dur;
    SPIKEZ.PREF.nr_channel = nr_channel;
    SPIKEZ.PREF.fileinfo=fileinfo;
    SPIKEZ.PREF.Time = Time;
    SPIKEZ.PREF.Date = Date;
    SPIKEZ.PREF.EL_NAMES = EL_NAMES;
    SPIKEZ.PREF.EL_NUMS = EL_NUMS;
    SPIKEZ.AMP = AMP;
    SPIKEZ.neg.flag=1;
    SPIKEZ.pos.flag=0;
    SPIKEZ.neg.TS=TS;
    SPIKEZ.neg.AMP=SPIKEZ.AMP;

end