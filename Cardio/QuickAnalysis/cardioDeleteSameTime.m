% delete all spikes that occur "at the same time".
% Spikes occur at the same time if time difference <= dt
%
% MC, 08.10.2021

function [TS_nu,AMP_nu] = cardioDeleteSameTime(TS,AMP,dt)

% init
TS_nu = TS;
AMP_nu = AMP;

for n = 1:size(TS,2) % for all electrodes
    for m= n+1:size(TS,2) % for all other electrodes
        for i=1:length(nonzeros(TS(:,n)))
            for j=1:length(nonzeros(TS(:,m)))
                if abs(TS(i,n)-TS(j,m)) <= dt
                    TS_nu(i,n) = NaN;
                    TS_nu(j,m) = NaN;
                    AMP_nu(i,n) = NaN;
                    AMP_nu(j,m) = NaN; 
                end
            end
        end
    end
end

numDeletedSpikes = sum(isnan(TS_nu(:)));

% sorting
[TS_nu,AMP_nu] = zeroPadding(TS_nu,AMP_nu);


disp([num2str(numDeletedSpikes) ' spikes deleted because "at same time" (dt=' num2str(dt) ' s)'])

end