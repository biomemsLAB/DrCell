% this function transforms all NaNs into zeros.
%
% values are sorted and zero rows are deleted


function [TS,AMP]=nanPadding(TS,AMP)

if ~isempty(TS)
    
    % 1) all zeros to NaNs
    AMP(AMP==0)=NaN;
    TS(TS==0)=NaN;

    % 2) sorting
    [TS, idx] = sort(TS);
    for n=1:size(idx,2)
        AMP(:,n) = AMP(idx(:,n),n);
    end

    % 4) deleting all zero rows
    AMP(isnan(TS))=0;
    TS(isnan(TS))=0;
    AMP( ~any(TS,2), : ) = [];  % clear rows that only contain zeros
    TS( ~any(TS,2), : ) = [];  % clear rows that only contain zeros
    AMP(AMP==0)=NaN;
    TS(TS==0)=NaN;

end

end