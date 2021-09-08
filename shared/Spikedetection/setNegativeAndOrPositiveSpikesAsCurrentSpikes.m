% not used yet, has to be expanded to apply changes to amplitudes as well
% (if available)

function SPIKEZ=setNegativeAndOrPositiveSpikesAsCurrentSpikes(SPIKEZ,flag_neg,flag_pos)


if flag_neg && ~flag_pos
    SPIKEZ.TS=SPIKEZ.neg.TS;
    SPIKEZ.AMP=SPIKEZ.neg.AMP;
end
if flag_pos && ~flag_neg
    SPIKEZ.TS=SPIKEZ.pos.TS;
    SPIKEZ.AMP=SPIKEZ.pos.AMP;
end
if flag_neg && flag_pos
    SPIKEZ.TS=[SPIKEZ.neg.TS;SPIKEZ.pos.TS];
    SPIKEZ.AMP=[SPIKEZ.neg.AMP;SPIKEZ.pos.AMP];
    SPIKEZ.TS(SPIKEZ.TS==0)=NaN; % set zeros to NaN as "sort" consider NaN the biggest value
    SPIKEZ.AMP(SPIKEZ.AMP==0)=NaN;
    for n=1:size(SPIKEZ.neg.TS,2)  % SPIKES=nonzeros(SPIKES) would delete columns with only zero-values
        [SPIKEZ.TS(:,n), Index]=sort(SPIKEZ.TS(:,n));
        SPIKEZ.AMP(:,n)=SPIKEZ.AMP(Index,n);
    end
    SPIKEZ.TS(isnan(SPIKEZ.TS))=0;
    SPIKEZ.AMP(isnan(SPIKEZ.AMP))=0;
end
if ~flag_pos && ~flag_neg
    % just use current SPIKEZ.TS
end


end