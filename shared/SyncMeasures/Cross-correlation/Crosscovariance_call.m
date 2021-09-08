function [CC]=Crosscorrelation_call(TS,rec_dur,win,bin,step,lag,binary) 
% TS: Timestamps of Spikes or Bursts, 
% rec_dur: recording duration of the timestamp file in seconds,
% win: time window size in seconds (bin<win<=rec_dur)
% bin: binsize in seconds to discretize spiketrain
% step: step of bin in seconds (no overlap if step==bin)
% lag: max lag in samples
% binary: false: normal binning, true: binary binning


    % ensure that bin<=win
    if bin > win
        bin=win;
    end
    
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
        
        % adaptive bin:
        if 0
            ISIs=diff(nonzeros(TS_win(:,:,f)));
           bin=median(ISIs(ISIs>0))
           step=bin;
        end
        
        % 1) binning:
        for n=1:size(TS,2)
            TS_binned(:,n,f)=binning(nonzeros(TS_win(:,n,f)),rec_dur,bin,step,binary);
        end
        
        % if lag == NaN set lag to default value
        if isnan(lag)
           lag = size(TS_binned,1)-1; 
        end
        
        % 2) call cross-correlation function:
        M=zeros(size(TS_binned,2));
        M(M==0)=NaN;
        CC.lag=M; CC.delay=M;
        for i=1:size(TS_binned,2)-1
            for j=i+1:size(TS_binned,2)
                if ~isempty(nonzeros(TS_binned(:,i,f))) && ~isempty(nonzeros(TS_binned(:,j,f)))
                    %[xcor,~]=xcorr(TS_binned(:,i,f),TS_binned(:,j,f),'coeff');
                    [xcor,xlag]=xcov(TS_binned(:,i,f),TS_binned(:,j,f),lag,'coeff');
                    %[xcor,~]=xcorr(TS_binned(:,i,f),TS_binned(:,j,f),lag,'coeff'); % coeff: normalization autocorr=1
                    %[xcor,~]=Crosscorrelation(TS_binned(:,i,f),TS_binned(:,j,f),lag); % crosscorrelation (MC) using correlation as in statistic book
                    M(i,j)=max(xcor);
                    [~,I] = max(abs(xcor));
                    
                    CC.lag(i,j)=xlag(I);
                    CC.delay(i,j)=xlag(I)*bin;
                end
            end
        end
        
        CC_M(:,:,f)=M;

        % 3) calculate mean and std
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