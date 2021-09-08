
    function SPIKEZ=calc_snr_fast(SPIKEZ, COL_RMS, COL_SDT)  
    % --- Signal to Noise Ratio (CN,MC) ------------       
        
        if ~any(isnan(COL_RMS)) && ~any(isnan(COL_SDT))
            
            % --- SNR for negative spikes ---
            if isfield(SPIKEZ, 'neg')
                if isfield(SPIKEZ.neg,'AMP') && size(SPIKEZ.neg.THRESHOLDS.Th,2)==size(SPIKEZ.TS,2)
                    for n=1:size(SPIKEZ.neg.TS,2) %for all electrodes           
                        if SPIKEZ.neg.N(n) > 0
                            SNR(n)=mean(nonzeros(abs(SPIKEZ.neg.AMP(:,n))))/COL_SDT(n)^2;
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
                end
            end
            % --- SNR for positive spikes ---
            if isfield(SPIKEZ, 'pos')
                if isfield(SPIKEZ.pos,'AMP') && size(SPIKEZ.pos.THRESHOLDS.Th,2)==size(SPIKEZ.TS,2)
                    for n=1:size(SPIKEZ.pos.TS,2) %for all electrodes           
                        if SPIKEZ.pos.N(n) > 0
                            SNR(n)=mean(nonzeros(abs(SPIKEZ.pos.AMP(:,n))))/COL_SDT(n)^2;
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
                end
            end
        
        else
            SPIKEZ.neg.SNR.SNR=NaN;
            SPIKEZ.neg.SNR.SNR_dB=NaN;
            SPIKEZ.neg.SNR.Mean_SNR_dB=NaN; 
            SPIKEZ.pos.SNR.SNR=NaN;
            SPIKEZ.pos.SNR.SNR_dB=NaN;
            SPIKEZ.pos.SNR.Mean_SNR_dB=NaN; 
            DISP('WARNING: SNR could not be calculated')
        end
         
    end
