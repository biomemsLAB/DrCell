%% This function uses the synchrony measure from Sihn and Kim 
% Title of paper: A Spike Train Distance Robust to Firing Rate Changes Based on the Earth Mover’s Distance
% Year: 2020
%
% input:    TS: Timestamps of Spikes or Bursts, 
%           rec_dur: recording duration of the timestamp file in seconds,
%           flag_profile = 1: synchrony over time and matrix is also
%           calculated, 0: it is not calculated
% output:   Sync:   Sync.S:                 Synchrony index
%                   Sync.PREF:              preferences    
%           if flag_profile:
%                   Sync.PREF.P:            Profile => Sync.PREF.P.PlotProfileX(), Sync.PREF.P.PlotProfileY()
%                   Sync.PREF.M:            Synchrony Matrix   
%
% Dependency:
% d=fct_spikeDistance(g,f): this function has been provided by the authors of the paper (Shin and Kim)
%
% Author: Manuel Ciba
% Date: 01.12.2020

function [Sync]=SyncMeasure_EarthMoversDistance(TS) 


    %% 0) Init
    Sync.S=NaN;
    Sync.PREF.method='EarthMoversDistance';

    %% 1) Matrix to cell format (NaN-patting)
    % check data
    if size(TS,1)<2
       warning('File contains less than two spikes per spike train')
       return
    end
        
    % check data
    if size(TS,2)<2 
       warning('File contains only one spike train.')
       return 
    end
    
    TS(isnan(TS))=0; % zero padding is used.
    
    tic
    
    %% 2) Calc distance for each spike train pair 
    D=zeros(size(TS,2),size(TS,2));
    D(D==0)=NaN;
    for i=1:size(TS,2)-1
        for j=i+1:size(TS,2) % i+1: only calculate for half matrix, as matrix is symmetric
            d = fct_spikeDistance(nonzeros(TS(:,i)), nonzeros(TS(:,j))); % call original EMD function
            D(i,j)=d; % store in Matrix D
        end
    end
    
    %% 3) Synchrony = 0 - Distance
    S=0-mean(mean(D,'omitnan'),'omitnan'); % in order to get low values for low synchrony and vice versa, the distance is substracted from 0 (here 0 is used as the distance value does not have a high boundary such as the SPIKE-distance (values between 0 and 1))    
    
    t=toc; % calculation time

    %% 4) Save results in structure
    Sync.S=S;
    
    %% 6) save prefs:
    Sync.PREF.t=t; % calculation time
    
end