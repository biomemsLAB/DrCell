
function [MI]=TransferEntropy_call(TS,rec_dur,win,bin,step,binary,norm) 
% TS: Timestamps of Spikes or Bursts, 
% rec_dur: recording duration of the timestamp file in seconds,
% win: time window size in seconds (bin<win<=rec_dur)
% bin: binsize in seconds to discretize spiketrain
% step: step of bin in seconds (no overlap if step==bin)
% binary: false: normal binning, true: binary binning
% norm=1: MI/min(H1,H2), norm=2: 2*MI/(H1+H2) -> norm=2 is more stable

    % ensure that bin<=win
    if bin > win
        bin=win;
    end

    % save prefs:
    MI.PREF.rec_dur=rec_dur;
    MI.PREF.win=win;
    MI.PREF.bin=bin;
    MI.PREF.step=step;
    MI.PREF.norm=norm;

    % 0) split TS-file (length: rec_dur) into several files (length: win)
    TS_win=zeros(size(TS,1),size(TS,2),ceil(rec_dur/win));
    win_beg=0;
    win_end=win;
    for f=1:ceil(rec_dur/win) % number of temporary file
        for n=1:size(TS,2)
            mask=TS(:,n)>win_beg & TS(:,n)<=win_end;
            num_el = length(nonzeros(mask));
            TS_win(1:num_el,n,f)=TS(mask,n)-((f-1)*win);
            
            % FR_min:
%             if length(nonzeros(TS_win(:,n,f)))< 6
%                 TS_win(:,n,f)=0;
%             end
        end
        win_beg=win*f;
        win_end=win*(f+1);
    end
    

    for f=1:size(TS_win,3)
        
        % 1) binning:
        for n=1:size(TS,2)
            TS_binned(:,n,f)=binning(nonzeros(TS_win(:,n,f)),rec_dur,bin,step,binary);
        end

        % 2) call TE function:
        M=zeros(size(TS_binned,2));
        M(M==0)=NaN;
        for i=1:size(TS_binned,2)
            for j=1:size(TS_binned,2)
                if ~isempty(nonzeros(TS_binned(:,i,f))) && ~isempty(nonzeros(TS_binned(:,j,f))) && i~=j
                    M(i,j)=TransferEntropy(TS_binned(:,i,f),TS_binned(:,j,f));
                else
                    M(i,j)=NaN;
                end
            end
        end
        
        MI_M(:,:,f)=M;

        % 3) 
        % set diagonal to NaN
        n=size(MI_M,1);
        temp=MI_M(:,:,f);
        temp(1:n+1:n*n) = NaN;
        MI_M(:,:,f)=temp;

        % 4) calculate mean and std
        MI_mean(f)=mean(nonzeros(MI_M(:,:,f)),'omitnan');
        MI_std(f)=std(nonzeros(MI_M(:,:,f)),'omitnan');
        
    end
    
    % calc mean of all temporary files
    MI.mean=mean(MI_mean);
    MI.std=mean(MI_std);
    for i=1:size(MI_M,1)
        for j=1:size(MI_M,2)
            MI.M(i,j)=mean(MI_M(i,j,:),'omitnan');
        end
    end
    
end