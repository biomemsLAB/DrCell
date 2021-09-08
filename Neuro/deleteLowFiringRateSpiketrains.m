%% Delete all spike trains with less than 'FRmin' spikes per minute
% Input: SPIKES:    Timestamps of spikes (nth spike x recording electrode) (ZERO-PATTING)
%           AMP:    corresponding amplitude of the spike.
%           rec_dur:    recording duration of the file in seconds
%           FRmin:      minimum firing rate in spikes per minute

function [SPIKES, AMP]=deleteLowFiringRateSpiketrains(SPIKES,AMP,rec_dur,FRmin)

            SPIKES(isnan(SPIKES))=0;

            for n=1:size(SPIKES,2)
                if length(nonzeros(SPIKES(:,n)))<(FRmin*rec_dur/60)
                    SPIKES(:,n)=0;
                    AMP(:,n)=0;
                end
            end
            
            SPIKES(SPIKES==0)=NaN;
end