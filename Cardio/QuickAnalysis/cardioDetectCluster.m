function cardioDetectCluster(synchrony_matrix)
        pairs = [];
        idx1 = 1;
        for i = 1:size(synchrony_matrix,2)
            for j = i : size(synchrony_matrix,2)
                if synchrony_matrix(i,j) == 1
                    pairs(:,idx1)=[i,j];
                    idx1=idx1+1;
                end
            end
        end
        
        
        if isempty(pairs)
            disp('no synchronous pairs detected -> ANALYZE THIS DATA MANUALLY')
            return
        end
        
        % test if pairs are connected. if not than more than one cluster
        idx=1;
        flag = 0;
        for i=1:size(pairs,2)
            for j=1:size(pairs,2)
                if any(pairs(:,i) == pairs(:,j))
                    cluster1(idx)=pairs(1,i);
                    idx=idx+1;
                    cluster1(idx)=pairs(2,i);
                    idx=idx+1;
                else
                    flag=1;
                end
            end
        end
        
        if flag; disp('More than one cluster detected!'); end
    end