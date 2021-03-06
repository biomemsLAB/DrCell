function distance = getEuclidianDistanceBetweenElectrodes(idx_el1,idx_el2,EL_NAMES, flag_60HDMEA) % returns distance in mm

if nargin < 4
    flag_60HDMEA = 1;
end

if ~flag_60HDMEA
    % get electrode name from index
    name_el1 = EL_NAMES{idx_el1};
    name_el2 = EL_NAMES{idx_el2};
    
    % calculate delta x and delta y in m
    el_pitch = 200E-6; % 200 µm electrode pitch
    dx = abs(str2double(name_el1(4)) - str2double(name_el2(4))) * el_pitch;
    dy = abs(str2double(name_el1(5)) - str2double(name_el2(5))) * el_pitch;
    
    distance = sqrt(dx*dx + dy*dy);
end

if flag_60HDMEA % MC
    % remap electrodes to 60HDMEA-Layout:
    EL_NUMS=[12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
    EL_NUMS_hd=[23 12 33 32 31 61 62 63 82 73 34 13 22 44 43 53 54 72 64 74 14 24 21 41 42 52 51 71 83 84 15 25 28 48 47 57 58 78 75 85 35 16 27 45 46 56 55 77 86 65 26 17 36 37 38 68 67 66 87 76];
    %[~,idx] = ismember(EL_NUMS,EL_NUMS_hd); % use this to remmap all electrodes at once. here not necessary so "find" is used
    el1 = EL_NUMS(idx_el1);
    el2 = EL_NUMS(idx_el2);
    new_idx_el1 = find(el1==EL_NUMS_hd);
    new_idx_el2 = find(el2==EL_NUMS_hd);
    % define pitch and layout as a 2D matrix (pitch 30µm, in middle 500 µm):
    matrix_x = [0, 30, 60, 90, 120, 500+0, 500+30, 500+60, 500+90, 500+120].*10^-6;
    matrix_x = repmat(matrix_x, 6, 1);
    matrix_y = [0, 30, 60, 90, 120, 150]'.*10^-6;
    matrix_y = repmat(matrix_y, 1, 10);
    % transpose matrix -> necessary for correct indexing with new_idx_el
    matrix_x = matrix_x';
    matrix_y = matrix_y';
    x1 = matrix_x(new_idx_el1);
    y1 = matrix_y(new_idx_el1);
    x2 = matrix_x(new_idx_el2);
    y2 = matrix_y(new_idx_el2);
    dx = abs(x1 - x2);
    dy = abs(y1 - y2);
    distance = sqrt(dx*dx + dy*dy);
end
end