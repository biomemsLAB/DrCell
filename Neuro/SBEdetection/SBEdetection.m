% SBEdetection = detect synchronous BURSTS events

function [SBE]=SBEdetection(BURSTS,rec_dur,SaRa,Th,idleTime)  % faster Algorithm (MC) % (BURSTS,rec_dur,SaRa,Th,idleTime)
        
        numberOFminEL=Th; % at least "Th" synchronous bursts have to occur to define a SBE
        BURSTS=BURSTS.*SaRa;
        sync_time = int32(0.04*SaRa); % +-40ms before and after burstbegin
        
        % init
        SBE.BEG=0;
        SBE.END=0;
        SBE.CORE=0;
        SBE.SIB=0;
        SBE.BD=0;
        
        % save prefs:
        SBE.PREF.rec_dur=rec_dur;
        SBE.PREF.sync_time=0.04;
        SBE.PREF.numberOfMinEl=Th;
        SBE.PREF.ildeTime=idleTime;
        
        if(size(nonzeros(BURSTS(1,:))) < numberOFminEL) % skip if there are less el with bursts than numberOFminEL
        else
            binary=zeros;
            %binary(1:SaRa*recTime)=0;
            for n=1:size(BURSTS,2)
                if ~isempty(nonzeros(BURSTS(:,n)))
                    for k=1:size(nonzeros(BURSTS(:,n)))
                        start=BURSTS(k,n)+1-sync_time; % +1: so array position can not be 0 (-1 later!)
                        if start<1 ,start=1; end
                        ende=BURSTS(k,n)+1+sync_time;
                        %if ende>=size(BURSTS,1) ende=size(BURSTS,1); end    
                        binary(int32(start):int32(ende),n)=1;
                    end
                end
            end

           SUM=sum(binary,2); % sum every element that is in the same column
           NB_pot=SUM>=numberOFminEL;
           
           % take maximum point as networkburst-timestamp
           % 1) set all values smaller than numberOfminEl to zero
           SUM(NB_pot==0)=0;

           if ~isempty(nonzeros(SUM))
               CORE=zeros(size(SUM));
               SIB=zeros(size(SUM));
               BEG=zeros(size(SUM));
               END=zeros(size(SUM));
               % find maximum of series surrounded by zeros
               for i=1:size(SUM)
                   if SUM(i)>0
                       k=0;
                       while(SUM(i+k)>0 && (i+k)<=size(SUM,1))
                           k=k+1;
                       end
                       k=k+i;
                       %index=int32((k-i)/2);
                      [maximum,index]=max(SUM(i:k));
                       CORE(i+index-1)=1;
                       SIB(i+index-1)=maximum;
                       BEG(i)=1;
                       END(k)=1;                   

                   end
               end

               % transform NB into timestamps
               k=0;
               for t=1:size(CORE,1)-1
                   if BEG(t)<BEG(t+1)
                       k=k+1;
                       SBE.BEG(k,1)=(t+1 -1)/SaRa; % -1: because of the offset (time 0 -> array position 1)
                   end
                   if CORE(t)<CORE(t+1)           
                       SBE.CORE(k,1)=(t+1 -1)/SaRa; % -1: because of the offset (time 0 -> array position 1)
                       SBE.SIB(k,1)=SIB(t+1); % here SIB is not spikes per burst but number of bursts per SBE
                   end
                   if END(t)<END(t+1)
                       SBE.END(k,1)=(t+1 -1)/SaRa; % -1: because of the offset (time 0 -> array position 1)
                   end
               end

               % calculate networkburstduration:
                for k=1:size(SBE.BEG,1)
                    SBE.BD(k,1)=SBE.END(k)-SBE.BEG(k);
                end

                % idle time in seconds: delete SBE that are closer than
                % idleTime to each other
                k=0;
                while k<=size(SBE.BEG,1)-2 
                    k=k+1;
                     if (SBE.BEG(k+1)-SBE.END(k)<idleTime) && (SBE.BEG(k+1)~=0)
                         if SBE.BD(k)<SBE.BD(k+1) % only delete networkburst, if next networkburst is longer or equal
                            SBE.CORE((k):size(SBE.CORE,1)-1)=SBE.CORE((k+1):size(SBE.CORE,1));
                            SBE.CORE(end)=0; 
                            SBE.BEG((k):size(SBE.BEG,1)-1)=SBE.BEG((k+1):size(SBE.BEG,1));
                            SBE.BEG(end)=0;
                            SBE.END((k):size(SBE.END,1)-1)=SBE.END((k+1):size(SBE.END,1));
                            SBE.END(end)=0;
                            SBE.SIB((k):size(SBE.SIB,1)-1)=SBE.SIB((k+1):size(SBE.SIB,1));
                            SBE.SIB(end)=0;
                            SBE.BD((k):size(SBE.BD,1)-1)=SBE.BD((k+1):size(SBE.BD,1));
                            SBE.BD(end)=0;
                            k=k-1; % because new burst is on position k
                         else % if BD(k) >= BD(k+1), delete BD(k+1)
                            SBE.CORE((k+1):size(SBE.CORE,1)-1)=SBE.CORE((k+2):size(SBE.CORE,1));
                            SBE.CORE(end)=0; 
                            SBE.BEG((k+1):size(SBE.BEG,1)-1)=SBE.BEG((k+2):size(SBE.BEG,1));
                            SBE.BEG(end)=0;
                            SBE.END((k+1):size(SBE.END,1)-1)=SBE.END((k+2):size(SBE.END,1));
                            SBE.END(end)=0;
                            SBE.SIB((k+1):size(SBE.SIB,1)-1)=SBE.SIB((k+2):size(SBE.SIB,1));
                            SBE.SIB(end)=0;
                            SBE.BD((k+1):size(SBE.BD,1)-1)=SBE.BD((k+2):size(SBE.BD,1));
                            SBE.BD(end)=0;
                            k=k-1; % because new burst is on position k 
                         end
                     end
                end
                temp=nonzeros(SBE.CORE);
                SBE.CORE=temp;
                temp=nonzeros(SBE.BEG);
                SBE.BEG=temp;
                temp=nonzeros(SBE.END);
                SBE.END=temp;
                temp=nonzeros(SBE.SIB);
                SBE.SIB=temp;
                temp=nonzeros(SBE.BD);
                SBE.BD=temp;

           end
        end
       % Calculate other parameter like "mean burst duration"
        SBE=BurstParameterCalculation(SBE,rec_dur);

end