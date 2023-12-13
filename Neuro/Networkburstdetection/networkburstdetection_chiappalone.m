%% Detect networkbursts according to chiappalone et al. or jimbo et al.
% Input:                TS: time stamps of spikes (nth spike, nth spike train) in seconds
%                       rec_dur: duration of recording in seconds
%                       bin: bin size in seconds
%                       idleTime: minimal allowed time between two networkbursts (Not working yet!)
%                       ThDecide: 0: chiappalone definition, 1: jimbo's lab
%                       definition, 3: MC's definition
%                       fig: 0: don't show figure, 1: show figure

function [NB,AllSpikesPerBin,actElPerBin,Product,numberOfBins,Th]=networkburstdetection_chiappalone(TS,rec_dur,bin,idleTime,ThDecide,fig)

    if nargin < 5
        fig=0;
    end

    % init
    NB.BEG=NaN;
    NB.END=NaN;
    NB.CORE=NaN;
    NB.SIB=NaN;
    NB.BD=NaN;
    
    if ThDecide == 3
        % MC: use bin size defined by Spike-contrast
        [~,temp.PREF] = SpikeContrast(TS,rec_dur, 0.01);
        bin=temp.PREF.S_smallBin;
        if isnan(bin) % ensure that bin is a valid value
            bin= rec_dur/2;
        end
        NB.PREF.bin=bin;
        clear temp 
    end

    % save prefs:
    NB.PREF.rec_dur=rec_dur;
    NB.PREF.bin=bin;
    NB.PREF.idleTime=idleTime;

    % Bin Spikes
    step=bin;
    [AllSpikesPerBin,actElPerBin,edges,x]=getNumSpikesAndActElPerBin(TS,rec_dur,bin,step);
    numberOfBins=length(x);

    % FR*AE:
    Product=zeros(1,numberOfBins);
    for binPosition=1:numberOfBins
        Product(binPosition)=AllSpikesPerBin(binPosition)*actElPerBin(binPosition);
    end


    % select Threshold
    if ThDecide == 0
        Th=9; % according to chiappalone et al.
    end
    if ThDecide == 1 || ThDecide == 3
        % use definition of jimbo's lab
        p_std=std(Product);
        p_mean=mean(Product);
        Th=max([p_mean+(p_std*3), 10]); % Th is at least 10 or 3*standardDeviation+mean
    end
    if ThDecide == 2 
        % MC, used for 3D hESC neurons
        %p_std=std(Product);
        %Th=max([p_std*5, 10]); 
        Th=600;
    end

    % Find NB from threshold
    [X,Y,begin,ending,duration,integral,peakMask] = detectSpikesFromThreshold(Product,Th);
    NB.CORE=(X'.*bin);  % X': transposed in order to get format needed by function "BurstParameterCalculation"
    NB.BEG=begin'.*bin;
    NB.END=ending'.*bin;
    NB.BD=duration'.*bin;
    if ~isnan(X)
        for i=1:length(X)
            NB.SIB(i,1)=sum(AllSpikesPerBin(begin(i):ending(i)));
        end
    end

    % Burst Idle Time: DOES NOT WORK YET!!!
    %NB=burstIdleTime(NB,idleTime);

    % Networkburst-Parameter:
    NB=BurstParameterCalculation(NB,rec_dur);
    
    % Y-Values:
    NB.Y_Product=Y;
    if isnan(X)
        NB.Y_AllSpikesPerBin=NaN;
        NB.Y_actElPerBin=NaN;
    else
        NB.Y_AllSpikesPerBin=AllSpikesPerBin(X);
        NB.Y_actElPerBin=actElPerBin(X);
    end
    
    if fig
       figure
       h1=subplot(4,1,1);
       h1=plotSpikeTrain(TS,h1);
       
       h2=subplot(4,1,2);
       stairs(x-x(1) , AllSpikesPerBin); 
       h2.XLabel.String='time in s';
       h2.YLabel.String='FR';
       
       h3=subplot(4,1,3);
       stairs(x-x(1) , actElPerBin); 
       h3.XLabel.String='time in s';
       h3.YLabel.String='AE';
       
       h4=subplot(4,1,4);
       stairs(x-x(1) , Product); hold on
       h4.XLabel.String='time in s';
       h4.YLabel.String='FR*AE';
       plot(NB.CORE,Y,'kx');
       plot([0 rec_dur],[Th Th],'--g')
       
       linkaxes([h1 h2 h3 h4],'x')
    end
            
end