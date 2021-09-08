%% bin a sequence of events (e.g. time stamps of spikes)
% Input:    y: signal (e.g. time stamps)
%           rec_dur: recording duration of the timestamp file in seconds,
%           bin: binsize in seconds to discretize spiketrain
%           step: bin-step, if step==bin -> no overlap
%           flag_binary=1: frequencies can be only 0 or 1, flag_binary=0: normal mode
% Output:   y_binned:       binned signal
%           x_step:         corresponding x values (=bin center) of y_binned
%           edges_step:     edges of bins

function [y_binned,x_step,edges_step]=binning(y,rec_dur,binsize,step,flag_binary) 

    if binsize/step == 2 % if half overlap use faster function
        [y_binned,x_step,edges_step]=binning_halfOverlap(y,rec_dur,binsize,flag_binary);
    else
        %% Init
        edges_bin=0:binsize:rec_dur+step;           %   edges of bins without step
        x_bin=edges_bin(1:end-1) + binsize/2;       % center of bins without step

        numSteps=binsize/step;                      % number of steps per bin
        numBins=length(x_bin);                      % number of bins without step
        numEdges=length(edges_bin);
        temp_binned=zeros(numBins,numSteps);        % each row contains binned signal for another step
        temp_x=zeros(numBins,numSteps);             % temp_x containts corresponding x values for temp_binned
        temp_edges=zeros(numEdges,numSteps);        % contains corresponding edges for temp_binned

        %% 1) calc one histograms for each overlapping step. Bin-start is shiftet by "step" respectively.       
        for i=1:numSteps
            %edges=0+((i-1)*step):binsize:rec_dur+((i-1)*step);
            edges_nu = edges_bin+((i-1)*step);
            temp_x(:,i)= edges_nu(1:end-1) + binsize/2;
            temp_edges(:,i)= edges_nu;
            temp_binned(:,i)=histcounts(y,edges_nu);
        end

        %% 2) merge all histograms to one histogram
        y_binned=zeros(numSteps*numBins,1);         % final histogram
        x_step=zeros(numSteps*numBins,1);           % corresponding x values of final histogram
        edges_step=zeros(numSteps*(numBins+1),1);   % corresponding edges of final histogram
        for k=1:numSteps
            y_binned(k:numSteps:end)=temp_binned(:,k);
            x_step(k:numSteps:end)=temp_x(:,k);
            edges_step(k:numSteps:end)=temp_edges(:,k);
        end

        %% 1) new overlap binning method (faster)
        if 0
        edges=0:step:rec_dur;
        N = histcounts(y,edges);
        binSizeFactor= (binsize/step)/2;
        edges_step=edges;
        x_step=edges(1:end-1)+step;
        y_binned=N;
        for i=1:binSizeFactor
           y_binned(1:end-i)= y_binned(1:end-i) + y_binned(i+1:end); 
        end

        end

        %% 3) if flag_binary is true set all values >0 to 1
        if flag_binary
           y_binned(y_binned>0)=1; 
        end
    
    end

end