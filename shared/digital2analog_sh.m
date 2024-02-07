% Convert digital sample values (datatype: uint) of 3brain HDMEA data to analog values in microVolt (datatype: double) (SH.KH)

function [m]=digital2analog_sh(M, BitDepth, MaxVolt, SignalInversion) 
    
    % Test if the raw signal in matrix M is saved as integer or if it was
    % already converted
    is_integer = all(all(floor(M)==M));

    if is_integer
        Bit=BitDepth;
        MxV=MaxVolt;
        SIV=SignalInversion;
        m = single(M);
        m=SIV*(m-(2^Bit)/2)*(MxV*2/2^Bit);
    else
        % M is already converetd -> return original values
        m = M;
    end
    
    
end