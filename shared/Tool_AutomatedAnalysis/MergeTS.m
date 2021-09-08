% --- Merge TimeStamps -------------------------------------------
    function MERGED=MergeTS(SPIKEZ,MERGED,filename,flag_realClock) 
        
        if nargin == 3
           flag_realClock=0; % use by default the rec_dur to combine files
        end
        
        SPIKEZ.TS(SPIKEZ.TS==0)=NaN; % NaN Patting
        SPIKEZ.AMP(isnan(SPIKEZ.TS))=NaN; % NaN Patting
        
        
        
        %disp(['Merging TS file: ' filename '. Real clock mode: ' num2str(flag_realClock)])
        MERGED.neg.flag = 0; % dont use pos or neg spikes, only current
        MERGED.pos.flag = 0; % dont use pos or neg spikes, only current
        
        if ~flag_realClock % use rec_dur to combine files
            disp('Real clock mode: off')
            % save first data
            if size(MERGED.TS,2) ~= size(SPIKEZ.TS,2)
                MERGED.TS=SPIKEZ.TS; % first time MERGED gets fields like TS, AMP, PREF, ect...
                MERGED.AMP=SPIKEZ.AMP;
                MERGED.PREF=SPIKEZ.PREF;
                MERGED.PREF.filename{1,1}=filename;
                if isfield(SPIKEZ,'FILTER')
                    MERGED.FILTER=SPIKEZ.FILTER;
                end
                if isfield(SPIKEZ,'SNR')
                    MERGED.SNR=SPIKEZ.SNR;
                end
                if isfield(SPIKEZ,'WAVEFORM')
                   MERGED.WAVEFORM=SPIKEZ.WAVEFORM; 
                end
                %MERGED.pos=SPIKEZ.pos; 
                %MERGED.neg=SPIKEZ.neg;
                % merge files    
            else   
                MERGED.PREF.filename{end+1,1}=filename;
                for n=1:size(SPIKEZ.TS,2)
                    numElementsOld=sum(~isnan(MERGED.TS(:,n)),1);
                    numElementsNew=sum(~isnan(SPIKEZ.TS(:,n)),1);
                    TS = SPIKEZ.TS(:,n);
                    AMP = SPIKEZ.AMP(:,n);
                    if numElementsNew > 0
                        MERGED.TS(1+numElementsOld:numElementsNew+numElementsOld,n)=TS(~isnan(TS))+MERGED.PREF.rec_dur;
                        MERGED.AMP(1+numElementsOld:numElementsNew+numElementsOld,n)=AMP(~isnan(TS)); 
                    end
                end
                MERGED.PREF.rec_dur=MERGED.PREF.rec_dur + SPIKEZ.PREF.rec_dur;
            end
        end
        
        if flag_realClock % use real clock time to combine files
            disp('Real clock mode: on')
            date_s=SPIKEZ.PREF.Date;
            time_s=SPIKEZ.PREF.Time;
            
            day=str2num(date_s(1:2));
            month = str2num(date_s(4:5));
            year = str2num(date_s(7:10));
            hours=str2num(time_s(1:2)); 
            minutes = str2num(time_s(4:5));
            seconds = str2num(time_s(7:8));
            
            DateNumber_full = datenum(year,month,day,hours,minutes,seconds); % DateNumber = datenum(Y,M,D,H,MN,S) 
            DateNumber_year = datenum(num2str(year),'yyyy');
            
            DateNumber = DateNumber_full - DateNumber_year;
            
            % save first data
            if size(MERGED.TS,2) ~= size(SPIKEZ.TS,2)
                MERGED.TS=SPIKEZ.TS; % first time MERGED gets fields like TS, AMP, PREF, pos.flag ect...
                MERGED.AMP=SPIKEZ.AMP;
                MERGED.PREF=SPIKEZ.PREF;
                MERGED.PREF.filename{1,1}=filename;
                MERGED.PREF.DateNumber{1,1}=DateNumber;
                if isfield(SPIKEZ,'FILTER')
                    MERGED.FILTER=SPIKEZ.FILTER;
                end
                if isfield(SPIKEZ,'SNR')
                    MERGED.SNR=SPIKEZ.SNR;
                end
                %MERGED.pos=SPIKEZ.pos; 
                %MERGED.neg=SPIKEZ.neg;
                % merge files    
            else    
                OffsetTime = DateNumber - MERGED.PREF.DateNumber{1,1}; % minus first datenumber
                OffsetTime = OffsetTime * 24 * 60 * 60; % from days to seconds
                MERGED.PREF.filename{end+1,1}=filename;
                for n=1:size(SPIKEZ.TS,2)
                    numElementsOld=sum(~isnan(MERGED.TS(:,n)),1);
                    numElementsNew=sum(~isnan(SPIKEZ.TS(:,n)),1);
                    TS = SPIKEZ.TS(:,n); 
                    AMP = SPIKEZ.AMP(:,n);      
                    if numElementsNew > 0
                        MERGED.TS(1+numElementsOld:numElementsNew+numElementsOld,n)=TS(~isnan(TS))+OffsetTime;
                        MERGED.AMP(1+numElementsOld:numElementsNew+numElementsOld,n)=AMP(~isnan(TS)); 
                    end
                end
                MERGED.PREF.rec_dur=OffsetTime + SPIKEZ.PREF.rec_dur;
                MERGED.PREF.DateNumber{end+1,1}=DateNumber;
            end
        end
        
    end