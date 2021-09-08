function [NETWORKBURSTS,AllSpikesPerBin,actElPerBin,Product,numberOFbins,Th]=networkburstdetection(SPIKES,rec_dur,bin,idleTime,Th)
            %ThDecide = str2num(cell2mat(inputdlg('enter 0 or 1 (0: fixed Threshold, 1: flexible Threshold)')));        
            ThDecide=0;
           
            
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
           
           
%            % test: matlab binning:
%            
%            [SPIKEHISTOGRAM, edges]=histcounts(nonzeros(SPIKES(:))); % use spikes of all electrodes
%            
%            if size(SPIKEHISTOGRAM,1)==1 % in case only one El is active the size of hist would be [1,numberOfbins]
%                SPIKEHISTOGRAM=SPIKEHISTOGRAM';
%            end   
%            bin=edges(1);
%            xvalues=edges(1:end-1)+edges(1)/2; % use bin center as x value
%            numberOFbins=size(SPIKEHISTOGRAM,1);
           
            
            % merge all 60 electrodes to one electrode
            AllSpikesPerBin=1:numberOFbins;
            AllSpikesPerBin(:)=0; % number of spikes over all electrodes per bin
            actElPerBin=1:numberOFbins;
            actElPerBin(:)=0; % number of active electrodes per bin
            for binPosition=1:numberOFbins
                for n=1:size(SPIKES,2)
                    AllSpikesPerBin(binPosition)=AllSpikesPerBin(binPosition)+SPIKEHISTOGRAM(binPosition,n);
                    if SPIKEHISTOGRAM(binPosition,n) > 0
                        actElPerBin(binPosition)=actElPerBin(binPosition)+1;
                    end
                end               
            end
            
            % Filter FR and AE:
            % smoot by median (size 20)
            if 0
%                AllSpikesPerBin=median_smooth(AllSpikesPerBin,20);
%                actElPerBin=median_smooth(actElPerBin,20);
               %AllSpikesPerBin=smooth(AllSpikesPerBin,20); % average filter
               %actElPerBin=smooth(actElPerBin,20);
               AllSpikesPerBin=medfilt1(AllSpikesPerBin,20); % median filter
               actElPerBin=medfilt1(actElPerBin,20);
            end
            
            % delete all values smaller 3:
            %AllSpikesPerBin(AllSpikesPerBin<3)=0;
            %actElPerBin(actElPerBin<3)=0;
            
            % smooth curves by filter
            if 0
                lpFilt = designfilt('lowpassfir','PassbandFrequency',0.25, ...
             'StopbandFrequency',0.35,'PassbandRipple',0.5, ...
             'StopbandAttenuation',65,'DesignMethod','kaiserwin');
                AllSpikesPerBin=filter(lpFilt,AllSpikesPerBin);
                actElPerBin=filter(lpFilt,actElPerBin);
            end
            % smooth curves by condensator
            if 0
                oldVal=0;
                for k=1:size(AllSpikesPerBin,1)
                    %val_k=AllSpikesPerBin(k);
                   AllSpikesPerBin(k)=AllSpikesPerBin(k)+oldVal/2;
                   oldVal = AllSpikesPerBin(k);
                end
                oldVal=0;
                for k=1:size(actElPerBin,1)
                    %val_k=actElPerBin(k);
                   actElPerBin(k)=actElPerBin(k)+oldVal/2;
                   oldVal = actElPerBin(k);
                end
            end
            
            
            % FR*AE:
            for binPosition=1:numberOFbins
                Product(binPosition)=AllSpikesPerBin(binPosition)*actElPerBin(binPosition);
            end
            
            % THRESHOLD:
            % Networkbursts defined if Product exceeds threshold
            % according to Chiappalone et al threshold is set to 9
            % constantly
            % Th=9;
            
            % fixed Threshold
            if ThDecide == 0
                %Th=1000; % Th=50 (3D-cultures)
                
                
                %FRperSec = length(nonzeros(SPIKES))/rec_dur; % calc spikerate per seconds
                %FRperBin_expected = FRperSec * bin; % number of spikes per bin if uniformly distributed
                %Th=FRperBin_expected * 10;
            end
            
            % flexible Threshold
            if ThDecide == 1 
                % use definition of jimbo's lab
                p_std=std(Product);
                p_mean=mean(Product);
                Th=max([p_mean+(p_std*3), 10]);
            end

            
            % flexible Threshold: Th is at least 9 or 1/4*maxValue
%             if ThDecide == 1 
%                 Th=max(actElPerBin)*max(AllSpikesPerBin)*1/4; % Th= 1/2*max(AE) * 1/2*max(FR)
%                 if Th<9 Th=9; end % minimal threshold value is set to 9 (3 spikes per burst, at least on 3 electrodes -> 3*3=9 spikes)
%             end
            
            
           
            
            % APPLY THRESHOLD
            Mask=Product>=Th;

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
                if Mask(binPosition)==1 && binPosition==numberOFbins-1 potend=binPosition; end % in case last bin is still above threshold
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
            
            % calculate relative networkbursts
            if 0
                % SIBrel
                maxSIB=max(NETWORKBURSTS.SIB(:));
                for k=1:size(NETWORKBURSTS.SIB,1)
                    NETWORKBURSTS.SIBrel(k) = NETWORKBURSTS.SIB(k)/maxSIB;
                end                        
                NETWORKBURSTS.SIBrelAll = sum(NETWORKBURSTS.SIBrel);
                % BDrel
                maxBD=max(NETWORKBURSTS.BD(:));
                for k=1:size(NETWORKBURSTS.BD,1)
                    NETWORKBURSTS.BDrel(k) = NETWORKBURSTS.BD(k)/maxBD;
                end
                NETWORKBURSTS.BDrelAll = sum(NETWORKBURSTS.BDrel);
                % Nrel
                NETWORKBURSTS.Nrel = mean([NETWORKBURSTS.SIBrelAll NETWORKBURSTS.BDrelAll]);
            end
            
            % Networkburst-Parameter:
            NETWORKBURSTS=BurstParameterCalculation(NETWORKBURSTS,rec_dur);
            
            
            
    %% Nested Function        
    function [smooth]=median_smooth(elements,l)
               for i=1:size(elements,2)
                   if i>=size(elements,2)-l % last time: use last point as i+1
                      smooth(i)=median(elements(i:size(elements,2))); 
                   end 
                   if i<size(elements,2)-l
                      smooth(i)=median(elements(i:i+(l-1))); % if l=3: median over i, i+1, i+2
                   end
               end
    end
end