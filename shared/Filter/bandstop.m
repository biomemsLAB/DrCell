% --- bandstop filter (Sh.Kh)----------------------------------------------
function [RAW,filterName,f_edge]=bandstop(RAW,f_edge,SaRa,HDrawdata,flag_waitbar,stimulidata,lowerBoundary)


if nargin <=3
    HDrawdata=0;
end

if nargin <=4
    flag_waitbar=0;
end

if nargin <=5
    stimulidata=0;
end

if nargin <=6
    lowerBoundary=0;
end

if flag_waitbar; h_wait = waitbar(0,'Filtering'); end

MM=RAW.M;
filterName = 'HP_cheby2_order3_ripple20';

if lowerBoundary== 0 % in case that lower boundary equals zero use highpass instead of bandstop
    % check if Signal Processing Toolbox is installed:
    v = ver;
    if any(strcmp('Signal Processing Toolbox', {v.Name})) % if toolbox is installed calculate Hd (MC)
        f_edge = f_edge(1); % (1): necessary if more than one instance of DrCell is opened (MC)
        [z,p,k] = cheby2(3,20,f_edge*2/SaRa,'high');
        [sos,g] = zp2sos(z,p,k);			% Convert to SOS form
        Hd = dfilt.df2tsos(sos,g);
        [b,a] = sos2tf(sos);
        %save('filterParameter_HP_50Hz','a','b','g') % "save" was only needed one time to save the filter parameter
    else % if not, load filter parameter for the case Highpass 50 Hz
        disp('Signal Processing Toolbox is not installed. 50 Hz highpass filtering is applied')
        tmp=load('filterParameter_HP_50Hz.mat'); % tmp.a tmp.b is loaded
    end
else
    [z,p,k] = cheby2(3,20,[str2double(get(findobj('Tag','CELL_low_edit'),'string'))*2/SaRa str2double(get(findobj('Tag','CELL_high_edit'),'string'))*2/SaRa],'stop');
    [sos,g] = zp2sos(z,p,k);			% Convert to SOS form
    Hd = dfilt.df2tsos(sos,g);
end

% if less than 1000 electrodes apply filter directly
if HDrawdata == 0 || size(MM,2)<=1000    
    if any(strcmp('Signal Processing Toolbox', {v.Name})) % (MC)
        MM = filter(Hd,MM);
    else
        MM=filter(tmp.b,tmp.a,MM);
    end
    
else
    % if MATLAB runs on windows, the function "memory" is available
    if ispc  
        [~,systemview] = memory;
        if systemview.PhysicalMemory.Total>=((3/4)*systemview.PhysicalMemory.Available)% When enough memory is available
            j = 1200;  % j: number of electrodes that get filtered in parallel 
        else
            j = 1; % bei kleinem Arbeitsspeicher muss j klein sein
        end
    else
        j = 1; 
    end

    for i=0:+j:(floor(numel(MM(1,:))/j)-1)*j
        
        if flag_waitbar; waitbar(((floor(numel(MM(1,:))/j)-1)*j)/i,h_wait); end
        
        if HDrawdata == 1
            m=digital2analog_sh(MM(:,i+1:i+j),RAW.BitDepth, RAW.MaxVolt, RAW.SignalInversion);
            m(m<-4000)=0;
            m(m>4000)=0;
            m=(filter(Hd,m));
            %m=RAW.SignalInversion*(m/(RAW.MaxVolt*2/2^RAW.BitDepth))+((2^RAW.BitDepth)/2); % %convert analog values to digital sample Values
            MM(:,i+1:i+j)=m;
        else %for .mat Data mit  El > 60
            m = MM(:,i+1:i+j);
            m = filter(Hd,m);
            MM(:,i+1:i+j) = single(m);
        end
    end
    i=i+j;
    if i<size(MM,2)
        clear m;
        if HDrawdata ==1
            m=(MM(:,i+1:size(MM,2)));
            m=digital2analog_sh(m,RAW);
            m(m<-4000)=0;
            m(m>4000)=0;
            m=(filter(Hd,m));
            %m=(m/(RAW.MaxVolt*2/2^RAW.BitDepth))+((2^RAW.BitDepth)/2); % %convert analog values to digital sample Values
            MM(:,i+1:size(MM,2))=m;
        else %for .mat Data mit  El > 60
            m=(MM(:,i+1:size(MM,2)));
            m = filter(Hd,m);
            MM(:,i+1:size(MM,2))=m;
        end
    end
   
end
if stimulidata == 1
    for n = 1:(length(BEG))
        MM((int32(BEG(n)*SaRa)):(int32(END(n)*SaRa)),:) = 0;
    end
end
RAW.M=MM;

if flag_waitbar; waitbar(1, h_wait); close(h_wait); end
end