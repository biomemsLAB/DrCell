% Call function TSPE - interface with DrCell format

function [CM,CM_exh,CM_inh]=TSPE_withSurrogateThreshold_call(TS,rec_dur,flag_waitbar)
% Estimate connecitivy:
sdf=TS_M2sdf(TS,rec_dur); % convert format of time stamps like needed by TSPE
CM=TSPE_withSurrogateThreshold(sdf,[],[],[],[],[],[],[],[],flag_waitbar); % CMres: NxN matrix where N(i, j) is the total spiking probability edges (TSPE) i->j
CM = CM - diag(diag(CM)); % set diagonal to zero (=deleting self loops)

[CM_exh,CM_inh]=seperateConnectivityMatrixToInhExc(CM);

CM(isnan(CM))=0;
CM_exh(isnan(CM_exh))=0;
CM_inh(isnan(CM_inh))=0;
end
