% Calculate spike amplitudes by means of raw data (M) and spike
% timestamps (TS)
%
function [AMPLITUDES]=getSpikeAmplitudes(raw,TS,SaRa)
    
    AMPLITUDES=zeros(size(TS));
    SP = int32(TS*SaRa); % converting spike-timestamp to sample-position, consider sample offset of one sample later!
    for n=1:size(TS,2)
        adress=nonzeros(SP(:,n));
        if size(adress)~=0
            for k=1:size(adress)
                AMPLITUDES(k,n)=raw.M(adress(k)+1,n); % !!! +1 because M(0s)=not valid, 0s on index 1! -> Amplitude(1,60)=M(TS(1,60)*SaRa+1,60)
            end
        end
    end
%     if(size(raw.M,2))>60 % for .BRW Data Sh-Kh  
%         AMPLITUDES=digital2analog_sh(AMPLITUDES,raw);
%         AMPLITUDES(AMPLITUDES==-4125)=0;
%     end
end