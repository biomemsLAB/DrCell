% get x y coordinates from the electrode names (=Lables)
% normal mode: 8x8 matrix, 60 electrodes
% HDmode: 60x60 matrix, 4069 electrodes

function [x,y]=get_X_Y_CoordinatesFromMeaLayout(EL_NAMES,HDmode)

if nargin<2
    HDmode=0; % default value: normal mode (60 electrodes, 8x8 Matrix)
end

if HDmode == 1
    for i=1:length(EL_NAMES)
        idx_beg = strfind(EL_NAMES{i},':');
        idx_end = strfind(EL_NAMES{i},',');
        x(i)=str2num(EL_NAMES{i}(idx_beg+1:idx_end-1)); % first number: x axis (from : to ,)
        y(i)=str2num(EL_NAMES{i}(idx_end+1:end)); % second number: y axis (from , to end)
    end
else
    for i=1:length(EL_NAMES)
        x(i)=str2num(EL_NAMES{i}(4)); % first number: x axis
        y(i)=str2num(EL_NAMES{i}(5)); % second number: y axis
    end
end

end