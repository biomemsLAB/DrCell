% Load _TS.mat or _RAW.mat file
% Input:    file                filename
%           flag_waitbar        optional input:
%                               If set to 1: Window will open that shows user that file is being loaded.
%                               If set to 0: no window will open (Default)

function [SPIKEZ,RAW,spiketraincheck,spikedata,Date,Time,SaRa,EL_NAMES,EL_NUMS,NR_SPIKES,T,rec_dur,fileinfo,nr_channel,SPIKES,AMPLITUDES,HDspikedata] = read_mat(file, flag_waitbar)

if nargin == 1
    flag_waitbar = 0;
end


[~,file_name,ext] = fileparts(file);

if ~strcmp(ext,'.mat')
    errordlg('File extension has to be ".mat".', 'Error');
    return
end

if flag_waitbar
    H = waitbar(0,'Please wait - reading data file...');
else
    disp(['Importing data file: ' file_name]);
end

X=0; % counter for waitbar

if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end


%% Init
RAW=[];
SPIKEZ=[];
NR_SPIKES=[];
spikedata=0;
spiketraincheck = 0;
SPIKES = [];
AMPLITUDES = [];
HDspikedata = 0;

%% open file
temp2= load(file);
temp=temp2.temp;
if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end

%        % -------------load Data whit matfile (Sh_KH)
%         MF=matfile(file);
%         RAW.M=MF.M;
%         SaRa=MF.SaRa;
%        % ------------end matfile

%% Load RAW
if isfield(temp,'M') % if raw data
    spiketraincheck = 0;
    spikedata=0;
    RAW=temp;
    %RAW.M=temp.M;
    RAW.M=single(temp.M);
    T=temp.T;
    rec_dur=temp.rec_dur;
    SaRa=temp.SaRa;
    EL_NAMES=temp.EL_NAMES;
    EL_NUMS=temp.EL_NUMS;
    nr_channel=temp.nr_channel;
    Date=temp.Date;
    Time=temp.Time;
    fileinfo=temp.fileinfo;
    full_path=file;
end

if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end

%% Load SPIKEZ
if isfield(temp,'SPIKEZ') % if spiketrain
    spiketraincheck=1;
    spikedata=1;
    SPIKEZ=temp.SPIKEZ;
    % old_parameter
    SPIKES=SPIKEZ.TS; % SPIKES, AMPLITUDES, rec_dur, SaRa, EL_NUMS, optional: fileinfo, Time, Date
    AMPLITUDES=SPIKEZ.AMP;
    SPIKEZ.TSC = TS_M2Cell(SPIKEZ.TS);
    % if SPIKEZ.TS = 0, then use negative spikes:
    if SPIKEZ.TS==0
        SPIKES=SPIKEZ.neg.TS;
        AMPLITUDES=SPIKEZ.neg.AMP;
        SPIKEZ.TS=SPIKEZ.neg.TS;
        SPIKEZ.AMP=SPIKEZ.neg.AMP;
    end
    
    if size(SPIKEZ.TS,2)>1000 % if more than 1000 electrodes, use HDspikedata mode in DrCell
        HDspikedata  = 1;
    end
    
    if isfield(SPIKEZ,'N')
        NR_SPIKES=SPIKEZ.N;
    else
        for n=1:size(SPIKEZ.TS,2)
            NR_SPIKES(n)=length(nonzeros(SPIKEZ.TS(:,n)));
        end
    end
    if isfield(SPIKEZ,'PREF')
        rec_dur=SPIKEZ.PREF.rec_dur;
        SaRa=SPIKEZ.PREF.SaRa;
        if isfield(SPIKEZ.PREF,'fileinfo')
            fileinfo=SPIKEZ.PREF.fileinfo;
            Time=SPIKEZ.PREF.Time;
            Date=SPIKEZ.PREF.Date;
            EL_NUMS=SPIKEZ.PREF.EL_NUMS;
            EL_NAMES=SPIKEZ.PREF.EL_NAMES;
        else
            EL_NUMS=[12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
            clear EL_NAMES
            for i=1:size(EL_NUMS,2)
                EL_NAMES{i}=['EL ' num2str(EL_NUMS(i))];
            end
            Time='Unknown';
            Date='Unknown';
            fileinfo='';
        end
    else
        EL_NUMS=[12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
        clear EL_NAMES
        for i=1:size(EL_NUMS,2)
            EL_NAMES{i}=['EL ' num2str(EL_NUMS(i))];
        end
        Time='Unknown';
        Date='Unknown';
        fileinfo='';
    end
    
    if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
    
    % if no amplitude data available, init AMP with ones
    if isempty(SPIKEZ.AMP)
       SPIKEZ.AMP = zeros(size(SPIKEZ.TS)); 
       SPIKEZ.AMP(SPIKEZ.TS~=0) = 1;
    end
    
    % ensure that all TS and AMP matrices have same size
    % TS:
    if isfield(SPIKES,'pos')
        if isfield(SPIKEZ.pos,'TS')
            I=max([size(SPIKEZ.TS,1),size(SPIKEZ.neg.TS,1),size(SPIKEZ.pos.TS,1)]);
            N=max([size(SPIKEZ.TS,2),size(SPIKEZ.neg.TS,2),size(SPIKEZ.pos.TS,2)]);
            TS=zeros(I,N);
            TSneg=zeros(I,N);
            TSpos=zeros(I,N);
            TS(1:size(SPIKEZ.TS,1),1:size(SPIKEZ.TS,2))=SPIKEZ.TS(:,:);
            TSneg(1:size(SPIKEZ.neg.TS,1),1:size(SPIKEZ.neg.TS,2))=SPIKEZ.neg.TS(:,:);
            TSpos(1:size(SPIKEZ.pos.TS,1),1:size(SPIKEZ.pos.TS,2))=SPIKEZ.pos.TS(:,:);
            SPIKEZ.TS=TS;
            SPIKEZ.neg.TS=TSneg;
            SPIKEZ.pos.TS=TSpos;
            % AMP:
            I=max([size(SPIKEZ.AMP,1),size(SPIKEZ.neg.AMP,1),size(SPIKEZ.pos.AMP,1)]);
            N=max([size(SPIKEZ.AMP,2),size(SPIKEZ.neg.AMP,2),size(SPIKEZ.pos.AMP,2)]);
            AMP=zeros(I,N);
            AMPneg=zeros(I,N);
            AMPpos=zeros(I,N);
            AMP(1:size(SPIKEZ.AMP,1),1:size(SPIKEZ.AMP,2))=SPIKEZ.AMP(:,:);
            AMPneg(1:size(SPIKEZ.neg.AMP,1),1:size(SPIKEZ.neg.AMP,2))=SPIKEZ.neg.AMP(:,:);
            AMPpos(1:size(SPIKEZ.pos.AMP,1),1:size(SPIKEZ.pos.AMP,2))=SPIKEZ.pos.AMP(:,:);
            SPIKEZ.AMP=AMP;
            SPIKEZ.neg.AMP=AMPneg;
            SPIKEZ.pos.AMP=AMPpos;
            % delete rows that only contain zeros
            SPIKEZ.TS( ~any(SPIKEZ.TS,2), : ) = [];  %rows
            SPIKEZ.AMP( ~any(SPIKEZ.AMP,2), : ) = [];  %rows
        end
    end
    
    
    t.M= struct([]);
    RAW=t;
    T=0:(1/SaRa):rec_dur-(1/SaRa);
    if ~HDspikedata
        RAW.M=zeros(size(T,2),size(SPIKEZ.TS,2));
        for n=1:size(SPIKEZ.TS,2)
            index=ceil(SPIKEZ.TS(:,n).*SaRa)+1;
            index2 = index(~isnan(index)); % remove NaN values from index
            index2=int32(index2);
            RAW.M(index2,n)=SPIKEZ.AMP(~isnan(SPIKEZ.AMP(:,n)),n);
        end
    else
        RAW.M=0;
    end
    
    
    nr_channel=size(SPIKEZ.TS,2);
    full_path=file;
    
    %recalculate parameter to be compatible with old TS-files (as
    %some spike parameter has been changed
    SPIKEZ.neg=struct;
    SPIKEZ.neg.flag=0; % only calc spikesparameter for current TS
    SPIKEZ.pos=struct;
    SPIKEZ.pos.flag=0; % only calc spikesparameter for current TS
    SPIKEZ=SpikeFeaturesCalculation(SPIKEZ);
end


if flag_waitbar
    waitbar(1,H,'Complete')
    close(H)
    disp(['Loaded: ' file_name])
else
    disp(['Loaded: ' file_name])
end
end