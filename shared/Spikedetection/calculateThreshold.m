function [THRESHOLDS,THRESHOLDS_pos,ELEC_CHECK,SPIKEZ,COL_RMS,COL_SDT]=calculateThreshold(RAW, SPIKEZ, Multiplier_neg, Multiplier_pos, Std_noisewindow, Size_noisewindow, HDrawdata,flag_waitbar, auto,win_beg, win_end, threshrmsdecide)


% default values
if nargin <= 8
    auto=1;
    win_beg=NaN;
    win_end=NaN;
    threshrmsdecide=1;
end

% Init
SPIKEZ.neg.THRESHOLDS.Th=zeros(size(RAW.M,2));
SPIKEZ.pos.THRESHOLDS.Th=zeros(size(RAW.M,2));
THRESHOLDS = 0;
THRESHOLDS_pos = 0;
ELEC_CHECK = 0;

T=RAW.T;
SaRa=RAW.SaRa;
nr_channel=RAW.nr_channel;
flag_negative = SPIKEZ.neg.flag;
flag_positive = SPIKEZ.pos.flag;


waitbar_counter2 = 0.7;

% save parameter in spiketrain file:
SPIKEZ.neg.THRESHOLDS.Multiplier=Multiplier_neg;
SPIKEZ.neg.THRESHOLDS.Std_noisewindow=Std_noisewindow;
SPIKEZ.neg.THRESHOLDS.Size_noisewindow=Size_noisewindow;

SPIKEZ.pos.THRESHOLDS.Multiplier=Multiplier_pos;
SPIKEZ.pos.THRESHOLDS.Std_noisewindow=Std_noisewindow;
SPIKEZ.pos.THRESHOLDS.Size_noisewindow=Size_noisewindow;



if flag_waitbar
    h_wait = waitbar(0,'Thresholds are calculated.');
    disp ('Calculating thresholds');
end

multiplier = Multiplier_neg;



window_beg = int32(0.01*SaRa+1);
window_end = int32((0.01+Size_noisewindow)*SaRa);
nr_win = 0;
calc_beg = 1;
calc_end = Size_noisewindow*SaRa;

CALC = zeros((2*int16(SaRa)),(size(RAW.M,2)));

if auto
    for n=1:size(RAW.M,2)
        if  HDrawdata==1 %Sh_Kh for .brw Data
            m = digital2analog_sh(RAW.M(:,n),RAW);
        else
            m=RAW.M;
        end
        while nr_win < (2/Size_noisewindow)             % use two secondes of the signal
            
            %calculate STD in windows
            if  HDrawdata==1 %Sh.Kh for .brw Data
                [~,sigma] = normfit(m(window_beg:window_end)); %if you have the Statistics-Toolbox you can use "normfit" as well
            else
                % check if Signal Processing Toolbox is installed:
                v = ver;
                if 0 %any(strcmp('Statistics and Machine Learning Toolbox', {v.Name}))
                    [~,sigma] = normfit(m(window_beg:window_end,n)); %if you have the Statistics-Toolbox you can use "normfit" as well
                else
                    sigma = std(m(window_beg:window_end,n));
                end
            end
                if((sigma < Std_noisewindow) && (sigma > 0))
                if  HDrawdata==1 %Sh.Kh for .brw Data
                    CALC(calc_beg:calc_end,n) = m(window_beg:window_end);
                else
                    CALC(calc_beg:calc_end,n) = m(window_beg:window_end,n);
                end
                calc_beg = calc_beg + Size_noisewindow*SaRa;
                calc_end = calc_end + Size_noisewindow*SaRa;
                window_beg = window_beg + int32(Size_noisewindow*SaRa);
                window_end = window_end + int32(Size_noisewindow*SaRa);
                
                if window_end>size(T,2) break; end %#ok
                ELEC_CHECK(n) = 1;
                nr_win = nr_win + 1;
            else
                window_beg = window_beg + int32(Size_noisewindow/2*SaRa);
                window_end = window_end + int32(Size_noisewindow/2*SaRa);
                
                if window_end>size(T,2) break; end %#ok
                if ((window_beg > 0.5*size(T,2)) && (nr_win == 0))
                    ELEC_CHECK(n) = 0; %noisy
                    break
                end
            end
        end
        
        nr_win = 0;
        window_beg = int32(0.01*SaRa+1);
        window_end = int32((0.01+Size_noisewindow)*SaRa);
        calc_beg = 1;
        calc_end = Size_noisewindow*SaRa;
        if HDrawdata ==1 || size(RAW.M,2)>60
            %if n==1000 || n==2000 || n==3000 || n==4000
            waitbar_counter2 = waitbar_counter2+n*(0.7/nr_channel);
            if flag_waitbar; waitbar(waitbar_counter2,h_wait); end
        else
            waitbar_counter2 = waitbar_counter2+(0.7/nr_channel);
            if flag_waitbar; waitbar(waitbar_counter2,h_wait); end
        end
        %if HDrawdata==0; break; end % Sh.Kh. Uncommented by MC
    end
    COL_RMS = sqrt(mean(CALC.^2));
    COL_SDT = std(CALC);
    
elseif auto == 0                    % Manuell
    if flag_waitbar; waitbar(.6,h_wait,'Please wait - Thresholds are calculated...'); end
    for n=1:size(RAW.M,2)
        if  HDrawdata==1 %Sh.Kh for .brw Data
            m = digital2analog_sh(RAW.M(:,n),RAW);
        else
            m = RAW.M;
        end
        if (win_end-rec_dur<1) && (win_beg == 0)
            COL_RMS = sqrt(mean(m.^2));                 % RMS
            COL_SDT = std(m);
        else
            start = win_beg*SaRa+1;
            finish = win_end*SaRa;
            COL_RMS = sqrt(mean(m(start:finish,:).^2)); % RMS
            COL_SDT = std(m(start:finish,:));
        end
        if HDrawdata==0; break; end
    end
end

if flag_negative
    if threshrmsdecide
        THRESHOLDS = -multiplier.*COL_RMS;
    else
        THRESHOLDS = -multiplier.*COL_SDT;
    end
    
    %new vectorize Sh.Kh
    ECH=find(ELEC_CHECK==0);
    for n=1:size(ECH,2)
        THRESHOLDS(ECH(n))=10000;
    end
end


if flag_positive
    
    if flag_waitbar; waitbar(.5,h_wait,'Please wait - positive thresholds are calculated...'); end
    multiplier = Multiplier_pos;
    
    if threshrmsdecide
        THRESHOLDS_pos = multiplier.*COL_RMS;
    else
        THRESHOLDS_pos = multiplier.*COL_SDT;
    end
    
    %new vectorize Sh.Kh
    ECH=find(ELEC_CHECK==0);
    for n=1:size(ECH,2)
        THRESHOLDS_pos(ECH(n))=10000;
    end
    
else
    THRESHOLDS_pos=0;
end

% save thresholds in spiketrain-file
SPIKEZ.neg.THRESHOLDS.Th=THRESHOLDS;
SPIKEZ.pos.THRESHOLDS.Th=THRESHOLDS_pos;
SPIKEZ.PREF.COL_RMS = COL_RMS;
SPIKEZ.PREF.COL_SDT = COL_SDT;


if flag_waitbar
    close(h_wait)
    disp('Threshold calculation finished')
end
end