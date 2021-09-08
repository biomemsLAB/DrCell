% SBEdetection = detect synchronous BURSTS events

function [SBE]=SBEdetection(BURSTS,rec_dur,SaRa,Th,idleTime)  % faster Algorithm (Sh.Kh) % (BURSTS,rec_dur,SaRa,Th,idleTime)
        
        numberOFminEL=Th; % at least "Th" synchronous bursts have to occur to define a SBE 
        BURSTS=BURSTS.*SaRa;
        sync_time = int32(0.04*SaRa); % +-40ms before and after burstbegin 
        
        % init
        SBE.BEG=0; % Beginning of SBE 
        SBE.END=0; % End of SBE
        SBE.CORE=0; % Core of SBE , When the center is an interval, the end of the range is considered
        SBE.SIB=0; % Maximum number of Bursts in a SBE
        SBE.BD=0; % Network burst duration
        
        % save prefs:
        SBE.PREF.rec_dur=rec_dur; 
        SBE.PREF.sync_time=0.04;
        SBE.PREF.numberOfMinEl=Th;
        SBE.PREF.ildeTime=idleTime;
        
        
% % ---------shiva Mit Vektorisieren---------------        
tic
        if(size(nonzeros(BURSTS(1,:))) < numberOFminEL) % skip if there are less el with bursts than numberOFminEL
        else 
        binary=zeros;
           for n=1:size(BURSTS,2)
                if ~isempty(nonzeros(BURSTS(:,n)))  %only if electrode contains burst
                    for j=1:size(nonzeros(BURSTS(:,n))) 
                        start=BURSTS(j,n)+1-sync_time; % +1: so array position can not be 0 (-1 later!)
                       
                        if start<1 
                           start=1; 
                        end
                        ende=BURSTS(j,n)+1+sync_time;
%                         if ende>=size(BURSTS,1) ende=size(BURSTS,1); end    
                        binary((start):(ende),n)=1;
                    end 
                end
            end % Shiva  harche tedad EL ha bishtar bashad in marhale bishtar tul mikeshad
         SUM=sum(binary,2); % sum every element that is in the same column
toc   
% %--------------------end--------------        

           
% % ---------------shiva mit Vekt + parfor------------------
% tic
%      if(size(nonzeros(BURSTS(1,:))) < numberOFminEL) % skip if there are less el with bursts than numberOFminEL
%         else 
%         SUM=zeros;
%             parfor n=1:size(BURSTS,2)
%                 if ~isempty(nonzeros(BURSTS(:,n)))  %only if electrode contains burst
%                   a=BURSTS(:);
%                     m=(max(a))+1-sync_time;
%                     binary=zeros(m+(2*sync_time),1);
%                     for j=1:size(nonzeros(BURSTS(:,n))) 
%                        start=BURSTS(j,n)+1-sync_time;
%                         if start<1 
%                            start=1;
%                         end
%                          ende=BURSTS(j,n)+1+sync_time;
%                         if ende>=size(BURSTS,1) ende=size(BURSTS,1); end    
%                         binary(start:start+sync_time)=1;
%                     end 
%                     SUM=SUM+binary;%  sum every element that is in the same column
%                 end
%             end % Shiva  harche tedad EL ha bishtar bashad in marhale bishtar tul mikeshad
% toc
%  %-----------end----------------
%  
 
           NB_pot=SUM>=numberOFminEL;
           
           % take maximum point as networkburst-timestamp
           % 1) set all values smaller than numberOfminEl to zero
           SUM(NB_pot==0)=0;
           SUMK =find(SUM~=0);
           SUMK(:,2)=nonzeros(SUM);
           Sn=0; %SBE number
           for i=1:size(SUMK)
                   if i>1 
                   i=k+1;
                   end
                   k=0;
                   while (SUMK(i+k,1)==SUMK(i+k+1,1)-1 && (i+k+1)<size(SUMK,1))
                       k=k+1;                        
                   end % shiva harche SaRa bozorgtar bashad in marhale bishtar tul mikeshad chon andazeye SUM bozorgtar mishavad
                       Sn=Sn+1;
                       k=k+i;
                       SBE.BEG(Sn,1)=(SUMK(i,1)-1)/SaRa;  
                       SBE.END(Sn,1)=SUMK(k,1)/SaRa;  
                       SBE.SIB(Sn,1)=max(SUMK(i:k,2));  
%                        [index]=max(SUMK(i:k,:)); 
                       [maximum,index]=max(SUMK(i:k,2));
                       core=find(SUMK(i:k,2)==maximum);
                       for m=1:(size(core,1)-1)
                           if (core(m)+1)==core(m+1)
    %                        m=m+1;
                           else
                               if (core(m)+1)<core(m+1)
                               index=core(m+1);
        %                        m=m+1;
                               end
                           end
                       end
                        SBE.CORE(Sn,1)=(SUMK(i+index)-2)/SaRa;
%                        SBE.CORE(Sn,1)=(index(1)-1)/SaRa;               
                       i=k+1;
                   if(i==size(SUMK,1))
                        break;
                    end
            end
                        
              
                for k=1:size(SBE.BEG,1) 
                    SBE.BD(k,1)=SBE.END(k)-SBE.BEG(k);% calculate networkburstduration
                end

                % idle time in seconds: delete SBE that are closer than idleTime to each other
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
               
                SBE.CORE=nonzeros(SBE.CORE); 
                SBE.BEG=nonzeros(SBE.BEG);
                SBE.END=nonzeros(SBE.END);
                SBE.SIB=nonzeros(SBE.SIB);
                SBE.BD=nonzeros(SBE.BD);

        end
              
       % Calculate other parameter like "mean burst duration"
       SBE=BurstParameterCalculation(SBE,rec_dur); 

end