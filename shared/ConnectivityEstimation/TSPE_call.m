% Call function TSPE - interface with DrCell format

function [CM,CM_exh,CM_inh,DM]=TSPE_call(TS, rec_dur, flag_waitbar, FLAG_NORM)


% Init
CM = 0;
CM_exh = 0;
CM_inh = 0;
DM = 0;

if isempty(TS)
    warning('Empty time stamp file!')
    return
end

if nargin < 4
    FLAG_NORM=1;
end

% Estimate connecitivy:
sdf=TS_M2sdf(TS,rec_dur); % convert format of time stamps like needed by TSPE
% FLAG_NORM=1; % use normalization
[CM, DM] = TSPE(sdf, [], [], [], [], FLAG_NORM, flag_waitbar);
%CM=TSPE_withSurrogateThreshold(sdf,[],[],[],[],[],[],[],[],flag_waitbar); % CMres: NxN matrix where N(i, j) is the total spiking probability edges (TSPE) i->j
CM = CM - diag(diag(CM)); % set diagonal to zero (=deleting self loops)

[CM_exh,CM_inh]=seperateConnectivityMatrixToInhExc(CM);

CM(isnan(CM))=0;
CM_exh(isnan(CM_exh))=0;
CM_inh(isnan(CM_inh))=0;
end
