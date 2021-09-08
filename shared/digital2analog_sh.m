%convert digital sample Values to analog values in microVolt (SH.KH)

function [m]=digital2analog_sh(M,raw) 
    
    Bit=raw.BitDepth;
    MxV=raw.MaxVolt;
    SIV=raw.SignalInversion;
    m = single(M);
    m=SIV*(m-(2^Bit)/2)*(MxV*2/2^Bit);
    
    
end