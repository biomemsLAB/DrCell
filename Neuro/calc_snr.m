
function SPIKEZ=calc_snr(RAW,SPIKEZ)
% --- Signal to Noise Ratio (CN,MC) ------------

if ~isnan(SPIKEZ.neg.THRESHOLDS.Std_noisewindow) && ~isnan(SPIKEZ.neg.THRESHOLDS.Size_noisewindow)
    PREF(15)= SPIKEZ.neg.THRESHOLDS.Std_noisewindow;%get value for STD to find spike-free windows
    PREF(16)= SPIKEZ.neg.THRESHOLDS.Size_noisewindow;%get windowsize to find spike-free windows
    SaRa=RAW.SaRa;
    
    
    window_beg = int32(0.01*SaRa+1);
    window_end = int32((0.01+PREF(16))*SaRa);
    nr_win = 0;
    calc_beg = 1;
    calc_end = PREF(16)*SaRa;
    
    CALC = zeros((2*SaRa),(size(RAW.M,2)));
    SNR = zeros(1,size(RAW.M,2));
    SNR_dB = zeros(1,size(RAW.M,2));
    
    for n=1:size(RAW.M,2)
        while nr_win < (2/PREF(16))             % use two secondes of the signal
            
            %calculate STD in windows
            [~,sigma] = normfit(RAW.M(window_beg:window_end,int32(n))); %if you have the Statistics-Toolbox you can use "normfit" as well
            
            if((sigma < PREF(15)) && (sigma > 0))
                CALC(calc_beg:calc_end,n) = RAW.M(window_beg:window_end,n);
                calc_beg = calc_beg + PREF(16)*SaRa;
                calc_end = calc_end + PREF(16)*SaRa;
                window_beg = window_beg + int32(PREF(16)*SaRa);
                window_end = window_end + int32(PREF(16)*SaRa);
                
                if window_end>size(RAW.T,2) break; end %#ok
                
                ELEC_CHECK(n) = 1;
                nr_win = nr_win + 1;
                
            else
                window_beg = window_beg + int32(PREF(16)/2*SaRa);
                window_end = window_end + int32(PREF(16)/2*SaRa);
                
                if window_end>size(RAW.T,2) break; end %#ok
                
                if ((window_beg > 0.5*size(RAW.T,2)) && (nr_win == 0))
                    ELEC_CHECK(n) = 0; %noisy
                    break
                end
            end
        end
        
        nr_win = 0;
        window_beg = 0.01*SaRa+1;
        window_end = (0.01+PREF(16))*SaRa;
        calc_beg = 1;
        calc_end = PREF(16)*SaRa;
        
    end
    COL_RMS = sqrt(mean(CALC.^2));
    COL_SDT = std(CALC);
    
    
    % --- SNR for negative spikes ---
    if isfield(SPIKEZ, 'neg')
        if isfield(SPIKEZ.neg,'AMP') && size(SPIKEZ.neg.THRESHOLDS.Th,2)==size(RAW.M,2)  && size(SPIKEZ.neg.N,2)==size(RAW.M,2)
            for n=1:size(SPIKEZ.neg.TS,2) %for all electrodes
                if SPIKEZ.neg.N(n) > 0
                    SNR(n)=mean(nonzeros(abs(SPIKEZ.neg.AMP(:,n))))^2/COL_SDT(n)^2;
                else
                    SNR(n) = 1;
                end
            end
            for n = 1:size(SNR,2)  %In some cases the RMS value is 0.99xx. the value is then set to 1
                if (SNR(n)<1 || SPIKEZ.neg.THRESHOLDS.Th(n) == 10000)
                    SNR(n)=1;
                end
            end
            SNR_dB = 20*log10(SNR);
            Mean_SNR_dB = mean(nonzeros(SNR_dB));
            % save in structure:
            SPIKEZ.neg.SNR.SNR=SNR;
            SPIKEZ.neg.SNR.SNR_dB=SNR_dB;
            SPIKEZ.neg.SNR.Mean_SNR_dB=Mean_SNR_dB;
        else
            % save in structure:
            SPIKEZ.neg.SNR.SNR=NaN;
            SPIKEZ.neg.SNR.SNR_dB=NaN;
            SPIKEZ.neg.SNR.Mean_SNR_dB=NaN;
        end
    end
    % --- SNR for positive spikes ---
    if isfield(SPIKEZ, 'pos')
        if isfield(SPIKEZ.pos,'AMP') && size(SPIKEZ.pos.THRESHOLDS.Th,2)==size(RAW.M,2) && size(SPIKEZ.pos.N,2)==size(RAW.M,2)
            for n=1:size(SPIKEZ.pos.TS,2) %for all electrodes
                if SPIKEZ.pos.N(n) > 0
                    SNR(n)=mean(nonzeros(abs(SPIKEZ.pos.AMP(:,n))))^2/COL_SDT(n)^2;
                else
                    SNR(n) = 1;
                end
            end
            for n = 1:size(SNR,2)  %In some cases the RMS value is 0.99xx. the value is then set to 1
                if (SNR(n)<1 || SPIKEZ.pos.THRESHOLDS.Th(n) == 10000)
                    SNR(n)=1;
                end
            end
            SNR_dB = 20*log10(SNR);
            Mean_SNR_dB = mean(nonzeros(SNR_dB));
            % save in structure:
            SPIKEZ.pos.SNR.SNR=SNR;
            SPIKEZ.pos.SNR.SNR_dB=SNR_dB;
            SPIKEZ.pos.SNR.Mean_SNR_dB=Mean_SNR_dB;
        else
            % save in structure:
            SPIKEZ.pos.SNR.SNR=NaN;
            SPIKEZ.pos.SNR.SNR_dB=NaN;
            SPIKEZ.pos.SNR.Mean_SNR_dB=NaN;
        end
    end
    
else
    SPIKEZ.neg.SNR.SNR=NaN;
    SPIKEZ.neg.SNR.SNR_dB=NaN;
    SPIKEZ.neg.SNR.Mean_SNR_dB=NaN;
    SPIKEZ.pos.SNR.SNR=NaN;
    SPIKEZ.pos.SNR.SNR_dB=NaN;
    SPIKEZ.pos.SNR.Mean_SNR_dB=NaN;
    disp('WARNING: SNR could not be calculated')
end

end
