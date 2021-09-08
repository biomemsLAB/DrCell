function Time_Amp = export_Time_amplitude(EL_NUMS,M,SPIKES,SaRa)

        clear Time adress Amplitude;

        Time(1,:) = EL_NUMS(1,:);
        Time(2:size(SPIKES,1)+1,:) = SPIKES;
        
        Amplitude(1,:) = EL_NUMS(:);
        SP = SPIKES*SaRa;
        for i = 1:size(SPIKES,2)
            adress = nonzeros(floor(SP(:,i)));
            if isempty(nonzeros(adress))
            else
                for j = 1:size(nonzeros(SPIKES(:,i)),1)
                    Amplitude(j+1,i) = min(M(adress(j)-2:adress(j)+2,i));
                end
            end
            adress = [];
        end
        if size(Time,2)<60
           EL_NUMS_full = [12 13 14 15 16 17 21 22 23 24 25 26 27 28 31 32 33 34 35 36 37 38 41 42 43 44 45 46 47 48 51 52 53 54 55 56 57 58 61 62 63 64 65 66 67 68 71 72 73 74 75 76 77 78 82 83 84 85 86 87];
           Time_full(1,:) = EL_NUMS_full;
           Time_full(2:size(Time,1),:)=zeros;
           Amplitude_full(1,:) = EL_NUMS_full;
           Amplitude_full(2:size(Time,1),:)=zeros;
           for i = 1:size(Time,2) 
               [~,nc]= find(EL_NUMS_full(:,:)==EL_NUMS(i));
               Time_full(:,nc) = Time(:,i);
               Amplitude_full(:,nc) = Amplitude(:,i);
           end
           Time_Amp = [Time_full,Amplitude_full];
        else
           Time_Amp = [Time,Amplitude];
        end
        
           temp = sortrows(Time_Amp',1)';
           clear Time_Amp
           Time_Amp = temp; 
                  
   end