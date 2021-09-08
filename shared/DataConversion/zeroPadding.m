% this function transforms all NaNs into zeros.
%
% values are sorted and zero rows are deleted


function [TS,AMP]=zeroPadding(TS,AMP)

% 1) all zeros to NaNs (needed for sorting)
AMP(AMP==0)=NaN;
TS(TS==0)=NaN;

% 2) sorting
for n=1:size(TS,2)
    [TS(:,n), idx] = sort(TS(:,n));
    AMP(idx,n) = AMP(:,n);
end

% 3) all NaNs to zeros
AMP(isnan(TS))=0;
TS(isnan(TS))=0;

% 4) deleting all zero rows
AMP( ~any(TS,2), : ) = [];  % clear rows that only contain zeros
TS( ~any(TS,2), : ) = [];  % clear rows that only contain zeros



end