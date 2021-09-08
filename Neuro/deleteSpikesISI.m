function SPIKEZ=deleteSpikesISI(SPIKEZ,ISI_max,nTimes)
    SPIKE=SPIKEZ.TS;
    
    for i=1:nTimes
       SPIKE(SPIKE==0)=NaN;
       deletedSpikes=zeros(1,60);
       for n=1:size(SPIKE,2)
           if ~isempty(nonzeros(SPIKE(:,n)))
              for k=1:size(nonzeros(SPIKE(:,n)),1)-2
                  if SPIKE(k+1,n)-SPIKE(k,n) > ISI_max
                      if SPIKE(k+2,n)-SPIKE(k+1,n) > ISI_max 
                          SPIKE(k+1,n)=NaN; % delete spike k+1 if time to pre-spike and post-spike is more than ISI_max
                          deletedSpikes(n)=deletedSpikes(n)+1;
                      end
                  end
              end
           end
       end
       SPIKE=sort(SPIKE);
       SPIKE(isnan(SPIKE))=0;
    end
    
    SPIKEZ.TS=SPIKE;
end