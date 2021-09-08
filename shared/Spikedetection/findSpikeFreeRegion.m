% this function finds spike free region of length "win" in a raw signal
% (=noise)
% (needed for threshold calculation)
% input:    M: raw signal (samples x electrodes
%           T: x axis (time in seconds, same length as samples of M)
%           SaRa:  sample rate of raw data in Hz
%           win: size of window in seconds (typically 0.05 s)
%           sigma: standard deviation that is considered spike free
%           (typically 5)
% output:   win_beg: begin of spike free region as array index (1 x electrodes)
%           win_end: end of spike free region as array index (1 x electrodes)


function [win_beg,win_end]=findSpikeFreeRegion(M,T,SaRa,win,sigma_max)
    
    win_beg=zeros(1,size(M,2));
    win_end=zeros(1,size(M,2));
    idx=win*SaRa;
    
    num_wins = floor(max(T)/win);
    for n=1:size(M,2)
        ibeg=1;
        iend=idx;
        i=1;
        sigma_tmp=0;
        while sigma_tmp>sigma_max && i<=num_wins
            [~,sigma_tmp] = normfit(M(ibeg:iend,n));
            ibeg=ibeg+idx;
            iend=iend+idx;
            i=i+1; % number of iterations
        end
        win_beg(1,n)=ibeg;
        win_end(1,n)=iend;
    end
    
    
end