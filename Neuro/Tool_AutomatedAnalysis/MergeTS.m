% --- Merge TimeStamps -------------------------------------------
    function MERGED=MergeTS(SPIKEZ,MERGED,filename,flag_realClock) 
        
        if nargin == 3
           flag_realClock=0; % use by default the rec_dur to combine files
        end
        
        %disp(['Merging TS file: ' filename '. Real clock mode: ' num2str(flag_realClock)])
        
        
        if ~flag_realClock % use rec_dur to combine files
            % save first data
            if size(MERGED.TS,2) ~= size(SPIKEZ.TS,2)
                MERGED.TS=SPIKEZ.TS; % first time MERGED gets fields like TS, AMP, PREF, pos.flag ect...
                MERGED.AMP=SPIKEZ.AMP;
                MERGED.PREF=SPIKEZ.PREF;
                MERGED.PREF.filename{1,1}=filename;
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
                MERGED.PREF.filename{end+1,1}=filename;
                for n=1:size(SPIKEZ.TS,2)
                    numElements=size(nonzeros(MERGED.TS(:,n)),1);
                    MERGED.TS(1+numElements:size(nonzeros(SPIKEZ.TS(:,n)))+numElements,n)=nonzeros(SPIKEZ.TS(:,n))+MERGED.PREF.rec_dur;
                    MERGED.AMP(1+numElements:size(nonzeros(SPIKEZ.AMP(:,n)))+numElements,n)=nonzeros(SPIKEZ.AMP(:,n));         
                end
                MERGED.PREF.rec_dur=MERGED.PREF.rec_dur + SPIKEZ.PREF.rec_dur;
            end
        end
        
        if flag_realClock % use real clock time to combine files
            
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
                    numElements=size(nonzeros(MERGED.TS(:,n)),1);
                    MERGED.TS(1+numElements:size(nonzeros(SPIKEZ.TS(:,n)))+numElements,n)=nonzeros(SPIKEZ.TS(:,n))+OffsetTime;
                    MERGED.AMP(1+numElements:size(nonzeros(SPIKEZ.AMP(:,n)))+numElements,n)=nonzeros(SPIKEZ.AMP(:,n));         
                end
                MERGED.PREF.rec_dur=OffsetTime + SPIKEZ.PREF.rec_dur;
                MERGED.PREF.DateNumber{end+1,1}=DateNumber;
            end
        end
        
    end