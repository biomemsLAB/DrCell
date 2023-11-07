% This function can be called from a python script in order to 
% electrodee (has to be extended for multi-well MEA chips)

% Author: Manuel Ciba
% Date: 30.10.2023


function back = python_calculate_features(TS, AMP, rec_dur, SaRa ,Selection, time_win, FR_min)

if iscell(Selection)
    disp("Error: More than one feature was selected")
    return
end

% Create structure MERGED which is needed as input for CalcFeature_function
MERGED.TS= TS;
MERGED.AMP = AMP;
MERGED.PREF.rec_dur = rec_dur;
MERGED.PREF.SaRa = SaRa;
N = 0;
binSize = 0;
flag_HDMEA = 0;
flag_norm = 0;
flag_waitbar = 0;

[WIN]=CalcFeatures_function(MERGED, Selection, time_win, FR_min, N, binSize, flag_HDMEA, flag_norm, flag_waitbar);

FEATURES=unpackWIN2FEATURES(WIN); % unpack structure WIN to FEATURES

back = {{FEATURES.mean},{FEATURES.std},{FEATURES.values},{FEATURES.pref},{FEATURES.YLabel}};

end