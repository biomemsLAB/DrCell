%% DOES NOT WORK YET!!! (MC)

function B=burstIdleTime(B,idleTime)

    % idle time in seconds: delete Bursts that are closer than
    % idleTime to each other
    k=0;
    while k<=length(B.BEG)-2 
        k=k+1;
         if (B.BEG(k+1)-B.END(k)<idleTime) && (B.BEG(k+1)~=0)
             if B.SIB(k)<B.SIB(k+1) % only delete networkburst, if next networkburst is stronger or equal
                B.CORE((k):size(B.CORE,1)-1)=B.CORE((k+1):size(B.CORE,1));
                B.CORE(end)=0; 
                B.BEG((k):size(B.BEG,1)-1)=B.BEG((k+1):size(B.BEG,1));
                B.BEG(end)=0;
                B.END((k):size(B.END,1)-1)=B.END((k+1):size(B.END,1));
                B.END(end)=0;
                B.SIB((k):size(B.SIB,1)-1)=B.SIB((k+1):size(B.SIB,1));
                B.SIB(end)=0;
                B.BD((k):size(B.BD,1)-1)=B.BD((k+1):size(B.BD,1));
                B.BD(end)=0;
                %k=k-1; % because new burst is on position k
             % if SIB(k) >= SIB(k+1), delete SIB(k+1)
             else   
                B.CORE((k+1):size(B.CORE,1)-1)=B.CORE((k+2):size(B.CORE,1));
                B.CORE(end)=0; 
                B.BEG((k+1):size(B.BEG,1)-1)=B.BEG((k+2):size(B.BEG,1));
                B.BEG(end)=0;
                B.END((k+1):size(B.END,1)-1)=B.END((k+2):size(B.END,1));
                B.END(end)=0;
                B.SIB((k+1):size(B.SIB,1)-1)=B.SIB((k+2):size(B.SIB,1));
                B.SIB(end)=0;
                B.BD((k+1):size(B.BD,1)-1)=B.BD((k+2):size(B.BD,1));
                B.BD(end)=0;
                %k=k-1; % because new burst is on position k 
             end
         end
    end
    temp=nonzeros(B.CORE);
    B.CORE=temp;
    temp=nonzeros(B.BEG);
    B.BEG=temp;
    temp=nonzeros(B.END);
    B.END=temp;
    temp=nonzeros(B.SIB);
    B.SIB=temp;
    temp=nonzeros(B.BD);
    B.BD=temp;
            
end