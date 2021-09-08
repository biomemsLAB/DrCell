% convert DrCell's EL_NAMES vector to x and y vectors. 
% E.g. EL_NAMES = 'EL 23' -> x=2, y=3

function [x,y] = EL_NAMES_2_xy(EL_NAMES)
    for i = 1:length(EL_NAMES)
        x(i) = str2num(EL_NAMES{i}(4));
        y(i) = str2num(EL_NAMES{i}(5));
    end
end