

function [m]=digital2analog_sh(M,raw) %SH.KH 
    %convert digital sample Values to analog values in microVolt

    if size(raw.M,2)>60
        Bit=raw.BitDepth;
        MxV=raw.MaxVolt;
        SIV=raw.SignalInversion;
        m = single(M);
        m=SIV*(m-(2^Bit)/2)*(MxV*2/2^Bit);
    end
    
end