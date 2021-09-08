function [CC]=Crosscorrelation_selinger_call(TS,rec_dur,win,bin,step,binary) % Selinger: (TS,rec_dur,30,0.5,0.5,true)
% TS: Timestamps of Spikes or Bursts, 
% rec_dur: recording duration of the timestamp file in seconds,
% win: time window size in seconds (bin<win<=rec_dur)
% bin: binsize in seconds to discretize spiketrain
% step: step of bin in seconds (no overlap if step==bin)
% binary: false: normal binning, true: binary binning

    % save prefs:
    CC.PREF.rec_dur=rec_dur;
    CC.PREF.win=win;
    CC.PREF.bin=bin;
    CC.PREF.step=step;

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

        % 2) call cross-correlation function:
        for i=1:size(TS_binned,2)
            for j=1:size(TS_binned,2)
                if ~isempty(nonzeros(TS_binned(:,i,f))) && ~isempty(nonzeros(TS_binned(:,j,f)))
                    CC_M(i,j,f)=Crosscorrelation_selinger(TS_binned(:,i,f),TS_binned(:,j,f)); 
                else
                    CC_M(i,j,f)=NaN;
                end
            end
        end

        % 3) set nan-values to zero
        %CC_M(isnan(CC_M))=0;
        % set diagonal to zero
        n=size(CC_M,1);
        temp=CC_M(:,:,f);
        temp(1:n+1:n*n) = NaN;
        CC_M(:,:,f)=temp;
        % set values under diagonal to zero
        CC_M(:,:,f)=triu(CC_M(:,:,f));
        CC_M(CC_M==0)=NaN;

        % 4) calculate mean and std
        CC_mean(f)=mean(nonzeros(CC_M(:,:,f)),'omitnan');
        CC_std(f)=std(nonzeros(CC_M(:,:,f)),'omitnan');
        
    end
    
    % calc mean of all temporary files
    CC.mean=mean(CC_mean);
    CC.std=mean(CC_std);
    for i=1:size(CC_M,1)
        for j=1:size(CC_M,2)
            CC.M(i,j)=mean(CC_M(i,j,:),'omitnan');
        end
    end
    
end