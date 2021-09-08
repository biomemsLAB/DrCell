%% get TS-Matrix with time stamps that are within a defined range t_beg to t_end
% input:    TS: Matrix containing time stamps in seconds, dim #maxSpikes x #electrodes
%           AMP: corresponding amplitudes in µV
%           t_beg: begin in seconds
%           t_end: end in seconds
% output:   TS: Matrix containing only time stamps in seconds within the defined range, dim #maxSpikes x #electrodes
%           AMP: corresponding amplitudes in µV

function [TS,AMP]=getTSwithinRange(TS,AMP,t_beg,t_end)
    
    TS(TS==0)=NaN;
    mask=TS<t_end & TS>=t_beg;
    TS(~mask)=NaN;
    AMP(~mask)=NaN;
    
    %% sort TS and AMP
    for n=1:size(TS,2)
        [TS(:,n), Index]=sort(TS(:,n));
        AMP(:,n)=AMP(Index,n);
    end
    
    %% set NaNs to zero
    TS(isnan(TS))=0;
    AMP(isnan(AMP))=0;
    
    %% delete rows that only contain zeros
    TS( ~any(TS,2), : ) = [];  
    AMP( ~any(AMP,2), : ) = [];  
    
    %% set zeros to NaN
    TS(TS==0)=NaN;
    AMP(AMP==0)=NaN;

end