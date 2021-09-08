% --- Signal to Noise Ratio (CN) ------------
    function SPIKEZ=calc_snr(RAW,SPIKEZ)        
      
        %PREF(15) = str2double(get(findobj(gcf,'Tag','STD_noisewindow'),'string'));              %get value for STD to find spike-free windows
        %PREF(16) = str2double(get(findobj(gcf,'Tag','Size_noisewindow'),'string'))/1000;       %get windowsize to find spike-free windows
        
        PREF(15)= SPIKEZ.THRESHOLDS.Std_noisewindow;
        PREF(16)= SPIKEZ.THRESHOLDS.Size_noisewindow;
        SaRa=RAW.SaRa;
        M=RAW.M;
        SPIKE=SPIKEZ.TS;
        NR_SPIKE=SPIKEZ.N;
        
        window_beg = 0.01*SaRa+1;
        window_end = (0.01+PREF(16))*SaRa;
        nr_win = 0;
        calc_beg = 1;
        calc_end = PREF(16)*SaRa;
        
        CALC = zeros((2*SaRa),(size(M,2)));
        SNR = zeros(1,size(M,2));
        SNR_dB = zeros(1,size(M,2));
        
            for n=1:size(M,2)
                while nr_win < (2/PREF(16))             % use two secondes of the signal
                    
                    %calculate STD in windows
                    [~,sigma] = normfit(M(window_beg:window_end,n)); %if you have the Statistics-Toolbox you can use "normfit" as well
                    
                    if((sigma < PREF(15)) && (sigma > 0))
                        CALC(calc_beg:calc_end,n) = M(window_beg:window_end,n);
                        calc_beg = calc_beg + PREF(16)*SaRa;
                        calc_end = calc_end + PREF(16)*SaRa;
                        window_beg = window_beg + PREF(16)*SaRa;
                        window_end = window_end + PREF(16)*SaRa;
                        
                        if window_end>size(T,2) break; end %#ok
                        
                        ELEC_CHECK(n) = 1;
                        nr_win = nr_win + 1;
                        
                    else
                        window_beg = window_beg + PREF(16)/2*SaRa;
                        window_end = window_end + PREF(16)/2*SaRa;
                        
                        if window_end>size(T,2) break; end %#ok
                        
                        if ((window_beg > 0.5*size(T,2)) && (nr_win == 0))
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
        
        
        
        for i=1:size(M,2) %for all electrodes
            
            if NR_SPIKE(i) > 0
                for k=1:NR_SPIKE(i) %for i-th electrode
                     if ceil(SPIKE(k,i)*SaRa) == 0 % MC: to prevent this case: M(0,n)
                        amptemp(k) = - M(1,i);
                     else
                        amptemp(k) = - M((ceil(SPIKE(k,i)*SaRa)),i);
                     end
                end
                
                SNR(i) = (mean(amptemp)/COL_SDT(i))^2;
                
                amptemp=[];
            else
                SNR(i) = 1;
            end
        end
        
        for n = 1:size(SNR,2)  %In some cases the RMS value is 0.99xx. the value is then set to 1
            if (SNR(n)<1 || THRESHOLDS(n) == 10000)
                SNR(n)=1;
            end
        end
        
        SNR_dB = 20*log(SNR);
        Mean_SNR_dB = mean(SNR_dB);
    
        % save in structure:
        SPIKEZ.SNR.SNR=SNR;
        SPIKEZ.SNR.SNR_dB=SNR_dB;
        SPIKEZ.SNR.Mean_SNR_dB=Mean_SNR_dB;
        
         
    end
