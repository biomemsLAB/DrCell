function [m]=analog2digital_sh(M, BitDepth, MaxVolt, SignalInversion) 
    

   m=SignalInversion*(M/(MaxVolt*2/2^BitDepth))+((2^BitDepth)/2); % %convert analog values to digital sample Values

        
end