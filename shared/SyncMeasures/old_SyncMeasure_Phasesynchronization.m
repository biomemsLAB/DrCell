% Input: 
% TS: time stamps in seconds (n_maxSpikes x n_electrodes)
% rec_dur: recording duration in seconds
% SaRa: Sample rate in 1/seconds

% Output:
% Sync.M: matrix of pairwise phase sync values (n_electrodes + n_electrodes)
% Sync.S: total phase sync value

function [Sync]=SyncMeasure_Phasesynchronization(TS,rec_dur,SaRa)

    


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
            
            % double the timestamps [1 2 3] -> [1 1 2 2 3 3]
            TS_temp = nonzeros(TS(:,n));
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


    % calculate Matrix (pairwise phase sync)
    M=zeros(N);
    M(M==0)=NaN;
    for i=1:N
        for j=i+1:N % +1 -> do not calculate diagonal
            if ~isempty(nonzeros(phases(:,i))) && ~isempty(nonzeros(phases(:,j)))
               temp= exp(1i*phases(:,i)) + exp(1i*phases(:,j));
               M(i,j)= mean(abs(temp/2));
            end
        end
    end

    % calculate total Phase Sync value "R"
    R=0;
    actEl=0;
    sum=0;
    for n=1:N
       if ~isempty(nonzeros(phases(:,n))) % only if phases with nonzero elements exist
           actEl=actEl+1;           
           sum=sum+exp(1i*phases(:,n));
       end
    end
    R=mean(abs(sum/actEl));
    
    %% 4) save prefs:
    Sync.M = M; % synchrony matrix
    Sync.S = R; % scalar synchrony value 
    Sync.PREF.method='Phasesynchronization';
    Sync.PREF.rec_dur=rec_dur;


end



       
