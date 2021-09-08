% convert hdf5 (Multichannel Systems) to _RAW.mat (DrCell) file
% Note: you have to install the matlab toolbox provided by MCS to open hdf5
% files (can be downloaded online)

function RAW = MCS_hd5_2_RAW(filepath)
    
    % using the matlab toolbox provided by MCS to open hdf5 files (note:
    % you have to install it manually in order to use this function)
    % for more infos see: doc McsHDF5
    data=McsHDF5.McsData(filepath);
    
    Date = data.Data.Date;
    Time = data.Recording{1,1}.TimeStamp;
    
    EL_NAMES = data.Recording{1,1}.AnalogStream{1,1}.Info.Label;
    
    for n=1:size(EL_NAMES,1)
        EL_NUMS(n) = str2double(EL_NAMES{n});
    end

    M = data.Recording{1,1}.AnalogStream{1,1}.ChannelData' ./1000000; % from pV to µV
    rec_dur = double(data.Recording{1,1}.Duration ./1000000); % from µs to s
    SaRa = double(size(M,1)/rec_dur);
    T = 0: 1/SaRa: rec_dur -1/SaRa;
    fileinfo = {data.Data.MeaName};
    nr_channel = size(M,2);

    RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel);

end

            
            
            