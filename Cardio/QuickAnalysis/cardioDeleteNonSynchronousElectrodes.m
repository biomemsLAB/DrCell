function [TS,AMP] = cardioDeleteNonSynchronousElectrodes(TS,AMP, synchrony_matrix)
        
        disp('delete asynchronous electrodes:')
        
        idx1 = 1;
        idx2 = 1;
        pairs_valid = [];
        pairs_unvalid = [];
        for i = 1:size(synchrony_matrix,2)
            for j = i:size(synchrony_matrix,2)
                if synchrony_matrix(i,j) == 1
                    pairs_valid(:,idx1)=[i,j];
                    idx1=idx1+1;
                elseif synchrony_matrix(i,j) > 0 && synchrony_matrix(i,j) < 1
                    pairs_unvalid(:,idx2)=[i,j];
                    idx2=idx2+1;
                end
            end
        end
        
        if isempty(pairs_valid)
            disp('no synchronous pairs detected -> ANALYZE THIS DATA MANUALLY')
            %return
        end
        
        el_valid = unique(pairs_valid);
        el_unvalid = unique(pairs_unvalid);
        
        % electrodes that are within "unvalid" and does also are within
        % "valid" are valid. electrodes that are within "unvalid" and not
        % in "valid" are unvalid -> delete them
        el_toDelete = setdiff(el_unvalid,el_valid);
        
        [TS,AMP] = cardioDeleteElectrodes(TS,AMP,el_toDelete);

    end