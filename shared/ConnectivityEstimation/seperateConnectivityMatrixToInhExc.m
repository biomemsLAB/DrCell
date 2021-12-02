function [CM_exh,CM_inh]=seperateConnectivityMatrixToInhExh(CM)
CM_exh = CM;
CM_exh(CM<0)=0; % delete inhibitory connections leaving only exhibitory ones

CM_inh = CM;
CM_inh(CM>0)=0; % delete exh connections leaving only inh ones
end