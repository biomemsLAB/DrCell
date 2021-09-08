% only use the Nth strongest connections
% (MC)


function [CM_nu,CM_exh,CM_inh]=applyConstantThresholdToCM(CM,N)

    if nargin==1
        N=2;
    end

    CM_nu = zeros(size(CM));
    
    [CM_exh,CM_inh]=seperateConnectivityMatrixToInhExh(CM);

    mask1=false(size(CM_exh));
    mask1(CM_exh>(factor*std(nonzeros(CM_exh))))=1;
    CM_exh(~mask1)=0;

    mask2=false(size(CM_inh));
    mask2(CM_inh<(factor*std(nonzeros(CM_inh))))=1;
    CM_inh(~mask2)=0;
    
    
    CM_nu(mask2)=CM_inh(mask2);
    CM_nu(mask1)=CM_exh(mask1);
end