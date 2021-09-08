function NB = networkburstdetection_mc2(TS,rec_dur,fig)


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

        % load look up table that contains F_ratio values over number of spikes
        % per minute for uniform randomly distributed spiketrians.
        %lut=load('networkburstdetection_mc2_LUT');
        FRperMin=(length(nonzeros(TS))/rec_dur*60);
        %border=9e-06* FRperMin - 0.0027; % min border
        border=8.4e-05* FRperMin + 0.039; % mean border
        border=border*1.3;
        %border(border<0.05)=0.05;
        %border=lut.fx(FRperMin);

        % plot spiketrain(s)
        if fig
            figure
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
        
        ISI=diff(TS);
        ISImin = min(ISI(:));

        % calc all histograms
        while bin>ISImin*2 || bin>0.001
            i=i+1;
            
            [S(i).hist,S(i).actEl,S(i).edges,S(i).x]=getNumSpikesAndActElPerBin(TS,rec_dur,bin);
            
            S(1).bin(i)=bin;
            bin=bin*0.8;
        end


        %% calculate derivation of each histogram
        numSpikes = sum(S(1).hist); % number of all spikes
        for i=1:size(S,2)   
            derivation=diff(S(i).hist);
            %dif(i)=max(abs(derivation))/ max(S(i).hist); % derivation and normalized to max value
            
            if sum(S(i).hist) ~= 0
                derivation_coeff2(i)= (max((S(i).actEl))/numActEl);
                derivation_coeff3(i)=(sum(abs(derivation))/ (numSpikes*2)) ; % MC3: sum(|derivation|) / (2*#Spikes)

                derivation_coeff(i)=(sum(abs(derivation))/ (numSpikes*2)) * (max((S(i).actEl))/numActEl);
                
                S(i).actEl(S(i).actEl==1)=0; % set all bins with only one active el. to zero
                Sync_values(i)= sum(S(i).actEl ./ numActEl) / length(nonzeros(S(i).hist)) ; % sum(relative number of spikes on each el. per bin) / number of bins with spikes           
                
                %derivation_coeff(i)=std(S(i).hist)/max(S(i).hist);
                
                % derivation_coeff(i)= sum(S(i).actEl ./ numActEl) /
                % length(S(i).hist); % percent of bins that are active
            else
                derivation_coeff(i)=0;
            end
            
            
    
            % show in figure
            if fig
                hs(2)=subplot(3, 1, 2);
                plot(S(i).x, S(i).hist); hold off
                %plot(S(i).x, [0 diff(S(i).hist)]); hold off
                hs(2).XLabel.String='t /s';
                hs(2).YLabel.String='Spikes per bin';
                hs(2).XLim=[0 rec_dur];
                linkaxes(hs(1:2),'x')

                hs(3)=subplot(3, 1, 3);
                %plot(1:length(dif),dif,'x');                    
                %hs(3).XLabel.String='bin iteration';
                plot(S(1).bin(1:length(derivation_coeff)),derivation_coeff,'bx'); hold on % final curve
                plot(S(1).bin(1:length(derivation_coeff2)),derivation_coeff2,'k.'); % act el
                plot(S(1).bin(1:length(derivation_coeff3)),derivation_coeff3,'g.'); % deviation
                hs(3).XLabel.String='bin size in seconds';
                hs(3).XScale='log';
                hs(3).YLabel.String={'Coefficients'};
                pause(0.01); 
            end
        end

        if fig; legend('C','MaxActEl','Contrast'); end
        
        
        %% find peak (select index i of peak):
        [~,i]=(max(derivation_coeff));
        Sync_val=Sync_values(i);     
        if fig 
            hold on;
            plot(S(1).bin(i),Sync_val,'rx') % show peak position
        end
        
        %% Calculate for each electrode pair (bi-variate)
        M_sync=zeros(size(TS,2),size(TS,2));
        M_sync(M_sync==0)=NaN;
        for k=1:size(TS,2)-1
            for j=i+1:size(TS,2)
                [hist,actEl]=getNumSpikesAndActElPerBin(TS(:,[k,j]),rec_dur,S(1).bin(i)); % calc spikes per bin and act. el. considering only two electrodes
                actEl(actEl==1)=0; % if number of active el. is only 1, no synchronous event can appear, so set it to zero
                M_sync(k,j)= sum(actEl ./ 2) / length(nonzeros(hist)) ; % calculate sync value (same def. like in the multi-variate case but only with maximal 2 electrodes)
            end
        end
        
        % fit curve "derivation_coeff over bin-sizes"
        % only sigmoid without peak?
%         x_data=[1:length(derivation_coeff)]';
%         sigfunc = @(A, x)(1 ./ (1 + (x/A(1)).^(A(2))));
%         A0(1)=length(x_data)/2; % init value
%         A0(2)=1;
%         [A_fit,R,J]= nlinfit(x_data, derivation_coeff', sigfunc, A0);
%         border=sum(abs(R))
        
%         figure;
%         plot(x_data,derivation_coeff); hold on
%         plot(x_data,sigfunc(A_fit,x_data));

        % find middle peak
%         [y_peak,x_peak] = findpeaks(derivation_coeff); %findpeaks(fit7(x_data)); % find local maximum     
%         [max_dif,i_peak]=max(y_peak);
%         i=x_peak(i_peak);
        
        
        
        
        
        % TEST (use "optimal" bin size)
%         bin=findOptimalBinSize(TS,rec_dur,0)
%         [S(1).hist,S(1).actEl,S(1).edges,S(1).x]=getNumSpikesAndActElPerBin(TS,rec_dur,bin);
%         i=1;
        
        
        % NEW: choose best iteration from maximal derivation
        %i_array=(find(dif>=max(dif)*0.9));
        
%         [max_dif,i_array]=(max(derivation_coeff)); % MC3     
%         i=i_array(ceil(end/2)); % choose middle index
        
        %i=i_array(1); % choose first index
        % try different thresholds
        th_max=max(S(i).hist);
        th_array=[0.01:0.01:0.5] * th_max;
        th=th_max*0.01;
        index=1;
        for th= th_array
            [x,y]=detectSpikesFromThreshold(S(i).hist,th);
            numPeaks(index)=length(nonzeros(x));
            index=index+1;
        end
        % choose lowest th that shows most frequent number of peaks
        nNB=mode(numPeaks);
        th_index=min(find(nNB==numPeaks)); % find first index that has nNB peaks
        th=th_array(th_index);
        
        % calculate F_ratio
        CDF = cumsum(sort(S(i).hist)); % test if histogram values are normally distributed, if yes (p>0.05) -> noise
        Zn = CDF./max(CDF);
        Zn(Zn==0)= 1*10^-10;
        Zn(Zn==1)= 1- 1*10^-10;
        ADT=neuro_ADT(Zn);
        P = neuro_P(ADT);
        p=1-P; % if p < 0.05, null hypothesis is rejected -> data are not uniformly distributed
        %figure; histogram(nonzeros(TS))
        %F_ratio=mean(y) / mean(S(i).hist);
%         [x,y,~,~,~,~,peakMask]=detectSpikesFromThreshold(S(i).hist,th);
        
%         noise=mean(S(i).hist(~peakMask));
%         signal=mean(S(i).hist(peakMask));
%         F_ratio=signal/noise;
        
        %deviation=diff(S(i).hist);
        %dev=deviation(x);
        %F_ratio = dev./y; % if deviation of peak is as high as peak

        if 1 %p<= border  % if histogram values are not uniformly distributed (=random) than NBs are valid
            % decrease th as long as number of peaks does not change:
            %         z=length(x);
            [x]=detectSpikesFromThreshold(S(i).hist,th);
            z=x;
            while(z == length(x))
                [z]=detectSpikesFromThreshold(S(i).hist,th);
                th=th/1.01; % decrease th by 1% 
            end
            th=th*1.01;

            [x,y,begin,ending,duration,integral,peakMask]=detectSpikesFromThreshold(S(i).hist,th);
            % output Parameter
            NB.BEG=S(i).x(begin)';
            NB.END=S(i).x(ending)';
            NB.CORE = S(i).x(x)';
            NB.SIB = integral';
            NB.BD = S(i).x(ending)'-S(i).x(begin)'; %duration .* S(1).bin(i); 
            NB.nNB=nNB;
            NB.F_ratio = p;
            NB.bin=S(1).bin(i);
            NB.th=th;
            NB.Sync=Sync_val;
            NB.M = M_sync;


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

    
    NB=BurstParameterCalculation(NB,rec_dur);
    

end