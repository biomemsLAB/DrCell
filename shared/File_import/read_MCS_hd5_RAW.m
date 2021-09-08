% convert hdf5 (Multichannel Systems) to _RAW.mat (DrCell) file
% Note: you have to install the matlab toolbox provided by MCS to open hdf5
% files (can be downloaded online)
% https://de.mathworks.com/matlabcentral/fileexchange/54976-mcsmatlabdatatools

function [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel] = read_MCS_hd5_RAW(file, flag_waitbar)

if nargin == 1
    flag_waitbar = 0;
end

[~,file_name,ext] = fileparts(file);

if ~strcmp(ext,'.h5')
    errordlg('File extension has to be ".h5".', 'Error');
    return
end

if flag_waitbar
    H = waitbar(0,'Please wait - analyzing data file...');
else
    disp(['Importing data file: ' file_name]);
end

% using the matlab toolbox provided by MCS to open hdf5 files (note:
% you have to install it manually in order to use this function)
% for more infos see: doc McsHDF5
data=McsHDF5.McsData(file);

X=0;
if flag_waitbar; X=X+0.5; waitbar(X,H,'Please wait - reading data file...'); end

Date = data.Data.Date;
Time = data.Recording{1,1}.TimeStamp;
EL_NAMES = data.Recording{1,1}.AnalogStream{1,1}.Info.Label;
for n=1:size(EL_NAMES,1)
    EL_NUMS(n) = str2double(EL_NAMES{n});
    EL_NAMES{n} = ['EL ' EL_NAMES{n}];
end



if flag_waitbar; X=X+0.5; waitbar(X,H,'Please wait - reading data file...'); end

M = data.Recording{1,1}.AnalogStream{1,1}.ChannelData' ./1000000; % from pV to �V
rec_dur = double(data.Recording{1,1}.Duration ./1000000); % from �s to s
SaRa = double(size(M,1)/rec_dur);
T = 0: 1/SaRa: rec_dur -1/SaRa;
fileinfo = {data.Data.MeaName};
nr_channel = size(M,2);

% change order of the electrodes such as used for the standard DrCell layout
[EL_NUMS,idx] = sort(EL_NUMS);
EL_NAMES = EL_NAMES(idx);
M = M(:,idx);

if flag_waitbar
    waitbar(1,H,'Complete')
    close(H)
    disp(['Loaded: ' file_name])
else
    disp(['Loaded: ' file_name])
end

end



