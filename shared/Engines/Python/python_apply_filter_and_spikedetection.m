% This function can be called from a python script in order to apply filter
% and spike detection to DrCell compatible RAW MEA-data. 
%
%
% Currently it will work with data from 60-electrode-MEA chips and 
% 4096-electrode-HDMEA-Chips (has to be extended for other layouts such as 
% multi-well MEA chips).
%
% SWTEO spike detection is not included yet.
%
% Author: Manuel Ciba
% Date: 30.10.2023


function [RAW_python, SPIKEZ_python] = python_apply_filter_and_spikedetection(RAW, f_edge, thresholdFactor, baseFactor, HDrawdata, flag_pos, flag_neg, idleTime)

    disp("Applying filter...")
    [RAW, SPIKEZ.FILTER.Name, SPIKEZ.FILTER.f_edge] = ApplyFilter(RAW,f_edge,HDrawdata,0);
    SPIKEZ=initSPIKEZ(SPIKEZ,RAW);

    % positive or negative spikes?
    SPIKEZ.neg.flag = flag_neg;
    SPIKEZ.pos.flag = flag_pos;
    SPIKEZ.PREF.idleTime = idleTime;  % idleTime in seconds: after a spike, all spikes within idle time are ignored

    flag_calculateThreshold = 1;

    if flag_calculateThreshold
        disp("Calculating thresholds...")
        Multiplier_neg=thresholdFactor;
        Multiplier_pos=thresholdFactor;
        if ~HDrawdata; Std_noisewindow=baseFactor; else; Std_noisewindow=9999; end
        Size_noisewindow=0.05; % 50 ms
        flag_waitbar = 0;
        [~,~,~,SPIKEZ,COL_RMS,COL_SDT]=calculateThreshold(RAW,SPIKEZ,Multiplier_neg,Multiplier_pos,Std_noisewindow,Size_noisewindow,HDrawdata,flag_waitbar); % using default values of: flag_waitbar,auto,win_beg,win_end,threshrmsdecide);
        % calc SNR
        SPIKEZ=calc_snr_fast(SPIKEZ, COL_RMS, COL_SDT);
        SPIKEZ.PREF.CLEL = zeros(size(RAW.M,2),1);
        SPIKEZ.PREF.Invert_M = zeros(size(RAW.M,2),1);
     end
            
    %RAW=invertAndDeleteElectrodes(RAW, SPIKEZ.PREF.CLEL, SPIKEZ.PREF.Invert_M);

    % spikedetection
    disp("Detecting spikes...")
    SPIKEZ.PREF.flag_isHDMEAmode = HDrawdata;
    SPIKEZ=spikedetection(RAW,SPIKEZ);
    disp("Applying idle time and getting amplitudes...")
    [SPIKEZ]=applyRefractoryAndGetAmplitudes(RAW,SPIKEZ);
    disp("Calculating spike features...")
    SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
    SPIKEZ=calc_snr(RAW,SPIKEZ);

    % put the data into format that is compatible with python (only one
    % structure layer allowed)
    disp("Preparing MATLAB structures for Python...")
    SPIKEZ_python.TS = SPIKEZ.TS;
    SPIKEZ_python.AMP = SPIKEZ.AMP;
    SPIKEZ_python.rec_dur = SPIKEZ.PREF.rec_dur;
    RAW_python.M = RAW.M;
    RAW_python.T = RAW.T;

end