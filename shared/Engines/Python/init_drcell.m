% Initializes DrCell by adding all DrCell folders to the MATLAB search
% paths.
% This is important to call DrCell functions from your own script.
%
% Authors: 
% Philipp Staigerwald
% Manuel Ciba

function init_drcell(drcell_path)

% remove old DrCell/Neuro/Cardio folder from search path
PathCell = textscan(path, '%s', 'Delimiter', pathsep);
PathCell = PathCell{1,1}; % unpack cell (as textscan was used);
for i=1:size(PathCell,1)
    if any(strfind(PathCell{i},'DrCell')) % remove all entries that contain string "DrCell"
        rmpath(PathCell{i});
    end
end

% Add all DrCell folder to matlab search path
% path_full = mfilename('fullpath'); % get path of this m-file (.../path/DrCell.m)
path_full = drcell_path; % path of the main-folder (.../path/DrCell.m)

[path_drcell,~] = fileparts(path_full); % separate path and m-file-name

p=genpath(path_drcell); % get path of all subfolders
addpath(p); % add to matlab search path

disp("DrCell is initialized")

end