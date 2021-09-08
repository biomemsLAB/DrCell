function [H]=Entropy_ISI_call(TS,rec_dur,win) 
% TS: Timestamps of Spikes or Bursts, 
% rec_dur: recording duration of the timestamp file in seconds,
% win: time window size in seconds (bin<win<=rec_dur)
% bin: binsize in seconds to discretize spiketrain
% step: bin-step, if step==bin -> no overlap

% this function needs function "binning"

    % save prefs:
    H.PREF.rec_dur=rec_dur;
    H.PREF.win=win;


    % 0) split TS-file (length: rec_dur) into several files (length: win)
    TS_win=zeros(size(TS,1),size(TS,2),ceil(rec_dur/win));
    win_beg=0;
    win_end=win;
    for f=1:ceil(rec_dur/win) % number of temporary file
        for n=1:size(TS,2)
            mask=TS(:,n)>win_beg & TS(:,n)<=win_end;
            num_el = length(nonzeros(mask));
            TS_win(1:num_el,n,f)=TS(mask,n)-((f-1)*win);    
        end
        win_beg=win*f;
        win_end=win*(f+1);
    end
    

    for f=1:size(TS_win,3)
        
        % 1) calc ISIs + binning:
        ISI(:,:,f)=diff(TS_win(:,:,f));
        ISI(ISI<0)=0;
        logISI=log10(nonzeros(ISI(:,:,f))); % log10 + put all ISIs of all electrodes together (:,:,f)
        edges=log10(0.0001):0.1:log10(10);
        TS_binned(:,f)=histcounts(nonzeros(logISI),edges);
        

        % 2) call Entropy function:
        for n=1:size(TS_binned,2)
            H_M(n,f) = Entropy(TS_binned(:,n,f));
        end

        % 3) set nan-values to zero
        H_M(isnan(H_M))=0;
        % calc mean
        H.mean=mean(nonzeros(H_M(:,f)));
        H.std=std(nonzeros(H_M(:,f)));
    end
    
    % calc mean of temporary files
    H.mean=mean(H.mean);
    H.std=mean(H.std);
    for n=1:size(H_M,1)
        H.M(n)=mean(H_M(n,:));
    end
end