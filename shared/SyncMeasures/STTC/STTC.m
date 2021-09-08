%% STTC - Spike Time Tiling Coefficient
% translation from original c code (comparison with python code of
% "elephant" package yields same STTC values) for given spike trains:
% STTC_mc2([1.3, 7.56, 15.87, 28.23, 30.9, 34.2, 38.2, 43.2], [1.02, 2.71, 18.82, 28.46, 28.79, 43.6], 50, 3)

function S = STTC(st1, st2, T, dt)
    
    % preprocessing (only use non-NaN Elements)
    st1 = st1(~isnan(st1));
    st2 = st2(~isnan(st2));
    
    % start of synchrony calculation
    if isempty(st1) || isempty(st2)
        S = NaN;
    else
       TA = run_T(st1, dt, T);
       TA = TA/T;
       TB = run_T(st2, dt, T);
       TB = TB/T;
       PA = run_P(st1, st2, dt);
       PA = PA/length(st1);
       PB = run_P(st2, st1, dt);
       PB = PB/length(st2);
       S = 0.5 * (PA-TB)/(1-TB*PA) + 0.5 *(PB-TA)/(1-TA*PB);
    end
       
    
    
    %% Nested functions
    function Nab = run_P(st1, st2, dt)
        N1 = length(st1);
        N2 = length(st2);
        
        Nab = 0;
        j=1;
        for i=1:N1
            while(j<=N2)
               if(abs(st1(i)-st2(j))<=dt)
                  Nab = Nab +1;
                  break
               elseif(st2(j)>st1(i))
                  break
               else
                  j=j+1;
               end
            end
        end
    end

    function time_A = run_T(st1, dt, T)
       N1 = length(st1);
       start = 0;
       tend = T;
       i=1;
       
       % maximum
       time_A = 2 * N1 * dt;
       
       % if just one spike in train
       if(N1==1)
          if(st1(1)-start)<dt
             time_A=time_A-start+st1(1)-dt; 
          elseif st1(1)+dt > tend
              time_A=time_A-st(1)-dt+tend;
          end
       
       
       % if more than one spike in train
       else
           while(i<=(N1-1))
               diff=st1(i+1)-st1(i);
               
               if diff < 2*dt
                  % substract overlap
                  time_A = time_A - 2 * dt + diff;
               end
               
               i=i+1;
           end
           
           % check if spikes are within dt of the start and/or end, if so just need to subract
           % overlap of first and/or last spike as all within-train overlaps have been accounted for
           if (st1(1)-start) < dt
              time_A=time_A-start+st1(1)-dt; 
           end
           
           if(tend-st1(N1) < dt)
              time_A = time_A-st1(N1)-dt+tend; 
           end
           
       end
       
       
    end

end