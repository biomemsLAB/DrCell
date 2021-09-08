%% Convert cell to matrix (NaN-padding)

function M=TS_Cell2M(C)
    
    for i=1:length(C)
        M(1:length(C{i}),i)=C{i};
    end
    
    M(M==0)=NaN;
end