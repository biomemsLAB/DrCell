% convert hdf5 (Multichannel Systems) to _RAW.mat (DrCell) file
% Note: you have to install the matlab toolbox provided by MCS to open hdf5
% files (can be downloaded online)

function TS = MCS_hd5_2_TS(filepath)
    
    % using the matlab toolbox provided by MCS to open hdf5 files (note:
    % you have to install it manually in order to use this function)
    % for more infos see: doc McsHDF5
    data=McsHDF5.McsData(filepath);
    
    CELL=data.Recording{1}.TimeStampStream{1}.TimeStamps;
    
    TS = TS_Cell2M(CELL);
    TS = double(TS);
    TS = TS./1000000; % to seconds

end

            
            
            