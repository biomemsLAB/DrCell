 function [SPIKEZ,SPIKES,AMPLITUDES,NR_SPIKES,FR,N_FR,aeFRmean,aeFRstd,SNR,SNR_dB,Mean_SNR_dB]=copySpikesIntoOldStructure(SPIKEZ)
        
%         SPIKEZ.TS(SPIKEZ.TS==0) = NaN;
%         [SPIKEZ.TS, idx] = sort(SPIKEZ.TS);
%         SPIKEZ.AMP(idx) = SPIKEZ.AMP(:);  % AMPs are already correct(???)
%         
%         SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
%  
%         if ~isfield(SPIKEZ.neg,'TS')
%             if isempty(SPIKEZ.neg.TS)
%                 SPIKEZ.neg.TS = SPIKEZ.TS;
%                 SPIKEZ.neg.AMP = SPIKEZ.AMP;
%             end
%         end
        
        NR_SPIKES=SPIKEZ.N; 
        SPIKES = SPIKEZ.TS;
        AMPLITUDES = SPIKEZ.AMP;
        FR=SPIKEZ.FR;
        N_FR=SPIKEZ.aeN_FR; % number of active electrodes
        aeFRmean=SPIKEZ.aeFRmean;
        aeFRstd=SPIKEZ.aeFRstd;
        SNR=SPIKEZ.neg.SNR.SNR;
        SNR_dB = SPIKEZ.neg.SNR.SNR_dB;
        Mean_SNR_dB = SPIKEZ.neg.SNR.Mean_SNR_dB;
    end