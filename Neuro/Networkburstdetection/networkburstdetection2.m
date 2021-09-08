function [NETWORKBURSTS,AllSpikesPerBin,actElPerBin,Product,numberOFbins,Th]=networkburstdetection2(SPIKES,AMP,rec_dur,bin,idleTime)
            %ThDecide = str2num(cell2mat(inputdlg('enter 0 or 1 (0: fixed Threshold, 1: flexible Threshold)')));        
            ThDecide=1;
            
            % init
            NETWORKBURSTS.BEG=0;
            NETWORKBURSTS.END=0;
            NETWORKBURSTS.CORE=0;
            NETWORKBURSTS.SIB=0;
            NETWORKBURSTS.BD=0;
            
            % save prefs:
            NETWORKBURSTS.PREF.rec_dur=rec_dur;
            NETWORKBURSTS.PREF.bin=bin;
            NETWORKBURSTS.PREF.idleTime=idleTime;
           
            
           % divide all spiketrains into bins   
           xvalues=(bin/2):bin:rec_dur-bin/2; % xvalues are center of bin -> Offset of bin/2 so bin starts at zero
           for n=1:size(SPIKES,2)
               SPIKEHISTOGRAM(:,n)=hist(nonzeros(SPIKES(:,n)),xvalues);
           end
           if size(SPIKEHISTOGRAM,1)==1 % in case only one El is active the size of hist would be [1,numberOfbins]
               SPIKEHISTOGRAM=SPIKEHISTOGRAM';
           end           
           numberOFbins=size(SPIKEHISTOGRAM,1);
           
           % Calculate sum(Amplitudes/bin)
           AMPHISTOGRAM=zeros(size(SPIKEHISTOGRAM));
           for n=1:size(AMP,2)
               for i = 1:numberOFbins
                   binS = bin * (i-1);
                   binE = bin * i;
                   mask=(SPIKES(:,n)> binS) & (SPIKES(:,n)<=binE);
                   AMPHISTOGRAM(i,n)=sum(abs(AMP(mask,n)));
               end
           end
            
            % merge all 60 electrodes to one electrode
            AllSpikesPerBin=1:numberOFbins;
            AllSpikesPerBin(:)=0; % number of spikes over all electrodes per bin
            AllAmpsPerBin=1:numberOFbins;
            AllAmpsPerBin(:)=0;
            actElPerBin=1:numberOFbins;
            actElPerBin(:)=0; % number of active electrodes per bin
            for binPosition=1:numberOFbins
                for n=1:size(SPIKES,2)
                    AllSpikesPerBin(binPosition)=AllSpikesPerBin(binPosition)+SPIKEHISTOGRAM(binPosition,n);
                    AllAmpsPerBin(binPosition)=AllAmpsPerBin(binPosition)+AMPHISTOGRAM(binPosition,n);
                    if SPIKEHISTOGRAM(binPosition,n) > 0
                        actElPerBin(binPosition)=actElPerBin(binPosition)+1;
                    end
                end
                Product(binPosition)=AllAmpsPerBin(binPosition)*AllSpikesPerBin(binPosition)*actElPerBin(binPosition);
            end
            
            % THRESHOLD:
            % Networkbursts defined if Product exceeds threshold
            % according to Chiappalone et al threshold is set to 9
            % constantly
            % Th=9;
            
            % fixed Threshold
            if ThDecide == 0
                Th=9;
            end
            
            % flexible Threshold: Th is at least 9 or 1/4*maxValue
            if ThDecide == 1 
                Th=max(Product)*1/8; % Th= 1/2*max(AE) * 1/2*max(FR) * 1/2*max(AMP)
                if Th<9 Th=9; end % minimal threshold value is set to 9 (3 spikes per burst, at least on 3 electrodes -> 3*3=9 spikes)
            end
            
            for binPosition=1:numberOFbins
                Mask(binPosition)=Product(binPosition)>=Th;
            end
            potbeg = 0;
            potend = 0;
            k=0; % index for NETWORKBURSTS array
            for binPosition=1:numberOFbins-1 % only set maximum of Product as Netzworkburst-Stamp
                %beginning of Networkburst
                if Mask(binPosition+1)>Mask(binPosition)
                    potbeg = binPosition;
                end
                if Mask(binPosition)==1 && binPosition==1 potbeg=1; end % in case first bin is alraedy above threshold
                %End of Spikes
                if (Mask(binPosition+1)<Mask(binPosition) && (potbeg ~= 0))
                    potend = binPosition;
                end
                % = Peak
                if potend ~= 0
                    if potbeg~=potend % only set networkburst if begin and end is not equal
                        SEARCH = Product(potbeg:potend); % set maximum as CORE
                        [~,I]= max(SEARCH);
                        k=k+1;
                        NETWORKBURSTS.CORE(k,1)=((potbeg+I-1)*bin);
                        NETWORKBURSTS.BEG(k,1)=(potbeg*bin);
                        NETWORKBURSTS.END(k,1)=(potend*bin);
                        NETWORKBURSTS.SIB(k,1)=sum(AllSpikesPerBin(potbeg:potend)); % Save number of spikes in each networkburst                
                    end
                    potbeg = 0;
                    potend = 0;
                end
            end
            
            % transform networkbursts into timestamps
%             for k=1:size(NetworkburstsPerBin.beg,1)
%                 NETWORKBURSTS.CORE(k)=NetworkburstsPerBin.core(k)*bin*(k-1);
%                 NETWORKBURSTS.BEG(k)=NetworkburstsPerBin.beg(k)*bin*(k-1);
%                 NETWORKBURSTS.END(k)=NetworkburstsPerBin.end(k)*bin*(k-1);
%             end
%             Networkbursts_temp=nonzeros(NETWORKBURSTS.CORE);
%             NETWORKBURSTS.CORE(:)=0;
%             NETWORKBURSTS.CORE=Networkbursts_temp;
%             Networkbursts_temp=nonzeros(NETWORKBURSTS.BEG);
%             NETWORKBURSTS.BEG(:)=0;
%             NETWORKBURSTS.BEG=Networkbursts_temp;
%             Networkbursts_temp=nonzeros(NETWORKBURSTS.END);
%             NETWORKBURSTS.END(:)=0;
%             NETWORKBURSTS.END=Networkbursts_temp;
            
            % calculate networkburstduration:
            for k=1:size(NETWORKBURSTS.BEG,1)
                NETWORKBURSTS.BD(k,1)=NETWORKBURSTS.END(k)-NETWORKBURSTS.BEG(k);
            end

            % idle time in seconds: delete networkbursts that are closer than
            % idleTime to each other
            k=0;
            while k<=size(NETWORKBURSTS.BEG,1)-2 
                k=k+1;
                 if (NETWORKBURSTS.BEG(k+1)-NETWORKBURSTS.END(k)<idleTime) && (NETWORKBURSTS.BEG(k+1)~=0)
                     if NETWORKBURSTS.SIB(k)<NETWORKBURSTS.SIB(k+1) % only delete networkburst, if next networkburst is stronger or equal
                        NETWORKBURSTS.CORE((k):size(NETWORKBURSTS.CORE,1)-1)=NETWORKBURSTS.CORE((k+1):size(NETWORKBURSTS.CORE,1));
                        NETWORKBURSTS.CORE(end)=0; 
                        NETWORKBURSTS.BEG((k):size(NETWORKBURSTS.BEG,1)-1)=NETWORKBURSTS.BEG((k+1):size(NETWORKBURSTS.BEG,1));
                        NETWORKBURSTS.BEG(end)=0;
                        NETWORKBURSTS.END((k):size(NETWORKBURSTS.END,1)-1)=NETWORKBURSTS.END((k+1):size(NETWORKBURSTS.END,1));
                        NETWORKBURSTS.END(end)=0;
                        NETWORKBURSTS.SIB((k):size(NETWORKBURSTS.SIB,1)-1)=NETWORKBURSTS.SIB((k+1):size(NETWORKBURSTS.SIB,1));
                        NETWORKBURSTS.SIB(end)=0;
                        NETWORKBURSTS.BD((k):size(NETWORKBURSTS.BD,1)-1)=NETWORKBURSTS.BD((k+1):size(NETWORKBURSTS.BD,1));
                        NETWORKBURSTS.BD(end)=0;
                        k=k-1; % because new burst is on position k
                     else % if SIB(k) >= SIB(k+1), delete SIB(k+1)
                        NETWORKBURSTS.CORE((k+1):size(NETWORKBURSTS.CORE,1)-1)=NETWORKBURSTS.CORE((k+2):size(NETWORKBURSTS.CORE,1));
                        NETWORKBURSTS.CORE(end)=0; 
                        NETWORKBURSTS.BEG((k+1):size(NETWORKBURSTS.BEG,1)-1)=NETWORKBURSTS.BEG((k+2):size(NETWORKBURSTS.BEG,1));
                        NETWORKBURSTS.BEG(end)=0;
                        NETWORKBURSTS.END((k+1):size(NETWORKBURSTS.END,1)-1)=NETWORKBURSTS.END((k+2):size(NETWORKBURSTS.END,1));
                        NETWORKBURSTS.END(end)=0;
                        NETWORKBURSTS.SIB((k+1):size(NETWORKBURSTS.SIB,1)-1)=NETWORKBURSTS.SIB((k+2):size(NETWORKBURSTS.SIB,1));
                        NETWORKBURSTS.SIB(end)=0;
                        NETWORKBURSTS.BD((k+1):size(NETWORKBURSTS.BD,1)-1)=NETWORKBURSTS.BD((k+2):size(NETWORKBURSTS.BD,1));
                        NETWORKBURSTS.BD(end)=0;
                        k=k-1; % because new burst is on position k 
                     end
                 end
            end
            temp=nonzeros(NETWORKBURSTS.CORE);
            NETWORKBURSTS.CORE=temp;
            temp=nonzeros(NETWORKBURSTS.BEG);
            NETWORKBURSTS.BEG=temp;
            temp=nonzeros(NETWORKBURSTS.END);
            NETWORKBURSTS.END=temp;
            temp=nonzeros(NETWORKBURSTS.SIB);
            NETWORKBURSTS.SIB=temp;
            temp=nonzeros(NETWORKBURSTS.BD);
            NETWORKBURSTS.BD=temp;
            
            
            
            % Networkburst-Parameter:
            NETWORKBURSTS=BurstParameterCalculation(NETWORKBURSTS,rec_dur);
            

end