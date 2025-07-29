% Convert an axion file *.spk to DrCell readable TS files (for each well a
% separate TS file is created)
%
% input:
% file_path: full path to the *.spk file
%
% output:
% no return arguments but a folder "TS" is created in "datapath" which
% contains the new *_TS.mat files
%
% Author: Manuel Ciba
% Date: 26.01.2024

function axion_spk2TS(file_path)
    
    % load all spike trains using the Axion lib
    Data = AxisFile(file_path).SpikeData.LoadData; 

    % get number of wells and electrodes (=channels)
    numWellRows = size(Data, 1);
    numWellCols = size(Data, 2);
    numElRows = size(Data, 3);
    numElCols = size(Data, 4);
    nr_channel = numElRows * numElCols;
    nr_wells = numWellRows * numWellCols;
    disp([num2str(nr_wells) '-well data'])

    % get meta data which is saved in any non-empty well 
    for i = 1:size(Data, 1)  % for Well Aj ... Dj
        for j= 1:size(Data, 2)  % for Well i1 ... i6
            for k = 1:size(Data,3)  % for electrode 1l ... 4l
                for l = 1:size(Data,4)  % for electrode k1 ... k4
                    if ~isempty(Data{i,j,k,l})
                        metadata = Data{i,j,k,l}(1).Source;
                    end
                end
            end
        end
    end

    % unpack metadata to DrCell variables
    rec_dur = metadata.Duration;
    SaRa = metadata.SamplingFrequency;
    fileinfo = metadata.Description;
    d = metadata.BlockVectorStartTime;
    Time = [num2str(d.Hour,'%02d') num2str(d.Minute,'%02d') num2str(d.Second,'%02d')];
    Date = [num2str(d.Year) num2str(d.Month,'%02d') num2str(d.Day,'%02d')];

    % Generate Well and Electrode names
    wellRowNames = arrayfun(@(x) char('A' + x - 1), 1:numWellRows, 'UniformOutput', false);
    wellColNames = arrayfun(@num2str, 1:numWellCols, 'UniformOutput', false);
    [rows, cols] = ndgrid(1:numElRows, 1:numElCols);
    EL_NAMES = arrayfun(@(r, c) [num2str(r) num2str(c)], rows, cols, 'UniformOutput', false);    
    EL_NUMS = rows * 10 + cols;
    EL_NAMES = EL_NAMES(:); % Convert to column vector
    EL_NUMS = EL_NUMS(:);   % Convert to column vector

    % get spike time stamps and store it in matrix TS
    TS = zeros(1, nr_channel);
    AMP = zeros(1, nr_channel);
    for i = 1:size(Data, 1)  % for Well Aj ... Dj
        for j= 1:size(Data, 2)  % for Well i1 ... i6
            idx_el = 0;  % init electrode index
            for k = 1:size(Data,3)  % for electrode 1l ... 4l
                for l = 1:size(Data,4)  % for electrode k1 ... k4
                    idx_el = idx_el + 1;
                    if ~isempty(Data{i,j,k,l})
                        time_stamps = [Data{i,j,k,l}(:).Start];
                        TS(1:length(time_stamps), idx_el) = time_stamps;
                        % get amplitudes for each spike from spike wave
                        % form (assumption: extreme value is spike)
                        for idx_spike = 1:size(time_stamps, 2)
                            metadata = Data{i,j,k,l}(idx_spike).Source;
                            max_amp = max(Data{i,j,k,l}(idx_spike).Data);
                            min_amp = min(Data{i,j,k,l}(idx_spike).Data);
                            if max_amp > abs(min_amp)
                                amp = max_amp;
                            else
                                amp = min_amp;
                            end
                            % convert to micro volt and save in matrix AMP
                            AMP(idx_spike, idx_el) = double(amp) * metadata.VoltageScale * 1000000;
                        end
                    end
                end
            end

            % save current TS of well ij to harddrive:

            % set all zeros to NaN
            AMP(AMP==0) = NaN;
            TS(TS==0) = NaN;
            
            % in case there are time stamps larger than rec_dur, delete these
            % time_stamps 
            AMP(TS > rec_dur) = NaN;
            TS(TS > rec_dur) = NaN;

            % only save file if at least one spike
            if any(any(~isnan(TS)))
                SPIKEZ = createStructure_SPIKEZ(TS,AMP,SaRa,rec_dur,fileinfo,nr_channel,Time,Date,EL_NAMES,EL_NUMS);
                wellName = [wellRowNames{i} wellColNames{j}];
                [root_path, file_name, ext] = fileparts(file_path);
                plate_id = regexp(file_name, 'Plate\d(?=\()', 'match', 'once');
                if ~isempty(plate_id)
                    folder = [root_path filesep 'TS' filesep wellName '_' plate_id];
                else
                    folder = [root_path filesep 'TS' filesep wellName];
                end
                if ~exist(folder, 'dir')
                   mkdir(folder)
                end
                file_path_new = [folder filesep Date '_' Time '_TS.mat'];
                saveSpikes(file_path_new, SPIKEZ);
                disp(['saved ' file_path_new])
            end


        end
    end
end
