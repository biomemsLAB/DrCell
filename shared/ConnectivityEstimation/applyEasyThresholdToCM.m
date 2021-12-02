% according to Stefano De Blasi (Master thesis) a factor of 2 yield highest
% accuracy: only values of the Connectivity Matrix (CM) > mean(CM)+2*std(CM) are
% considered, all others are set to zero
% (MC)
%
% input:
% CM: Connectivity Matrix
% factor: scalar value, only CM values are returned that are greater than mean(CM)+factor*std(CM)

function [CM_nu,CM_exh,CM_inh]=applyEasyThresholdToCM(CM,factor)

    if nargin==1
        factor=2;
    end

    CM_nu = zeros(size(CM));
    
    [CM_exh,CM_inh]=seperateConnectivityMatrixToInhExc(CM);

    mask1=false(size(CM_exh));
    mask1(CM_exh>(mean(nonzeros(CM_exh))+factor*std(nonzeros(CM_exh))))=1;
    CM_exh(~mask1)=0;

    mask2=false(size(CM_inh));
    mask2(CM_inh<(mean(nonzeros(CM_inh))-(factor*std(nonzeros(CM_inh)))))=1;
    CM_inh(~mask2)=0;
    
    CM_nu(mask1)=CM_exh(mask1);
    CM_nu(mask2)=CM_inh(mask2);
end