%% Plot time stamps as raster plot
% input:    TS:         matrix that contains time stamps in seconds of all electrodes (dim: MaxNumSpikes x NumElectrodes)
%           AMP:        amplitudes in ÂµV corresponding to TS (same structure like TS)
%           h:          handle of an existing subplot
%           mode:       'dot': each spike represented as dot, 'line' each spike represented as vertical line
%           flag_allEl: 0: only electrodes with spikes are plotted, 1: all electrodes are plotted
% output:   h:          handle of raster plot

function h=plotSpikeTrain_Color(TS,AMP,h,mode,flag_allEl)

    if nargin == 2
        figure;
        h=subplot(1,1,1);
        mode = 'dot';
        flag_allEl = 1;
    end
    
    if nargin == 3
        mode = 'dot';
        flag_allEl = 1;
    end
    
    if nargin == 4
        flag_allEl = 1;
    end
    
    axes(h); % make h current axes

    o=0.5;l=0; 
    ROW=0;  
    maxAMP=max(max(abs(AMP),[],'omitnan'),[],'omitnan');
    minAMP=min(min(abs(AMP),[],'omitnan'),[],'omitnan');
    %AMP(abs(AMP)>maxAMP)=maxAMP;
    for n=1:size(TS,2)
        
        disp(['Plot electrode ' num2str(n) ' of ' num2str(size(TS,2))])
        
        if flag_allEl; ROW=ROW+1; end % use this line if all channels should be plotted
        
        if ~isempty(nonzeros(TS(:,n))) && any(~isnan(TS(:,n)))
            
            if ~flag_allEl; ROW=ROW+1; end % use this line if no empty channels should be plotted

            if strcmp(mode,'line_HQ') % each spike is displayed as line (slow)
                for k=1:sum(~isnan(TS(:,n)))
                    amp=abs(AMP(k,n));
                    amp=amp-minAMP; % delete offset
                    amp=maxAMP-amp; % invert
                    if amp >= maxAMP/2 % green to yellow
                       color=[1-(amp-maxAMP/2)/maxAMP,1,0]; 
                    else % yellow to red
                       color=[1,amp/maxAMP,0]; 
                    end
                    color(isnan(color))=0;
                    line([TS(k,n) TS(k,n)],[o+ROW l+ROW],'Color',color); hold on
                end
            end 

            if strcmp(mode,'dot')
                Y=zeros(size(TS,1),1);
                S=5; % area of each point (not used when marker is specified in scatter-function)
                Y(:)=ROW; % value of Y Axis
                hp=scatter(TS(:,n),Y,S,AMP(:,n),'filled'); hold on
                hp.SizeData=2; % marker size
                % add colorbar:
                caxis([-60 0])
                colorA=[0 1 0]; % large amp
                colorB=[0 1 1];
                colorC=[0 0 1]; 
                colorD=[0 0 0]; % small amp
                cmap=get_cmap(colorA, colorB, colorC, colorD);
                colormap(h,cmap)
                %colormap(hs(1),'winter')
            end
            if strcmp(mode,'dot_ColorBar')
                Y=zeros(size(TS,1),1);
                S=5; % area of each point (not used when marker is specified in scatter-function)
                Y(:)=ROW; % value of Y Axis
                hp=scatter(TS(:,n),Y,S,AMP(:,n),'filled'); hold on
                hp.SizeData=2; % marker size
                % add colorbar:
                if n==size(TS,2) % add colorbar at last loop
                    caxis([0 100])
                    colorA=[0 1 0]; % large amp
                    colorB=[0 1 1];
                    colorC=[0 0 1]; 
                    colorD=[0 0 0]; % small amp
                    hc=colorbar;
                    hc.Label.String = {'Spike amplitude', 'in µV'};
                    cmap=get_cmap(colorD, colorC, colorB, colorA);
                    colormap(h,cmap)
                    %colormap(hs(1),'winter')
                end
            end

        end
    end
    h.YDir='reverse';
    h.YTick=[];%[1+o/2:1:ROW+1];
    h.TickLength=[0 1];
    h.YLabel.String='Spiketrains';
    h.YLim=[1 size(TS,2)+1];
    h.XLabel.String='time';
    %h.XLim=[0 rec_dur];
    %hs.XTick=[0:10:rec_dur];
end