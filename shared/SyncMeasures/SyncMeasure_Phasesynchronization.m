% Input: 
% TS: time stamps in seconds (n_maxSpikes x n_electrodes)
% rec_dur: recording duration in seconds
% SaRa: Sample rate in 1/seconds

% Output:
% Sync.M: matrix of pairwise phase sync values (n_electrodes + n_electrodes)
% Sync.S: total phase sync value

function [Sync,tim1,tim2,tim3]=SyncMeasure_Phasesynchronization(TS,rec_dur,SaRa)% (+SH.KH)

    


%     % generate spiketrain:
    N=size(TS,2); % number of electrodes
    t=0:1/SaRa:rec_dur; % Time axis
%     ST=zeros(size(t,2)-1,N);        
%     for n=1:N
%         ST(int32(nonzeros(TS(:,n)*SaRa)-1),n)=1; % set 1 for each spike, 0.0001 s is at array pos. 1, 60 s at 60000
%     end
    
    
    %% Phase Sync:
    
    % calculate phases for every electrode
    phases=zeros(size(t,2),N);
    for n=1:N
        if ~isempty(nonzeros(TS(:,n))) % only if electrode contains spikes    
            
            % ensure that there is no double time stamp as this will result
            % in an error when using interp1
            TS_temp=unique(TS(:,n));
            
            % double the timestamps [1 2 3] -> [1 1 2 2 3 3]
            TS_temp = nonzeros(TS_temp);
            TS2 = zeros(size(TS_temp,1)*2,1);
            TS2(1:2:end)=TS_temp;
            TS2(2:2:end)=TS_temp+(1/SaRa/100); % ideally the second point is the same as before, however for interpolation purpose this point is increased by a very small value (here 0.1ms /100)
            % XXXXXX
            %TS2=TS_temp;
            
            % insert artificial spikes at 0 s and 60 s            
            TS_art = zeros(size(TS2,1)+2,1); % create artificial timestamps with spike at begin and end
            TS_art(2:size(TS2,1)+1) = TS2;
            TS_art(1)=0; % set first artificial spike at 0.0000 s
            TS_art(end)=rec_dur; % set last artificial spike at 60 s
            
            TS_art = unique(TS_art); % in case the original data set already contained spikes at 0 s or 60 s this line will remove the doulbe time stamp (otherwise error at interp1 function) 
            
            TAUK = TS_art; % x values
            y=zeros(size(TAUK)); % y values
            y(2:2:end)=2*pi; % y values
            
            if 1
                phases(:,n) = interp1(TAUK,y,t,'linear'); % interp1(x,y,samples)
            end
            
            % manual interpolation
            if 0
                TAUK=int32(TAUK*SaRa);
                TAUK=double(TAUK)/SaRa;
                for k=1:length(TAUK)-1
                    dTAUK=int32(TAUK(k+1)*SaRa-TAUK(k)*SaRa);
                    dTAUK=double(dTAUK);
                    dt=0:dTAUK -1;
                    arraypos = int32(TAUK(k)*SaRa)+1 : int32(TAUK(k+1)*SaRa);
                    arraypos=int32(arraypos);

                    %phases(arraypos,n)= 2*pi*exp(-dt*6/(dTAUK)); % exp
                    phases(arraypos,n)=2*pi-exp(dt*6/(dTAUK))/exp(dt(end)*6/(dTAUK));
                end
    %             a=1; b=5000;
    %             figure; plot(t(a:b),phases(a:b,n)); hold on
                %plot(TAUK,ones(length(TAUK)),'x');
            end
        end
    end


        actEl=(1:N); % # active EL
        for i=1:size(phases,2)
             if sum(phases(:,i))==0
                 actEl(i)=0;
             end
        end
        phases( :, all( ~any( phases ), 1 ) ) = []; % delete zeros columns
        actEl(actEl==0)=[];    % delete zeros
        M=zeros(N);
        M(M==0)=NaN;
        phases=exp(1i*phases);
        for i=1:size(phases,2)  
            for j=i+1:size(phases,2)
                el1=actEl(i);
                el2=actEl(j);
                M(el1,el2)= mean(abs((phases(:,i) + phases(:,j))/2));
            end
        end  
        
  % calculate total Phase Sync value "R"
        s=sum(phases,2);
        R=mean(abs(s/numel(actEl)));
 
    %% 4) save prefs:
    Sync.M = M; % synchrony matrix 
    Sync.S = R; % scalar synchrony value 
    Sync.PREF.method='Phasesynchronization';
    Sync.PREF.rec_dur=rec_dur;


end



       
