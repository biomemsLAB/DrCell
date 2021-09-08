% --- Open Files (sh-Kh)
    function openfiles(~,~)

        % 'Open file' - Window
        [file,path] = uigetfile({'*.mat','RAW or ST file (*.mat)'; ...
                                '*_RAW.mat','Raw data file (*_RAW.mat)'; ...
                                '*_ST.mat','Spiketrain file (*_ST.mat)'; ...
                                '*.bxr','ST file (*.bxr)'; ...
                                '*.brw','Raw data file (*.brw)'; ...
                                '*.*',  'All Files (*.*)'},'Select one File with raw data or spiketrains.','MultiSelect','off');
        if not(iscell(file)) && not(ischar(file)) % if canceled - dont do anything
            return
        end
        
        % get file extension 
        [~,~,ext] = fileparts(file); 
        
        % if .mat file is selected, load it directly
        if strcmp(ext,'.mat')
            openMatButtonCallback
        end
        % if .brw (HD-Raw) file is selected, load it directly
        if strcmp(ext,'.brw')
            ImportbrwFileCallback            
        end
        % if .bxr (HD-Spike) file is selected, load it directly
        if strcmp(ext,'.bxr')
            ImportbxrFileCallback  
        end
        
    end