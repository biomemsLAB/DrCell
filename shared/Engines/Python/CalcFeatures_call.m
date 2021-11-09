function [back]=CalcFeatures_call(TS, AMP, rec_dur, SaRa ,Selection, time_win, FR_min, N, binSize)

if iscell(Selection)
    disp("To many arguemnts")
    return
end
MERGED.TS= TS;
MERGED.AMP = AMP;
MERGED.PREF.rec_dur = rec_dur;
MERGED.PREF.SaRa = SaRa;
N = 0;
binSize = 0;

[WIN]=CalcFeatures_function(MERGED,Selection,time_win,FR_min,N,binSize)
mean = WIN(1).parameter(1).mean
values = WIN(1).parameter(1).values
std = WIN(1).parameter(1).std
allEl = WIN(1).parameter(1).allEl
back = {[mean], [values], [std], [allEl]}

end
