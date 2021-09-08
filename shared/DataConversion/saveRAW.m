% RAW is renamed to "temp" as "temp" was used as name in past versions 

function saveRAW(temp, filepath)

    [path,filename,~]=fileparts(filepath);

    save([path filesep filename '_RAW.mat'], 'temp', '-v7.3'); % '-v7.3' flag needed for data greater than 2 GB

end