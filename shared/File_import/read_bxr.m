% Load time stamp 3brain HDMEA Data (.brx)
% Input:    file                filename
%           flag_waitbar        optional input:
%                               If set to 1: Window will open that shows user that file is being loaded.
%                               If set to 0: no window will open (Default)

function [TS,TSC,Date,Time,SaRa,EL_NAMES,EL_NUMS,T,rec_dur,fileinfo,nr_channel,ChIDs2NSpikes] = read_bxr(file, flag_waitbar)

if nargin == 1
    flag_waitbar = 0;
end


[~,file_name,ext] = fileparts(file);

if ~strcmp(ext,'.bxr')
    errordlg('File extension has to be ".bxr".', 'Error');
    return
end


if flag_waitbar
    H = waitbar(0,'Please wait - reading data file...');
else
    disp(['Importing data file: ' file_name]);
end

X=0; % counter for waitbar
% Import Spike Data
%MaxVolt = h5read(file,'/3BRecInfo/3BRecVars/MaxVolt');
%MinVolt = h5read(file,'/3BRecInfo/3BRecVars/MinVolt');
SpikeChIDs=h5read(file,'/3BResults/3BChEvents/SpikeChIDs'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
SpikeTimes=h5read(file,'/3BResults/3BChEvents/SpikeTimes'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
MeaChs2ChIDsMatrix=h5read(file,'/3BResults/3BInfo/MeaChs2ChIDsMatrix'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
%ChIDs2Labels=h5read(file,'/3BResults/3BInfo/ChIDs2Labels');
ChIDs2NSpikes=h5read(file,'/3BResults/3BInfo/3BSpikes/ChIDs2NSpikes'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
NRecFrames=h5read(file,'/3BRecInfo/3BRecVars/NRecFrames'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
SamplingRate=h5read(file,'/3BRecInfo/3BRecVars/SamplingRate'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
%BitDepth = h5read(file,'/3BRecInfo/3BRecVars/BitDepth');
NCols = h5read(file,'/3BRecInfo/3BMeaChip/NCols'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
NRows = h5read(file,'/3BRecInfo/3BMeaChip/NRows'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
NCols=double(NCols);
NCh=double(NCols*NRows);   % EL#
rec_dur=double(NRecFrames/SamplingRate);
SaRa=fix(SamplingRate);
nr_channel = NCh;
T = 0:(1/SaRa):double((NRecFrames-1)/int64(SaRa));
NRecFrames=double(NRecFrames);
Date=0;
Time=0;
fileinfo='';

% Create El_NUMS and EL_NAMES
j=0;
for i=1:NRows %
    Ch(1,(j+1):(j+NCols))=i;
    j=j+NCols;
end
j=0;
for i=1:NRows
    Ch(2,(j+1):(j+NCols))=1:NCols;
    j=j+NCols;
end
for i=1:NCh
    Ch(3,i)= ((Ch(1,i)-1)*64)+Ch(2,i);
end
ROW=Ch(1,:);
COL=Ch(2,:);
for i=1:NCh
    s=strcat('El: ', num2str(ROW(i)), ',', num2str(COL(i)));
    ss{i}=s;
end

if flag_waitbar; X=0; waitbar(X,H,'Converting spike times to cell (TSC)'); end

EL_NUMS=Ch(3,:);
EL_NAMES=ss;
%        Ch=Ch'; % Ch(:,1)=ROW , Ch(:,2)=COL , Ch(:,3)=ChID

% Create TS for Spikes Sh.Kh
%MeaChs2ChIDsMatrix2=MeaChs2ChIDsMatrix';
%SPIKESHD=zeros(max(ChIDs2NSpikes),NCh);
for i=1:NCh   
    
    if flag_waitbar; X=(i/NCh); waitbar(X,H,['Converting spike times to cell (TSC): Electrode ' num2str(i)]); end   
    
    a=find(SpikeChIDs==i-1); %  CH nummer ( 0 bis 4095 ) ist
    TSC{i}=double(SpikeTimes(a)./SamplingRate);
end
%TS= double(TS/SamplingRate);


if flag_waitbar; X=X+0.1; waitbar(X,H,'Converting cell to matrix'); end

% Create Cell Array
TS = TS_Cell2M(TSC);





if flag_waitbar
    waitbar(1,H,'Complete')
    close(H)
else
    disp(['converted: ' file_name])
end
end