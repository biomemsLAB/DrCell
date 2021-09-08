function synchrony_matrix=cardioPairwiseSynchrony(SPIKEZ,rec_dur)
        nr_channel = size(SPIKEZ.TS,2);
        synchrony_matrix = zeros(nr_channel,nr_channel); % init
        for i = 1:size(SPIKEZ.TS,2)
            for j = i+1:size(SPIKEZ.TS,2)
                [synchrony_matrix(i,j)] = SpikeContrast([SPIKEZ.TS(:,i),SPIKEZ.TS(:,j)],rec_dur, 0.1);
            end
        end
             
    end