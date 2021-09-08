%% Plot time stamps as raster plot
% input:    TS:         matrix that contains time stamps in seconds of all electrodes (dim: MaxNumSpikes x NumElectrodes)
%           h:          handle of an existing subplot
%           mode:       'dot': each spike represented as dot (default), 'line' each spike represented as vertical line
%           flag_allEl: 0: only electrodes with spikes are plotted, 1: all
%                       electrodes are plotted (default)
% output:   h:          handle of raster plot

function h=plotSpikeTrain(TS,h,mode,flag_allEl)

    if nargin == 1
        figure;
        h=subplot(1,1,1);
        mode = 'dot';
        flag_allEl = 1;
    end
    
    if nargin == 2
        mode = 'dot';
        flag_allEl = 1;
    end
    
    if nargin == 3
        flag_allEl = 1;
    end
    
    TS=sort(TS);
    
    o=0.0;l=0.75; 
    ROW=0;  
    %tic
    for n=1:size(TS,2)
        
        disp(['Plot electrode ' num2str(n) ' of ' num2str(size(TS,2))])
        
        if flag_allEl; ROW=ROW+1; end % use this line if all channels should be plotted
        
        if ~isempty(nonzeros(TS(:,n))) && any(~isnan(TS(:,n)))
            
            if ~flag_allEl; ROW=ROW+1; end % use this line if only active channels should be plotted

            if strcmp(mode,'line_HQ') % each spike is displayed as line (slow)
                for k=1:sum(~isnan(TS(:,n)))
                    line([TS(k,n) TS(k,n)],[o+ROW l+ROW],'Color','black');
                end
            end
            
            if strcmp(mode,'line') % each spike is displayed as line (fast)
                x=nonzeros(TS(:,n));
                y=(ROW).*ones(1,length(nonzeros(TS(:,n))));
                resolution=0.01;
                LineLength=l/resolution;
                pixel=0;
                for k=1:LineLength    
                    line ('Xdata',x,'Ydata', y+pixel, 'LineStyle','none','Marker','.','Color','black','MarkerSize',1);
                    pixel=pixel+resolution;
                end
            end

            if strcmp(mode,'dot') % each spike is displayed as dot (fast)
                  line ('Xdata',nonzeros(TS(:,n)),'Ydata', (ROW+0.25).*ones(1,length(nonzeros(TS(:,n)))),...
                            'LineStyle','none','Marker','.',...
                            'Color','black','MarkerSize',5);
            end

        end
    end
    
    h.YDir='reverse';
    h.YTick=[];%[1+o/2:1:ROW+1];
    h.TickLength=[0 1];
    h.YLabel.String=[{'Spike'} {'trains'}];
    h.YLim=[0.75 ROW+1];
    h.XLabel.String='Time in seconds';
    h.XLim=[0 ceil(max(TS(:)))];
    %hs.XTick=[0:10:rec_dur];
    %toc
end