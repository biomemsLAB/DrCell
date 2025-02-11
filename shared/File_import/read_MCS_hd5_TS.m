% convert hdf5 (Multichannel Systems) to _RAW.mat (DrCell) file
% Note: you have to install the matlab toolbox provided by MCS to open hdf5
% files (can be downloaded online)
% https://de.mathworks.com/matlabcentral/fileexchange/54976-mcsmatlabdatatools

function [TS,Date,Time,SaRa,EL_NAMES,EL_NUMS,rec_dur,fileinfo,nr_channel] = read_MCS_hd5_TS(filepath)
    
    % init
    TS=[];

    % open file 
    data=McsHDF5.McsData(filepath);

    % Trim whitespace and convert to numeric array
    C = data.Recording{1}.TimeStampStream{1}.Info.Label;
    A = cellfun(@str2double, strtrim(C));

    Date = data.Data.Date;
    Time = data.Recording{1,1}.TimeStamp;
    EL_NAMES=C;
    EL_NUMS=A;
    nr_channel=size(A,1);
    rec_dur = double(data.Recording{1,1}.Duration ./1000000);
    SaRa = 10000;
    fileinfo = {data.Data.MeaName};
    
    if ~isempty(data.Recording{1}.TimeStampStream)
        CELL=data.Recording{1}.TimeStampStream{1}.TimeStamps;
        TS = TS_Cell2M(CELL);
        TS = double(TS);
        TS = TS./1000000; % to seconds
        disp(['Loaded: ' filepath])
    end
end

            
            
            