% Same as networkburstdetection_mc2 but with another bin-choice criteria
% (find bin size according to shimazaki et al)

function NB = networkburstdetection_mc3(TS,rec_dur,fig)


    if nargin()==2
        fig=0; % show no figures by default
    end
    
    % 0) number of active electrodes = n
    TS(TS==0)=NaN; % ACTUALLY NOT CORRECT!!!
    numActEl=sum(max(~isnan(TS))); % if no spikes on electrode, than every element is NaN
    
    % init Parameter
    NB.BEG=0;
    NB.END=0;
    NB.CORE=0;
    NB.SIB=0;
    NB.BD=0;
    NB.nNB=0;
    NB.F_ratio = 0;
    NB.bin=NaN;
    NB.th=NaN;
    
    if ~isempty(nonzeros(TS))

        % plot spiketrain(s)
        if fig
            %figure(1)
            %clf % clear current figure
            hs(1)=subplot(4,1,1);
            o=0.5;l=0; ROW=0;  
            for n=1:size(TS,2)
                if ~isempty(nonzeros(TS(:,n)))
                    ROW=ROW+1;
                      line ('Xdata',nonzeros(TS(:,n)),'Ydata', (ROW+0.25).*ones(1,length(nonzeros(TS(:,n)))),...
                                'LineStyle','none','Marker','.',...
                                'Color','black','MarkerSize',5);
                end
            end
            hs(1).YDir='reverse';
            hs(1).YTick=[];%[1+o/2:1:ROW+1];
            hs(1).TickLength=[0 1];
            hs.YLabel.String='Spiketrains';
            hs(1).XLabel.String='t /s';
            hs(1).XLim=[0 rec_dur];
            %hs.XTick=[0:10:rec_dur];
        end

        % TEST (use "optimal" bin size)
        bin=findOptimalBinSize(TS,rec_dur,0)
        %bin=0.0500;
        [hist,actEl,edges,x]=getNumSpikesAndActElPerBin(TS,rec_dur,bin);
        i=1;
        
        Sync_val= sum(actEl ./ numActEl) / length(nonzeros(hist)) % percent of bins that are active

        % show in figure
        if fig
            hs(2)=subplot(4, 1, 2);
            plot(x, hist); hold off
            %plot(S(i).x, [0 diff(S(i).hist)]); hold off
            hs(2).XLabel.String='t /s';
            hs(2).YLabel.String='Spikes per bin';
            hs(2).XLim=[0 rec_dur];
            linkaxes(hs(1:2),'x')

            hs(2)=subplot(4, 1, 3);
            plot(x, actEl); hold off
            %plot(S(i).x, [0 diff(S(i).hist)]); hold off
            hs(2).XLabel.String='t /s';
            hs(2).YLabel.String='Spikes per bin';
            hs(2).XLim=[0 rec_dur];
            linkaxes(hs(1:2),'x')
        end
       

        % try different thresholds
        th_max=max(hist);
        th_array=[0.01:0.01:0.5] * th_max;
        th=th_max*0.01;
        index=1;
        for th= th_array
            [X,Y]=detectSpikesFromThreshold(hist,th);
            numPeaks(index)=length(nonzeros(X));
            index=index+1;
        end
        % choose lowest th that shows most frequent number of peaks
        nNB=mode(numPeaks);
        th_index=min(find(nNB==numPeaks)); % find first index that has nNB peaks
        th=th_array(th_index);
        
        

        if 1 %p<= border  % if histogram values are not uniformly distributed (=random) than NBs are valid
            % decrease th as long as number of peaks does not change:
            %         z=length(x);
            [X]=detectSpikesFromThreshold(hist,th);
            z=X;
            while(z == length(X))
                [z]=detectSpikesFromThreshold(hist,th);
                th=th/1.01; % decrease th by 1% 
            end
            th=th*1.01;

            [X,Y,begin,ending,duration,integral,peakMask]=detectSpikesFromThreshold(hist,th);
            % output Parameter
            NB.BEG=x(begin)';
            NB.END=x(ending)';
            NB.CORE = x(X)';
            NB.SIB = integral';
            NB.BD = x(ending)'-x(begin)'; %duration .* S(1).bin(i); 
            NB.nNB=nNB;
            NB.bin=bin(i);
            NB.th=th;
            NB.Sync=Sync_val;


        else
            x=1; y=0;
        end

        if fig
            hs(2)=subplot(4, 1, 4);
            plot(x, hist); hold on
            plot(x(X) ,Y,'x'); hold on
            plot([0 length(hist)].* bin,[th th],'g--'); hold off
            hs(2).XLim=[0 rec_dur];
            linkaxes(hs(1:2),'x')

            hs(2).XLabel.String='t /s';
            hs(2).YLabel.String='Spikes per bin';
            pause(0.01)
        end
    end

    
    NB=BurstParameterCalculation(NB,rec_dur);
    

end