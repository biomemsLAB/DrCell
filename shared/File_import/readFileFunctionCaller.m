function [RAW,SPIKEZ]=readFileFunctionCaller(file,myPath,flag_waitbar,flag_sixwell,RAW,SPIKEZ)

% init
if nargin == 3
    RAW=0;
    SPIKEZ=0;
    flag_sixwell = 0; % default: no sixwell MEA chip but normal one well with 59 electrodes
end

if nargin == 4
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
    [TS,Date,Time,SaRa,EL_NAMES,EL_NUMS,rec_dur,fileinfo,nr_channel] = read_MCS_hd5_TS(filepath); % load spike Timestamp data if available
    AMP = TS;
    AMP(~isnan(AMP))=1; % no amplitudes available, so create an artificial matrix
    SPIKEZ = createStructure_SPIKEZ(TS,AMP,SaRa,rec_dur,fileinfo,nr_channel,Time,Date,EL_NAMES,EL_NUMS);
else % fileformat not supported
    errordlg('Unknown Fileformat')
end

% if SixWell MEAs are used, change the electrode layout
if flag_sixwell
    %60 El MEA: EL_NUMS=[12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
    % SixWell MEA: 9 electrodes per well -> 11, 12, 13, 21, 22, 23, 31, 32, 33
    % Note: actually the numbering is A1, A2, ... F9 but the velocity calculation needs x y coordinates
    EL_NUMS=[22 23 12 60 31 21 33 31 21 12 33 22 23 12 13 10 32 11 32 11 13 50 23 21 11 12 33 32 22 31 31 22 32 33 12 11 21 23 20 13 11 32 11 32 40 13 12 23 31 33 12 21 31 33 21 22 20 13 23 22];
    clear EL_NAMES
    for i=1:size(EL_NUMS,2)
        EL_NAMES{i}=['EL ' num2str(EL_NUMS(i))];
    end 
    RAW.EL_NUMS = EL_NUMS;
    RAW.EL_NAMES = EL_NAMES;
end

end