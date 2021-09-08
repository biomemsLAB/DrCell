%% STTC - Spike Time Tiling Coefficient
% TA: the proportion of total recording time which lies +- dt of any spike
% from A. TB calculated similarly.


function STTC = STTC_mc(A, B, T, dt)
    
    if isempty(A) || isempty(B)
        STTC = NaN;
    else
        [TA, tstart_A, tend_A] = get_TX(A,T,dt);

        [TB, tstart_B, tend_B] = get_TX(B,T,dt);

        PB = get_PX(tstart_A, tend_A, B);
        PA = get_PX(tstart_B, tend_B, A);

        STTC = 0.5 * ((PA-TB)/(1-PA*TB) + (PB-TA)/(1-PB*TA));
    end

   
   
    
    %% Nested functions
    function [TA, tstart, tend] = get_TX(A,T,dt)
        j = 0;
        for i=1:length(A) % for every spike
            j=j+1; 
            tstart(j) = A(i) - dt;
            tend(j) = A(i) + dt;
            
            if i+1 <= length(A)
                while tend(j)>=A(i+1)
                   i=i+1; % skip next spikes if they lie inside the current interval
                   tend(j) = A(i) + dt;
                   if (i+1) > length(A)
                      break; 
                   end
                end   
            end
        end
        
        tstart(tstart<0)=0;
        tend(tend>T)=T;
        
        Tsum=0;
        for i=1:length(tstart)
            Tsum = Tsum + tend(i) - tstart(i);
        end
        
        TA = Tsum / T;
        
    end

    function PA = get_PX(tstart_B, tend_B, A)
        PA = 0;
        for i=1:length(tstart_B)
            PA = PA + any(A(tstart_B(i) <= A & tend_B(i) >= A));
        end
        PA = PA / length(A);
    end


end