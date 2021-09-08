% use function "load_dat.m" to load .dat file and get all variables needed
% for this function (like e.g. Date, Time, M, T, ....)

function RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel)
                   RAW.M=M;
                   RAW.T=T;
                   RAW.rec_dur=rec_dur;
                   RAW.SaRa=SaRa;
                   RAW.EL_NAMES=EL_NAMES;
                   RAW.EL_NUMS=EL_NUMS;
                   RAW.nr_channel=nr_channel;
                   RAW.Date=Date;
                   RAW.Time=Time;
                   RAW.fileinfo=fileinfo;
end