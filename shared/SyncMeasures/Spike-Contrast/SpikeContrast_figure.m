%% Measure synchrony of spike train data (by Manuel Ciba, August 2016)
% input:    TS: time stamps of spikes in seconds, 
%               input as matrix (dim: maxNumOfSpikesPerEl x numOfElectrodes)
%               matrix should be filled with NaN if no spike exists
%           rec_dur: recording duration in seconds
%           binStepFactor (optional): binStep = binSize/binStepFactor
%           (default = 2)
%           fig (optional): if 1: show plots, if 0: hide plots (default=0)
%           rec (optional): if 1: record and save video (default=0)
% output:   Sync:   Sync.S: synchrony index
%                   Sync.bin: bin size where synchrony reaches its maximum
%           hs:     handle array of three subplots (only if fig=1)
%
% needed functions:     [AllSpikesPerBin,actElPerBin,edges,xvalues]=getNumSpikesAndActElPerBin(TS,rec_dur,bin);


function [Sync,C,MeanActiveEl,Contrast,bins,hs] = SpikeContrast_figure(TS,rec_dur,binStepFactor,fig,rec)
    
    TS(TS==0)=NaN; % force NaN padding
    TS=sort(TS);
    
    tic

    if nargin==2 % Default values
        binStepFactor=2; % binStep = binSize/2 -> one overlap
        fig=0; % 1: show plot, 0: hide plot
        rec=0;
    end
    
    if nargin==3 % Default values
        fig=0; % 1: show plot, 0: hide plot
        rec=0;
    end
    
    if nargin==4 % Default values
        rec=0; 
    end
    
    %% PARAMETER
    binShrinkFactor=0.9; % decrease of the bin size in each iteration
    
    % first (=max) bin size
    firstBin=rec_dur/2; % old: firstBin=min([rec_dur/2, 30]) -> too restrictive!
    
    % min bin size
    ISI=diff(TS);
    ISImin= min(min(ISI));
    minBin=max([ISImin/2, 0.001]);
        
%     if fig % if figure mode use smallest ISI as minBin, otherwise use spikerate as this is faster
%         ISI=diff(TS);
%         ISImin= min(min(ISI));
%         minBin = ISImin; % old: minBin=max([ISImin 0.01]);
%     else 
%         minBin = rec_dur / size(TS,1); % maximal spike rate
%     end
    

    if minBin < 0
        error('negative time stamps not allowed')
    end
    
    if firstBin <= minBin
        minBin=firstBin/100;
    end
    
    %% 0) number of active electrodes = n
    numActEl=sum(max(~isnan(TS))); % if no spikes on electrode, than every element is NaN

    
    % plot spiketrains
    if fig
        hf=figure(1);
        %hf.Units='centimeters';
        %hf.Position=[0 0 12 12]; 
        if rec; hf.Position=[0 0 800 400]; end
        hs(1)=subplot(3,1,1);
        hs(1)=plotSpikeTrain(TS,hs(1),'line');
        hs.YLabel.String='Spiketrains';
        hs(1).XLabel.String='time in seconds';
        hs(1).XLim=[0 rec_dur];
    else
        hs=NaN;
    end
    
    
    %% 1) Bin TS 
    % init:
    j=1;
    bin = firstBin; % first bin size
    bins(j)=bin;
    while bin>minBin %|| length(bins)<10 % create different bin sizes until bin underruns minBin and at least 10 bins are selected
       j=j+1;
       bin=bin*binShrinkFactor;
       bins(j)=bin;
    end
    
    S(int8(j))=struct();
    S(1).numActEl=numActEl; % save numActEl into structure after initialization of S
    MeanActiveEl=zeros(j,1);
    Contrast=zeros(j,1); % 
    C=zeros(j,1); % C = cost function = MaxActiveEl * Contrast
    
    % calc all histograms
    i=0; % bin iteration
    numSpikes = sum(~isnan(TS(:))); % number of all spikes
    for bin=bins
        
        %% Calculate Histogram
        i=i+1;

        step = bin/binStepFactor; % bin step
        %[S(i).hist,S(i).actEl,S(i).edges,S(i).x]=getNumSpikesAndActElPerBin(TS,rec_dur,bin,step);
        %time_start = -ISImin;
        %time_end = rec_dur+ISImin;
        time_start = -ISImin;
        time_end = rec_dur+ISImin;
        [S(i).hist,S(i).actEl,S(i).edges,S(i).x]=f_SC_get_Theta_and_n_perBin(TS,time_start,time_end,bin);
        
        %[S(i).hist,S(i).x,S(i).edges]=boxcar(nonzeros(TS(:)),rec_dur,1/100,bin,0); 
        %S(i).actEl=S(1).numActEl; % avoid this parameter

        S(1).bin(i)=bin;
        
        %% Calculate Costfuction = contrast * maxActEl
        N=S(1).numActEl;
        if sum(S(i).hist) ~= 0 % if histogram is not empty
            
            %MeanActiveEl(i)= (mean(nonzeros(S(i).actEl))/N); % #MeanActiveEletrodesPerNonzeroBin / #activeElectrodesOfChip
            MeanActiveEl(i)= sum(S(i).actEl.*S(i).hist)/sum(S(i).hist) /N; % (#actElPerBin * #spikesPerBin) / #allSpikes = weighted meanActiveEl
            MeanActiveEl(i)= (MeanActiveEl(i)*N-1)/(N-1); % normalize range from [1/numActEl,1] to [0,1]
            Contrast(i)=(sum(abs(diff(S(i).hist)))/ (numSpikes*2)) ; % Contrast: sum(|derivation|) / (2*#Spikes)
            C(i)=Contrast(i) * MeanActiveEl(i); % Cost function
            
            
            %C(i)= (C(i)*N-1)/(N-1); % normalize range from [1/numActEl,1] to [0,1]

            %S(i).actEl(S(i).actEl==1)=0; % set all bins with only one active el. to zero
        end
        
        %% show in figure
        if fig
            hs(2)=subplot(3, 1, 2);
            stairs(S(i).x - S(1).bin(i)/2, S(i).hist./max(S(i).hist)); hold off
            hs(2).XLabel.String='time in seconds';
            hs(2).YLabel.String={'rel. Spikes'  'per bin'};
            hs(2).XLim=[0 rec_dur];
            box off
            %linkaxes(hs(1:2),'x')
            

            hs(3)=subplot(3, 1, 3);
            plot(S(1).bin(1:length(C(1:i))),C(1:i),'-k'); hold on % final curve 'bo'
            plot(S(1).bin(1:length(MeanActiveEl(1:i))),MeanActiveEl(1:i),'--b'); % act el 'k.'
            plot(S(1).bin(1:length(Contrast(1:i))),Contrast(1:i),'-.g'); % contrast 'g.'
            hold off
            hs(3).XLabel.String='bin size in seconds';
            hs(3).XScale='log';
            hs(3).YLabel.String={'Coefficients'}; 
            hs(3).YLim=[0,1];
            hs(3).XLim=[min(bins),max(bins)];
            box off
            
            
            % record
            if rec
                hf.Color=[1 1 1]; 
                hl=legend('C','ActiveST','Contrast');
                hl.Location='eastoutside';              
                F(i)=getframe(hf);   
            else
                pause(0.05)
            end
            
        end
        
    end
    

    if fig && ~rec; hl=legend('C','ActiveST','Contrast'); hl.Location='eastoutside'; end
    
    %% 2) Sync value is maximum of cost function C
    Sync.S= max(C);
    Sync.PREF.firstBin=firstBin;
    Sync.PREF.lastBin=minBin;
    Sync.PREF.binStepFactor=binStepFactor;
    Sync.PREF.rec_dur=rec_dur;
    Sync.PREF.t=toc; % calculation time
    
    %% plot 
    if fig 
        hold on;
        [~,i]=max(C);
        plot(S(1).bin(i),Sync.S,'rx') % show peak position
        text(S(1).bin(i)*1.2,Sync.S,['S=' num2str(Sync.S,'%1.2f')]) % 1.2f -> one number before ., two numbers after .
        
        % update 2nd plot to optimal bin size
        axes(hs(2))
        stairs(S(i).x- S(i).x(1) , S(i).hist./max(S(i).hist));
        hs(2).XLim=[0 rec_dur];
        hs(2).XLabel.String='time in seconds';
        hs(2).YLabel.String={'rel. Spikes'  'per bin'};
        box off
        
        %stairs(S(i).x- S(i).x(1) , S(i).hist./max(S(i).hist)); hold on
        % add relative number of active electrodes per bin
        %stairs(S(i).x- S(i).x(1), S(i).actEl./ S(1).numActEl);
        % add lenged
        %legend('rel. # spikes', 'rel. # act. el.')
        
        %fig=figure();
        %fig.Units='centimeters';
        %fig.Position=[0 0 12 12];
        if rec
            tmp=getframe(hf);
            F(end+1:end+50)=tmp; % last frame repeated
            v = VideoWriter('newfile.avi');
            v.FrameRate=30/4; % 4 times slower than default
            open(v)
            writeVideo(v,F)
            close(v)
        end
    end

    
        
end