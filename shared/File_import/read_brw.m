% Load Raw 3brain HDMEA Data (.brw)
% Input:    file                filename   
%           flag_waitbar        optional input:
%                               If set to 1: Window will open that shows user that file is being loaded.
%                               If set to 0: no window will open (Default)

function [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel,MaxVolt,MinVolt,BitDepth,SignalInversion] = read_brw(file, flag_waitbar)

if nargin == 1
    flag_waitbar = 0;
end


[~,file_name,ext] = fileparts(file);

if ~strcmp(ext,'.brw')
    errordlg('File extension has to be ".brw".', 'Error');
    return
end


if flag_waitbar
    H = waitbar(0,'Please wait - reading data file...');
else
    disp(['Importing data file: ' file_name]);
end

X=0; % counter for waitbar
MaxVolt = h5read(file,'/3BRecInfo/3BRecVars/MaxVolt'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
data2 = h5read(file,'/3BData/Raw'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
NRecFrames = h5read(file,'/3BRecInfo/3BRecVars/NRecFrames'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
BitDepth = h5read(file,'/3BRecInfo/3BRecVars/BitDepth'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
MinVolt = h5read(file,'/3BRecInfo/3BRecVars/MinVolt'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
SamplingRate = h5read(file,'/3BRecInfo/3BRecVars/SamplingRate'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
NCols = h5read(file,'/3BRecInfo/3BMeaChip/NCols'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
NRows = h5read(file,'/3BRecInfo/3BMeaChip/NRows'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
SignalInversion = h5read(file,'/3BRecInfo/3BRecVars/SignalInversion'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
NCols=double(NCols);
NCh=double(NCols*NRows);
Chs = h5read (file,'/3BRecInfo/3BMeaStreams/Raw/Chs'); if flag_waitbar; X=X+0.1; waitbar(X,H,'Please wait - reading data file...'); end
BitDepth= double(BitDepth);

%      %Convert Analog Values to Microvolt
%       m=double(m);
%       if MaxVolt==-MinVolt
%          m=SignalInversion*(m-(2^BitDepth)/2)*(MaxVolt*2/2^BitDepth);
%       end

NRecFrames=double(NRecFrames);
rec_dur =double(NRecFrames/SamplingRate);
SaRa = fix(SamplingRate);
NRecFrames=double(NRecFrames);
T = 0:(1/SamplingRate):((NRecFrames-1)/SamplingRate);
j=0;
for i=1:NRows
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
%Ch=Ch'; % Ch(:,1)=ROW , Ch(:,2)=COL , Ch(:,3)=ChID
M=zeros(NRecFrames,NCh);
M= reshape(data2,[NCh,NRecFrames]);
M=M';
clear data2;
EL_NUMS=Ch(3,:);
EL_NAMES=ss;
Date=0;
Time=0;
fileinfo='';
nr_channel=NCh;


if flag_waitbar
    waitbar(1,H,'Complete')
    close(H)
    disp(['Loaded: ' file_name])
else
    disp(['Loaded: ' file_name])
end

%% Erase first and last electrodes as they always show artefacts
M(:,1)=0;
M(:,end)=0;


end