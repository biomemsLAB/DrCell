% Calculate spike amplitudes by means of raw data (M) and spike
% timestamps (TS)
%
function [TS,AMP]=getSpikeAmplitudes(raw,TS,SaRa,flag_isHDMEAmode)

    if nargin < 4
       flag_isHDMEAmode = 0; % default: no HDMEA mode 
    end

    TS(TS==0)=NaN;
    TS=sort(TS, 1);
    AMP=zeros(size(TS));
    AMP(AMP==0)=NaN;
    SP = int32(TS*SaRa); % converting spike-timestamp to sample-position, consider sample offset of one sample later!
    for n=1:size(TS,2)
        adress=nonzeros((SP(~isnan(SP(:,n)),n)));
        if ~isempty(adress)
            for k=1:length(adress)
                AMP(k,n)=raw.M(adress(k)+1,n); % !!! +1 because M(0s)=not valid, 0s on index 1! -> Amplitude(1,60)=M(TS(1,60)*SaRa+1,60)
            end
        end
    end
    
    if flag_isHDMEAmode % convert values of amplitude if HDMEA data are used
        AMP=digital2analog_sh(AMP,raw.BitDepth, raw.MaxVolt, raw.SignalInversion);
        AMP(AMP==-4125)=NaN;
    end
end