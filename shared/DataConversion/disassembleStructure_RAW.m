% this function is only needed to provide old DrCell functions with
% non-structure variables. Note: Rather use structure "RAW" when creating new functions.

function [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel] = disassembleStructure_RAW(RAW)
                   M=RAW.M;
                   T=RAW.T;
                   rec_dur=RAW.rec_dur;
                   SaRa=RAW.SaRa;
                   EL_NAMES=RAW.EL_NAMES;
                   EL_NUMS=RAW.EL_NUMS;
                   nr_channel=RAW.nr_channel;
                   Date=RAW.Date;
                   Time=RAW.Time;
                   fileinfo=RAW.fileinfo;
end