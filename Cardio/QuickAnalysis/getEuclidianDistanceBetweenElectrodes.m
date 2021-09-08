function distance = getEuclidianDistanceBetweenElectrodes(idx_el1,idx_el2,EL_NAMES) % returns distance in mm
        
        % get electrode name from index
        name_el1 = EL_NAMES{idx_el1};
        name_el2 = EL_NAMES{idx_el2};
        
        % calculate delta x and delta y in m
        el_pitch = 200E-6; % 200 µm electrode pitch
        dx = abs(str2double(name_el1(4)) - str2double(name_el2(4))) * el_pitch;
        dy = abs(str2double(name_el1(5)) - str2double(name_el2(5))) * el_pitch;
        
        distance = sqrt(dx*dx + dy*dy);
    end
