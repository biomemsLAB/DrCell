function [TS,AMP] = cardioDeleteElectrodes(TS,AMP,idx_el)

    if ~isnan(idx_el)
        TS(:,idx_el) = 0;
        AMP(:,idx_el) = 0;
        numDeletedElectrodes = length(idx_el);
        
    else
        numDeletedElectrodes = 0;
    end
        
        disp([num2str(numDeletedElectrodes) ' electrodes deleted']) 
    end