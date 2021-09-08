function NB = networkburstdetection_mc(TS,rec_dur,fig)


    if nargin()==2
            fig=0; % show no figures by default
    end
    
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

        % load look up table that contains F_ratio values over number of spikes
        % per minute for uniform randomly distributed spiketrians.
        lut=load('networkburstdetection_mc_LUT');
        FRperMin=int32(length(nonzeros(TS))/rec_dur*60);
        border=lut.fx(FRperMin);

        % plot spiketrain(s)
        if fig
            %figure(1)
            %clf % clear current figure
            hs(1)=subplot(3,1,1);
            o=0.5;l=0; ROW=0;  
            for n=1:size(TS,2)
                if ~isempty(nonzeros(TS(:,n)))
                    ROW=ROW+1;
        %             for k=1:size(TS,1)
        %                 line([TS(k,n) TS(k,n)],[o+ROW l+ROW],'Color','black');
        %             end
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


        i=0; % bin iteration
        bin = rec_dur/2; % first bin size

        % calc all histograms
        while bin>0.01
            i=i+1;
            S(i).edges=0:bin:rec_dur;
            S(i).x = S(i).edges(1:end-1)+bin/2;
            S(i).hist=histcounts(nonzeros(TS),S(i).edges);
            S(1).bin(i)=bin;
            bin=bin/1.1;
        end


        % detect peaks for several thresholds
        for i=1:size(S,2)
            j=0;
            for th=max(S(i).hist) .* [0.1:0.1:0.5]
                j=j+1;
                S(1).bin_th(i,j)=th;
                [x,y]=detectSpikesFromThreshold(S(i).hist,th); % spikedetection
                numSpikes(i,j)=length(nonzeros(x));
    
                % show in figure
                if fig
                    hs(2)=subplot(3, 1, 2);
                    plot(S(i).x, S(i).hist); hold on
                    if x~=0 plot(S(i).x(x) ,y,'gx'); hold on; end % only show peak if there is a peak
                    plot([0 length(S(i).hist)].* S(1).bin(i),[th th],'g--'); hold off
                    hs(2).XLabel.String='t /s';
                    hs(2).YLabel.String='Spikes per bin';
                    linkaxes(hs(1:2),'x')

                    hs(3)=subplot(3, 1, 3);
                    plot(1:length(numSpikes),numSpikes,'x');
                    hs(3).XLabel.String='decreasing bin iteration';
                    hs(3).YLabel.String={'number of', 'detected peaks'};
                    %vari(i)=var(S(i).hist)/mean(S(i).hist);
                    %vari(i)=(max(S(i).hist)-min(S(i).hist))/std(S(i).hist);
                    %plot(1:length(vari),vari,'x'); 
                    pause(0.001); 
                end
            end

        end

        if max(max(numSpikes))>0     
            % choose best threshold (th with highest number of same elements
            for jj=1:size(numSpikes,2) % for each threshold value per histogram
                [pot_nNB(jj),pot_F(jj)]=mode(nonzeros(numSpikes(:,jj))); % potential number of networkbursts (nNB) and frequency (F)
            end

            if isnan(max(pot_nNB)) 
                pause(1); 
            end

            [~,j]=max(pot_F); % j: threshold index, choose index with highest frequency (=number of equal NBs)
            mask=pot_nNB(j)==pot_nNB(:); % th: j=1: lowest, j=end: highest; lowest gives better results, so choose lower th if nNB is the same
            j=min(find(mask));

            % number of networkbursts
            if ~isempty(j) nNB=pot_nNB(j); end
            F=length(nonzeros(numSpikes(:,j)==nNB));
            F_all = length(nonzeros(numSpikes(:,j)));
            F_ratio = F/F_all;

            % choose best bin (only for previously choosen threshold)
            bins=S(1).bin(numSpikes(:,j)==nNB);
            if ~isempty(bins) bin=bins(end); end
            i=find(S(1).bin==bin);

            th=S(1).bin_th(i,j);


            if F_ratio > border  % if less than 1% of all elements are equal elements (=NBs) do not detect spikes
                % decrease th as long as number of peaks does not change:
                %         z=length(x);
                [x]=detectSpikesFromThreshold(S(i).hist,th);
                z=x;
                while(z == length(x))
                    [z]=detectSpikesFromThreshold(S(i).hist,th);
                    th=th/1.01; % decrease th by 1% 
                end
                th=th*1.01;

                [x,y,begin,ending,duration,integral]=detectSpikesFromThreshold(S(i).hist,th);
                % output Parameter
                NB.BEG=S(i).x(begin)';
                NB.END=S(i).x(ending)';
                NB.CORE = S(i).x(x)';
                NB.SIB = integral';
                NB.BD = S(i).x(ending)'-S(i).x(begin)'; %duration .* S(1).bin(i); 
                NB.nNB=nNB;
                NB.F_ratio = F_ratio;
                NB.bin=bin;
                NB.th=th;


            else
                x=1; y=0;
            end

            if fig
                hs(2)=subplot(3, 1, 2);
                plot(S(i).x, S(i).hist); hold on
                plot(S(i).x(x) ,y,'x'); hold on
                plot([0 length(S(i).hist)].* S(1).bin(i),[th th],'g--'); hold off
                hs(2).XLim=[0 rec_dur];
                linkaxes(hs(1:2),'x')

                hs(2).XLabel.String='t /s';
                hs(2).YLabel.String='Spikes per bin';
                pause(0.01)
            end
        end

    end
    
    NB=BurstParameterCalculation(NB,rec_dur);
    

end