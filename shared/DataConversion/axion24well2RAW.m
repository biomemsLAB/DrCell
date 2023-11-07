% Convert an axion 24 well file containing raw data converted to a csv-file to DrCell readable RAW files (for each well a
% separate RAW file is created)
%
% input:
% fullpath: full path to the csv file
%
% output:
% no return arguments but a folder "RAW" is created in "datapath" which
% contains the new RAW.mat files
%
% Author: Manuel Ciba
% Date: 27.10.2023

function axion24well2RAW(fullpath)

    [filepath, filename, ext] = fileparts(fullpath);

    % read file
    T = readtable(fullpath);

    % get column names
    columnNames = T.Properties.VariableNames;
    % only use Well-Electrode names
    wellElNames = columnNames(2:end);
    % separate well and electrode names
    for i = 1:size(wellElNames,2)
        wellNames{i} = wellElNames{i}(1:2);
        elNames{i} = wellElNames{i}(3:4);
    end
    wellNamesUnique = unique(wellNames);
    elNamesUnique = unique(elNames);
    times = T.Time_s_;
    numEl = size(elNamesUnique,2);
    
    % for each unique well, generate RAW.M
    M = zeros(length(times),numEl);
    for wellNameUnique = wellNamesUnique
        % for each unique electrode, write a column into RAW
        for idx_elName = 1:numEl
            elNameUnique = elNamesUnique{idx_elName};
    
            % for all electrodes in the table, find the matching unique
            % well/electrdoe
            for i = 1:size(wellElNames,2)
 
                    wellName = wellNames{i}; % well name of current data
                    elName = elNames{i}; % electrode, e.g. 12
    
                    if strcmp(wellName,wellNameUnique) && strcmp(elName,elNameUnique) % if data belongs to current well and electrode (current = ...Unique)
                        M(:,idx_elName) = T{:,i+1}*1000000;  % first column is time, so i+1
                    end
            end
        end
    
        % add meta data to RAW structure
        rec_dur = round(times(end));
        nr_channel = numEl;
        fileinfo = {''};
        SaRa = 1/ (times(2) - times(1));
        Time = [];
        Date = [];
        EL_NAMES = {'11','12','13','14','21','22','23','24','31','32','33','34','41','42','43','44'};
        EL_NUMS = [11 12 13 14 21 22 23 24 31 32 33 34 41 42 43 44];
        RAW = createStructure_RAW(Date,Time,SaRa,EL_NAMES,EL_NUMS,M,times',rec_dur,fileinfo,nr_channel); % NOTE: in this script T is the table, not the time vector. The time vector is saved in "times"
        
        folder = [filepath filesep 'RAW'];
        if ~exist(folder, 'dir')
           mkdir(folder)
        end
        fullpathNew = [folder filesep filename '_' wellNameUnique{1}];
        
        saveRAW(RAW,fullpathNew);
    end
end