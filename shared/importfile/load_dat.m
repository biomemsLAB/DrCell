% Load Raw Data (.dat) (MC: taken from DrCell function "openFileButtonCallback" )
% Input:    filepath            Full path to file (file extention: .dat)
%           flag_waitbar        optional input: 
%                               If set to 1: Window will open that shows user that file is being loaded.
%                               If set to 0: no window will open (Default)
%

function [Date,Time,SaRa,EL_NAMES,EL_NUMS,M,T,rec_dur,fileinfo,nr_channel] = load_dat(filepath, flag_waitbar)
        
        if nargin == 1
           flag_waitbar = 0;  
        end
        
        
        [~,file_name,ext] = fileparts(filepath);
        
        if ~strcmp(ext,'.dat')
            errordlg('File extension has to be ".dat".', 'Error');
            return
        end
        

        if flag_waitbar
           H = waitbar(0,'Please wait - analyzing data file...'); 
        else
           disp(['Importing data file: ' file_name]); 
        end

        
        fid = fopen([filepath]);                                   % open file
        
        
        fseek(fid,0,'eof');
        filesize = ftell(fid);                                      % safes file size,
        fseek(fid,0,'bof');
        fileinfo = textscan(fid,'%s',1,'delimiter','\n');
        
        filedetails = textscan(fid,'%s',1,'delimiter','\n');
        filedetailscell = strread(char([filedetails{1}]),'%s','delimiter',',');
        
        Date = char([filedetailscell{1}]);
        Time = char([filedetailscell{2}]);
        Sample = char([filedetailscell{3}]);
        Sample = Sample(1:(size(Sample,2)-3));
        SaRa = str2double(Sample);
        FileType = [];
        if size(filedetailscell,1)==4
            FileType = char([filedetailscell{4}]);
        end
        
        fseek(fid,0,'bof');
            %---if rawdata---
            textscan(fid,'%s',1,'whitespace','\b\t','headerlines',2);
            elresult = textscan(fid,'%5s',61*1,'whitespace','\b\t');
            EL_NAMES = [elresult{:}];
            
%             if is_open==1
%                 nr_channel_old = nr_channel;
%             end
            
            nr_channel = find(ismember(EL_NAMES, '[ms]')==1)-1;
            if isempty(nr_channel)
                nr_channel = find(ismember(EL_NAMES, '[ms] ')==1)-1;
            end
            EL_NAMES = EL_NAMES(1:nr_channel);
            EL_CHAR = char(EL_NAMES);
            
            for n=1:size(EL_CHAR,1)
                EL_NUMS(n) = str2double(EL_CHAR(n,4:5));
            end
            
            fseek(fid,0,'bof');
            if file_name(length(file_name)-2)=='t'
                mresult = textscan(fid,'',1,'headerlines',4);
                M = [mresult{2:length(mresult)}];
                %M = [mresult{2:length(mresult)-1}]; original changed 2013-04-04
            else
                %---separation by dot---
                mresult = textscan(fid,'',1,'headerlines',4);
                M = [mresult{2:length(mresult)}];
            end
            
            clear M_temp;
            NTimes = ceil((filesize - ftell(fid))/10000);

            while ftell(fid)<filesize-2
                if file_name(length(file_name)-2)=='t'
                    ftell(fid);
                    mresult = textscan(fid,'',NTimes);%ceil(filesize/10000));
                    M = cat(1,M,[mresult{2:length(mresult)}]);
                    %M = [mresult{2:length(mresult)-1}]; original changed 2013-04-04
                    
                    if flag_waitbar
                        waitbar(ftell(fid)*.98/filesize,H,['Please wait - analyzing data file... (' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
                    end
                else
                    
                    %---separation by dot---
                    %- separation by comma see elseif isempty(FileType)
                    ftell(fid);
                    mresult = textscan(fid,'',NTimes);%ceil(filesize/10000));
                    M = cat(1,M,[mresult{2:length(mresult)}]);
                    if flag_waitbar
                        waitbar(ftell(fid)*.98/filesize,H,['Please wait - analyzing data file... (' int2str(ftell(fid)/1048576) ' of ' int2str(filesize/1048576),' MByte)']);
                    end
                end
            end
            
            clear M_temp;
            clear mresult;
            T2=(0:1/SaRa:(size(M,1)/SaRa));
            T=T2(1:(length(T2)-1));
            clear T2
            
            M = cat(2,EL_NUMS',M');
            M = sortrows(M);
            M = M(:,2:size(M,2));
            M = M';
            EL_NAMES = sortrows(EL_NAMES);
            EL_NUMS = sort(EL_NUMS);
            rec_dur = ceil(T(length(T)));
            %rec_dur_string = num2str(rec_dur);
            
            
            fclose(fid);                        % close file
            
            if flag_waitbar
                waitbar(1,H,'Complete')
                close(H)
            else
                disp(['converted: ' file_name])
            end
    end