% Input:    CM: Connectivity matrix (negative and poitive values allowed)
%           n: factor for the hard threshold (mean_CM + n * std_CM)
%
% Output:   FM: thresholded connectivity matrix containing inhibitory and excitatory connections
%           FM_exc: only excitatory connections (poitive values)
%           FM_inh: only inhibitory connections (negative values)
%           
% Dependencies: seperateConnectivityMatrixToInhExc, DDT
%
% Author: Manuel Ciba (2021)


function [FM,FM_exc,FM_inh]=applyThreshold_DDT(CM, n)

if nargin == 1
    n = 1; % default value
end

FM = zeros(size(CM));

[CM_exc,CM_inh]=seperateConnectivityMatrixToInhExc(CM);
FM_exc = DDT(CM_exc, n);

FM_inh = DDT(abs(CM_inh), n);
FM_inh = FM_inh * (-1);

FM(FM_exc ~=0) = FM_exc(FM_exc ~=0);
FM(FM_inh ~=0) = FM_inh(FM_inh ~=0);

end
