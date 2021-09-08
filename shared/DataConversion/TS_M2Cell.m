%% Convert matrix (NaN-padding) to cell

function C=TS_M2Cell(M)
    
    for i=1:size(M,2)
        tmp=M(:,i);
        C{i}=tmp(~isnan(tmp))'; % transpose the data so one cell has the format 1xNumSpikes (needed for cSPIKE)
    end
    
end