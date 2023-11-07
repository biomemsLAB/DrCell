clear all


%%%%%%%%%%%%%%%%%%%%%%%
% 1) ENTER THE PATH OF THE FOLDER WHICH CONTAINS THE CSV DATA
% 2) REMOVE ALL CSV DATA THAT DO NOT CONTAIN RAW DATA
datapath = '/home/mc/Desktop/FAUbox/Work/Projects/PSYNET/LSD-Data/Axion-Raw-csv/';
%%%%%%%%%%%%%%%%%%%%%%%


disp('Get filenames...')
files = dir(datapath);

% for all files, convert only the _spike_list.csv
for file_idx = 1:size(files,1)

    file = files(file_idx).name; 
    fullpath = [datapath file];
    [filepath,filename,ext] = fileparts(fullpath);

        if strcmp(ext, '.csv')  
            disp(['Converting file ' filename '...'])
            axion24well2RAW(fullpath);
        end
    

end

disp('Finished :)')

