% reduce size of time stamp matrix by deleting inactive electrodes (MC)

function [TS_reduced, activeElIdx] = reduceTSsize(TS)

        TS(isnan(TS))=0;
        TS_reduced=[];
        activeElIdx=[];

        j=0;
        for i=1:size(TS,2)
           if sum(TS(:,i))~=0 % if electrode is not inactive
               j=j+1;
               TS_reduced(:,j)=TS(:,i);
               activeElIdx(j) = i;
           end        
        end
        
        if isempty(TS_reduced)
           TS_reduced=TS; 
           activeElIdx=1:size(TS,2);
        end
        
end