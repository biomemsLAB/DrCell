% SBEdetection = detect synchronous BURSTS events

    function [SBE]=SBEdetection_old(BASE,T,SaRa,Th,idleTime)     % CN   % (BURSTS,T,SaRa,Th,idleTime)  
        
        %SI_EVENTS=zeros(size(BASE,2));
        SI_EVENTS=0;
        num_events=0;
        % init
        %SIB.BEG=0;
        %SIB.END=0;
        SIB.CORE=0;
        SIB.SIB=0;
        %SIB.BD=0;
        
        sync_time = int32(.04*SaRa);                    % time in which 2 spikes are considered parallel
        max_time = int32(.4*SaRa);
        wait_time = int32(idleTime*SaRa);
        
        ELECTRODE_ACTIVITY = zeros(size(T,2),size(BASE,2));
        ACTIVITY = zeros(1,length(T));
        
        for i = 1:size(BASE,2)                        % for each electrode...
            for j = 1:length(nonzeros(BASE(:,i)))     % for every Spike or Burst...
                pos = int32(BASE(j,i)*SaRa);
                
                if (pos>sync_time && pos<length(ACTIVITY)-sync_time)
                    ELECTRODE_ACTIVITY(pos-sync_time:pos+sync_time,i) = 1;
                end
            end
        end
        
        ACTIVITY = sum(ELECTRODE_ACTIVITY,2);
        
        clear ELECTRODE_ACTIVITY;
        
        i = 1; k = 1;
        while i <= length(ACTIVITY)
            if i+max_time < length(ACTIVITY)
                imax = i+max_time;
            else
                imax = length(ACTIVITY);
            end
            
            if ACTIVITY(i)>=Th
                [num,I] = max(ACTIVITY(i:imax));
                maxlength = 0;
                while ACTIVITY(i+I)==ACTIVITY(i+I+1)
                    maxlength = maxlength+1;
                    I = I+1;
                end
                I = I-int32(maxlength/2);
                SI_EVENTS(k,1) = T(i+I);              % ...safe in SI_EVENTS
                num_events(k,1) = num;
                k = k+1;
                i = i+I+wait_time;
            end
            i = i+1;
        end
        
        % save parameter in structure "SBE":
        SBE.CORE=SI_EVENTS;
        SBE.ACTIVITY=ACTIVITY;
        SBE.SIB=num_events;
        
    end

  
