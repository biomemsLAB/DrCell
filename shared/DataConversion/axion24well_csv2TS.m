% Convert an axion 24 well file *_spike_list.csv to DrCell readable TS files (for each well a
% separate TS file is created)
%
% input:
% file_path: full path to the *_spike_list.csv file
% rec_dur: the recording duration in seconds, since it is not included in
% _spike_list.csv
% SaRa: the sample rate in Hz, since it is not included in _spike_list.csv
%
% output:
% no return arguments but a folder "TS" is created in "datapath" which
% contains the new *_TS.mat files
%
% Author: Manuel Ciba
% Date: 13.12.2023

function axion24well_csv2TS(file_path, rec_dur, SaRa)

    [root_path, filename, ext] = fileparts(file_path);

    % read file
    T = readtable(file_path);
    C = table2cell(T);
    % TS in s: C{1,3}
    % Well_El: C{1,4}
    % AMP in mV: C{1,5}
    % TH factor: C{28,2}
    % Refactory time: C{32,2}
    % Rec_dur = ?
    % SaRa: C{5,2} = NaN

    % 1) Get all well names and el names
    for i = 1:size(C, 1)
        % if time stamp is not NaN, get well name
        if ~isnan(C{i, 3})
            wellNames{i} = C{i, 4}(1:2);
            elNames{i} = C{i, 4}(4:5);
        end
    end
    wellNamesUnique = unique(wellNames);
    elNamesUnique = unique(elNames);


    % for each well, generate SPIKEZ.TS und SPIKEZ.AMP und SPIKEZ.PREF
    for wellNameUnique = wellNamesUnique
        TS = zeros(1,length(elNamesUnique));
        AMP = zeros(1,length(elNamesUnique));
        for idx_elName = 1:size(elNamesUnique,2)
            elNameUnique = elNamesUnique(idx_elName);
    
            idx_spike = 0;
            for i = 1:size(C,1)
                ts = C{i, 3};  % time stamp in s
                amp = C{i, 5};  % amplitude in mV
                if ~isnan(ts)  % if time stamp is not NaN
                    wellName = C{i, 4}(1:2); % well name of current data
                    elName = C{i, 4}(4:5); % electrode, e.g. 12

                    if strcmp(wellName, wellNameUnique) && strcmp(elName, elNameUnique) % if data belongs to current well and electrode
                        idx_spike = idx_spike + 1;
                        TS(idx_spike, idx_elName) = ts;
                        AMP(idx_spike, idx_elName) = amp * 1000; % convert to uV
                    end
                end
            end
        end

        % set all zeros to NaN
        AMP(AMP==0) = NaN;
        TS(TS==0) = NaN;
        
        % in case there are time stamps larger than rec_dur, delete these
        % time_stamps 
        AMP(TS > rec_dur) = NaN;
        TS(TS > rec_dur) = NaN;

        %rec_dur = max(max(TS));
        %rec_dur = round(rec_dur / 60) * 60; % round the rec_dur to be a multiple of 60, e.g. 60, 120, 180...
        nr_channel = length(elNames);
        fileinfo = C(2,2);
        %SaRa = 18000.0;
        Time = C{4,2}(12:end);
        Date = C{4,2}(1:10);
        EL_NAMES = {'11','12','13','14','21','22','23','24','31','32','33','34','41','42','43','44'};
        EL_NUMS = [11 12 13 14 21 22 23 24 31 32 33 34 41 42 43 44];
        SPIKEZ = createStructure_SPIKEZ(TS,AMP,SaRa,rec_dur,fileinfo,nr_channel,Time,Date,EL_NAMES,EL_NUMS);
        
        folder = [root_path filesep 'TS' filesep wellNameUnique{1}];
        if ~exist(folder, 'dir')
           mkdir(folder)
        end
        
        % Convert to datetime object with the original format
        originalDate = datetime(Date, 'InputFormat', 'dd/MM/yyyy');
        % Convert to the desired format 'YYYYMMDD'
        formattedDate = datestr(originalDate, 'yyyymmdd');

        file_path = [folder filesep formattedDate '_' Time '_spike_list_TS.mat'];
        
        saveSpikes(file_path, SPIKEZ);
    end

end