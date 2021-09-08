%% bin a sequence of events (e.g. time stamps of spikes) with a bin overlap of 1/2*binSize
% Input:    y: signal (e.g. time stamps)
%           rec_dur: recording duration of the timestamp file in seconds,
%           bin: binsize in seconds to discretize spiketrain
%           flag_binary=1: frequencies can be only 0 or 1, flag_binary=0: normal mode
% Output:   y_binned:       binned signal
%           x_step:         corresponding x values (=bin center) of y_binned
%           edges_step:     edges of bins

function [y_binned,x_step,edges_step]=binning_halfOverlap(y,rec_dur,binsize,flag_binary) 



    %% 1) new overlap binning method (faster)
    step=binsize/2;
    edges_step=0:step:rec_dur;
    x_step=edges_step(1:end-1)+step;
    y_binned = histcounts(y,edges_step);
    y_binned(1:end-1)= y_binned(1:end-1) + y_binned(2:end); 

       
    %% 3) if flag_binary is true set all values >0 to 1
    if flag_binary
       y_binned(y_binned>0)=1; 
    end

end