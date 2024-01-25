% UNDER CONSTRUCTION (MC)

% Load time stamps from Axion file (.spk)
% Input:    file_path           full path and filename
%           flag_waitbar        optional input:
%                               If set to 1: Window will open that shows user that file is being loaded.
%                               If set to 0: no window will open (Default)

function [TS,TSC,Date,Time,SaRa,EL_NAMES,EL_NUMS,T,rec_dur,fileinfo,nr_channel,ChIDs2NSpikes] = read_axion_spk(file_path, flag_waitbar)

if nargin == 1
    flag_waitbar = 0;
end


[~,file_name,ext] = fileparts(file_path);

if ~strcmp(ext,'.spk')
    errordlg('File extension has to be ".spk".', 'Error');
    return
end


if flag_waitbar
    H = waitbar(0,'Please wait - reading data file...');
else
    disp(['Importing data file: ' file_name]);
end

X=0; % counter for waitbar

% load all spike trains
Data = AxisFile(file_path).SpikeData.LoadData; 

% get meta data which is saved in any non-empty well 
for i = 1:size(Data, 1)  % for Well Aj ... Dj
    for j= 1:size(Data, 2)  % for Well i1 ... i6
        for k = 1:size(Data,3)
            for l = 1:size(Data,4)
                if ~isempty(Data{i,j,k,l})
                    metadata = Data{i,j,k,l}(1).Source;
                end
            end
        end
    end
end

% get rec_dur and SaRa
rec_dur = metadata.Duration;
SaRa = metadata.SamplingFrequency;

% use function axion24well2TS to read csv data (because this function was
% written before this function. This function can also be modified to
% generate the TS files directly

end