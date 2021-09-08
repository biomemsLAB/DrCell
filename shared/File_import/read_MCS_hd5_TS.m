% convert hdf5 (Multichannel Systems) to _RAW.mat (DrCell) file
% Note: you have to install the matlab toolbox provided by MCS to open hdf5
% files (can be downloaded online)
% https://de.mathworks.com/matlabcentral/fileexchange/54976-mcsmatlabdatatools

function TS = read_MCS_hd5_TS(filepath)
    
    % init
    TS=[];

    % using the matlab toolbox provided by MCS to open hdf5 files (note:
    % you have to install it manually in order to use this function)
    % for more infos see: doc McsHDF5
    data=McsHDF5.McsData(filepath);
    
    if ~isempty(data.Recording{1}.TimeStampStream)
        CELL=data.Recording{1}.TimeStampStream{1}.TimeStamps;
        TS = TS_Cell2M(CELL);
        TS = double(TS);
        TS = TS./1000000; % to seconds
        disp(['Loaded: ' filepath])
    end
end

            
            
            