function [THRESHOLDS,THRESHOLDS_pos,ELEC_CHECK,SPIKEZ,COL_RMS,COL_SDT]=cardioThreshold(RAW,SPIKEZ,factor)
        
        
        Std_noisewindow=5; %PREF(15);
        Size_noisewindow=0.05; %PREF(16);
        Multiplier_neg= factor ; %PREF(1);
        Multiplier_pos= 5; %PREF(17);
        
        % call function to calculate threshold
        SPIKEZ.neg.flag = 1;
        SPIKEZ.pos.flag = 0; 
        flag_waitbar=1;
        HDrawdata = 0;
        [THRESHOLDS,THRESHOLDS_pos,ELEC_CHECK,SPIKEZ,COL_RMS,COL_SDT]=calculateThreshold(RAW,SPIKEZ,Multiplier_neg,Multiplier_pos,Std_noisewindow,Size_noisewindow,HDrawdata,flag_waitbar);
        
        % calc SNR
        SPIKEZ=calc_snr_fast(SPIKEZ, COL_RMS, COL_SDT);

        
    end