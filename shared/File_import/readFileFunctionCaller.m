function [RAW,SPIKEZ]=readFileFunctionCaller(file,myPath,flag_waitbar,RAW,SPIKEZ)

% init
if nargin <= 3
    RAW=0;
    SPIKEZ=0;
end

if isempty(RAW)
    RAW=0;
end

% get file extension
[~,~,ext] = fileparts(file);
filepath = [myPath filesep file];

if strcmp(ext,'.dat') % if Labview ASCII file is selected
    [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel] = read_dat(filepath, flag_waitbar);
    RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel);
elseif strcmp(ext,'.rhd') % if RHD file is selected (Fileformat used at GSI)
    [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel]=read_Intan_RHD2000_file(myPath, file);
    RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel);
elseif strcmp(ext,'.txt') % if MCRACK file is selected (NOTE: ACTUALLY NOT USED ANYMORE)
    disp('MCRACK files are not supported by this function caller')
elseif strcmp(ext,'.mat') % if .mat file is selected (_TS or _RAW files)
    [SPIKEZ,RAW] =read_mat(filepath, flag_waitbar);
elseif strcmp(ext,'.brw') % if .brw (3brain Raw File) file is selected
    [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel,MaxVolt,MinVolt,BitDepth,SignalInversion]=read_brw(filepath,flag_waitbar);
    % Save Data in RAW structure
    RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel);
    RAW.MaxVolt = MaxVolt;
    RAW.MinVolt = MinVolt;
    RAW.BitDepth = BitDepth;
    RAW.SignalInversion = SignalInversion;
elseif strcmp(ext,'.bxr') % if .bxr (3brain Spike File) file is selected
    [TS,TSC,Date,Time,SaRa,EL_NAMES,EL_NUMS,T,rec_dur,fileinfo,nr_channel,ChIDs2NSpikes] = read_bxr(filepath,flag_waitbar);
    temp.M= struct([]);
    RAW=temp;
    RAW.T=T;
    SPIKEZ.TS=TS;
    SPIKEZ.TSC=TSC;
    SPIKEZ.N=ChIDs2NSpikes;
    SPIKEZ.PREF.rec_dur=rec_dur;
    SPIKEZ.PREF.nr_channel = NCh;
    SPIKEZ.PREF.fileinfo=fileinfo;
    SPIKEZ.AMP = ~isnan(TS);
    SPIKEZ.neg.flag=1;
    SPIKEZ.pos.flag=0;
    SPIKEZ.neg.TS=TS;
    SPIKEZ.neg.AMP=SPIKEZ.AMP;
elseif strcmp(ext,'.h5') % if .h5 (Multichannel systems format, converted from .mcd to .h5 using "Multichannel Data Manager" (available online)
    [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel] = read_MCS_hd5_RAW(filepath, flag_waitbar);
    RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel);
    SPIKEZ.TS = read_MCS_hd5_TS(filepath); % load spike Timestamp data if available
else % fileformat not supported
    errordlg('Unknown Fileformat')
end

end