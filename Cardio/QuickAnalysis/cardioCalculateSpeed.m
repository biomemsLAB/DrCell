function [velocity_airline,velocity_min_mean,velocity_max_mean,velocity_mean_mean] = cardioCalculateSpeed(SPIKEZ,numSpikeColumns)

if nargin < 2
    numSpikeColumns = size(SPIKEZ.TS,1);
end

% init
velocity_airline = NaN;
velocity_min_mean = NaN;
velocity_max_mean = NaN;
velocity_mean_mean = NaN;

if numSpikeColumns > 0 % velocity only can be calculated if there is any spike column
    
    EL_NAMES = SPIKEZ.PREF.EL_NAMES;
    nr_channel = size(SPIKEZ.TS,2);
    
    
    for i=1:numSpikeColumns % for each "spike column"
        spikeColumn = zeros(size(SPIKEZ.TS,2),1); % init, important here
        for n=1:size(SPIKEZ.TS,2)
            spikeColumn(n) = SPIKEZ.TS(i,n);
        end
        spikeColumn(spikeColumn==0) = NaN;
        
        % --------------------------
        % calculate velocity (airline): last spike - first spike
        [firstSpike, idx_el_first] = min(spikeColumn);
        [lastSpike, idx_el_last] = max(spikeColumn);
        distance = getEuclidianDistanceBetweenElectrodes(idx_el_first,idx_el_last,EL_NAMES);
        delayTime = lastSpike - firstSpike;
        velocity_airline(i) = distance / delayTime;
        
        
        %delays(:,i) = SpikeColumn - firstSpike; % delay relative to the first spike
        %disp(['Spike-column nr. ' num2str(i) ' has a maximum delay of ' num2str(max(delays(:,i))) ' seconds and a median of ' num2str(median(delays(:,i),'omitnan'))])
        
        
        if ~SPIKEZ.PREF.sixwell % skip if six well mode, the neighboring electrode velocity calculation does not work yet.
            
            % --------------------------
            % calculate velocity between all neighboring electrodes: start with first spike
            idx_current = idx_el_first;
            
            % assign spikes to MEA layout resulting in a 8x8 matrix
            [xx,yy] = EL_NAMES_2_xy(EL_NAMES);
            xx(xx==0)=1; yy(yy==0)=1; % replace zeros with dummy value (relevant for sixwell MEAs)
            for idx_el = 1:nr_channel
                spikeColumn_matrix(yy(idx_el),xx(idx_el)) = spikeColumn(idx_el);
            end
            spikeColumn_matrix(spikeColumn_matrix==0)=NaN;
            %[dx,dy]=gradient(spikeColumn_matrix); % or better use diff since results from gradient are wired
            
            pitch = 200E-6;
            velo_min = zeros(size(spikeColumn_matrix));
            velo_min(velo_min==0)=NaN;
            velo_max=velo_min;
            numEl = size(spikeColumn_matrix,2);
            for yy = 1:numEl
                for xx = 1:numEl
                    velo = [NaN, NaN, NaN, NaN];
                    if xx+1 <= numEl % neighbor to the right
                        velo(1)=pitch/(spikeColumn_matrix(yy,xx) - spikeColumn_matrix(yy,xx+1));
                    end
                    if yy+1 <= numEl % neighbor to the bottom
                        velo(2)=pitch/(spikeColumn_matrix(yy,xx) - spikeColumn_matrix(yy+1,xx));
                    end
                    if yy+1 <= numEl && xx+1 <= numEl % neighbor to the right bottom diagonal
                        velo(3)=sqrt(pitch*pitch+pitch*pitch)/(spikeColumn_matrix(yy,xx) - spikeColumn_matrix(yy+1,xx+1));
                    end
                    if yy-1 > 0 && xx+1 <= numEl % neighbor to the right top diagonal
                        velo(4)=sqrt(pitch*pitch+pitch*pitch)/(spikeColumn_matrix(yy,xx) - spikeColumn_matrix(yy-1,xx+1));
                    end
                    
                    
                    velo_min(yy,xx) = min(abs(velo),[],'omitnan');
                    velo_max(yy,xx) = max(abs(velo),[],'omitnan');
                    velo_mean(yy,xx) = mean(abs(velo),'omitnan');
                end
            end
            velo_min(velo_min==inf)=NaN;
            velo_max(velo_max==inf)=NaN;
            velo_mean(velo_mean==inf)=NaN;
            
            velocity_min_mean(i) = mean(mean(velo_min,'omitnan'),'omitnan');
            velocity_max_mean(i) = mean(mean(velo_max,'omitnan'),'omitnan');
            velocity_mean_mean(i) = mean(mean(velo_mean,'omitnan'),'omitnan');
            
            %             % calculate velocity between consecutive spikes
            %             [spikeColumn_sorted, idx] = sort(spikeColumn);
            %             idx(isnan(spikeColumn)) = []; % delete nan values
            %             electrodeOrder{i} = EL_NUMS(idx);
            %             delays = diff(spikeColumn_sorted); % delay between consecutive spikes
            %             delays(isnan(delays))=[]; % delete nan values
            %             for ii = 1:length(delays)-1
            %                 idx_el_a = idx(ii);
            %                 idx_el_b = idx(ii+1);
            %                 distance = getEuclidianDistanceBetweenElectrodes(idx_el_a,idx_el_b);
            %                 velocity_consecutive(i,ii) = distance / delays(ii);
            %             end
        end
    end
    
end

end