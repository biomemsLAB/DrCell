% reduce size of time stamp matrix by deleting inactive electrodes (MC)

function [CM2,CM_exh2,CM_inh2] = rearrangeElectrodePosition(CM,CM_exh,CM_inh,activeElIdx,nr_channel)

    CM2=zeros(nr_channel,nr_channel);
    CM_exh2=CM2;
    CM_inh2=CM2;
    
    CM2(activeElIdx,activeElIdx)=CM;
    CM_exh2(activeElIdx,activeElIdx)=CM_exh;
    CM_inh2(activeElIdx,activeElIdx)=CM_inh;

end