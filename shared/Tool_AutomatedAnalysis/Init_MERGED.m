% --- Init Structure "MERGED" -----------------------------------
    function MERGED=Init_MERGED()
        % only at first time: 
        % make field
        if 1
            MERGED.TS = [];
            MERGED.AMP = [];
            MERGED.PREF.rec_dur = [];
        end 
    end