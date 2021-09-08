% --- BurstParameterCalculation (mean/std/ae: SIB,BD,IBI)-----------------     
function BURSTS=BurstParameterCalculation(BURSTS,recTime)    

        % this function needs BURSTS.BEG, BURSTS.SIB, BURSTS.BD

        BURSTS.BR = zeros(1,size(BURSTS.BEG,2)); % Burstrate per electrdoe in Burst/min
        BURSTS.BRn = zeros(1,size(BURSTS.BEG,2)); % Number of bursts per electrode
        BURSTS.SIBmean = zeros(1,size(BURSTS.BEG,2)); % mean Spikes per Burst per electrode
        BURSTS.SIBstd = zeros(1,size(BURSTS.BEG,2));            
        BURSTS.BDmean = zeros(1,size(BURSTS.BEG,2)); % Burstduration mean per electrode
        BURSTS.BDstd = zeros(1,size(BURSTS.BEG,2)); % Burstduration std per electrode  
        BURSTS.IBI = zeros(1,size(BURSTS.BEG,2)); 
        BURSTS.IBIstd = zeros(1,size(BURSTS.BEG,2)); %Interburstintervall
        BURSTS.IBImean = zeros(1,size(BURSTS.BEG,2));
        BURSTS.N=zeros(1,size(BURSTS.BEG,2));

        BURSTS.aeN=0;
        BURSTS.aeBRn=0;
        BURSTS.aeSIBn=0;
        BURSTS.aeBDn=0;
        BURSTS.aeIBIn=0;

        BURSTS.aeBRmean=0;
        BURSTS.aeBRstd=0;
        BURSTS.aeSIBmean=0;
        BURSTS.aeSIBstd=0;
        BURSTS.aeBDmean=0;
        BURSTS.aeBDstd=0;
        BURSTS.aeIBImean=0;
        BURSTS.aeIBIstd=0;

    if ~isempty(nonzeros(BURSTS.BEG)) % in case there is no burst, skip parameter calculation

            % Burst End (END)
            if ~isfield(BURSTS, 'END')
                for n=1:size(BURSTS.BEG,2)
                    BURSTS.END(:,n) = BURSTS.BEG(:,n)+BURSTS.BD(:,n);        
                end
            end

            % Burst Rate (BR):
            for n=1:size(BURSTS.BEG,2)
                BURSTS.BR(n) = length(nonzeros(BURSTS.BEG(:,n)))/recTime*60;        %  Burstrate per electrode per minute
                BURSTS.BRn(n)  = length(nonzeros(BURSTS.BEG(:,n)));
            end
            BURSTS.BR(isnan(BURSTS.BR))=0;
            BURSTS.BRn(isnan(BURSTS.BRn))=0;
            
            BURSTS.aeBRn= length(nonzeros(BURSTS.BR));
            BURSTS.aeBRmean=mean(nonzeros(BURSTS.BR));
            BURSTS.aeBRstd=std(nonzeros(BURSTS.BR));
            
            BURSTS.aeBRn(isnan(BURSTS.aeBRn))=0;
            BURSTS.aeBRmean(isnan(BURSTS.aeBRmean))=0;
            BURSTS.aeBRstd(isnan(BURSTS.aeBRstd))=0;
            


            % Spikes in burst (SIB):
            for n = 1:(size(BURSTS.BEG,2))
                if isempty(nonzeros(BURSTS.SIB(:,n)))
                    BURSTS.SIBmean(n)=0;
                    BURSTS.SIBstd(n)=0;
                else 
                    BURSTS.SIBmean(n)=mean(nonzeros(BURSTS.SIB(:,n)));
                    BURSTS.SIBstd(n)=std(nonzeros(BURSTS.SIB(:,n)));
                end
            end    
            for n=1:size(BURSTS.SIB,2)
               BURSTS.SIBn(n)=length(nonzeros(BURSTS.SIB(:,n))); 
            end
            BURSTS.SIBn(isnan(BURSTS.SIBn))=0;
           [BURSTS.aeSIBmean,BURSTS.aeSIBstd,BURSTS.aeSIBn]=CollectiveVariance(BURSTS.SIBmean,BURSTS.SIBstd,BURSTS.SIBn); 
           BURSTS.aeSIBmean(isnan(BURSTS.aeSIBmean))=0;
           BURSTS.aeSIBstd(isnan(BURSTS.aeSIBstd))=0;
           BURSTS.aeSIBn(isnan(BURSTS.aeSIBn))=0;
           
%             BURSTS.aeN_SIB= length(nonzeros(BURSTS.BEG)); % all in one pot
%             BURSTS.aeSIBmean = mean(nonzeros(BURSTS.SIB)); % all in one pot     
%             BURSTS.aeSIBstd = std(nonzeros(BURSTS.SIB)); % all in one pot
            %  mean number of spikes per burst for all electrodes. Notice: ...  
            % ... do not calculate aeSIBmean like this: mean(nonzeros(SIBmean))
            % ... because you wont get a weighted mean value. in other
            % words: calculating the mean of every electrode, then
            % calculate the mean of this means make you lose the
            % information of how many events per electrodes you get.
            % instead use all values of the whole MEA:
            % "nonzeros()" puts values of all electrodes together in
            % one array, so mean(nonzeros(SIB)) gives the weighted mean



            % Burstduration
            for n=1:size(BURSTS.BEG,2)
                if isempty(nonzeros(BURSTS.BD(:,n)))
                    BURSTS.BDmean(n)=0;
                    BURSTS.BDstd(n)=0;
                else
                    BURSTS.BDmean(n) = mean(nonzeros(BURSTS.BD(:,n)));
                    BURSTS.BDstd(n) = std(nonzeros(BURSTS.BD(:,n)));
                end
            end
            for n=1:size(BURSTS.BD,2)
               BURSTS.BDn(n)=length(nonzeros(BURSTS.BD(:,n))); 
            end
            BURSTS.BDn(isnan(BURSTS.BDn))=0;
            [BURSTS.aeBDmean,BURSTS.aeBDstd,BURSTS.aeBDn]=CollectiveVariance(BURSTS.BDmean,BURSTS.BDstd,BURSTS.BDn); 
            BURSTS.aeBDmean(isnan(BURSTS.aeBDmean))=0;
            BURSTS.aeBDstd(isnan(BURSTS.aeBDstd))=0;
            BURSTS.aeBDn(isnan(BURSTS.aeBDn))=0;


            % Interburstintervall
            for n=1:size(BURSTS.BEG,2)
                if size(nonzeros(BURSTS.BEG(:,n)))<=1
                    BURSTS.IBI(:,n)=0;
                else
                    for i = 1:size(nonzeros(BURSTS.BEG(:,n)),1)-1
                        BURSTS.IBI(i,n) = BURSTS.BEG(i+1,n)-(BURSTS.BEG(i,n)+BURSTS.BD(i,n));
                    end
                end
            end
            for n=1:size(BURSTS.IBI,2)
               BURSTS.IBIn(n)=length(nonzeros(BURSTS.IBI(:,n))); 
            end
            for n=1:size(BURSTS.BEG,2) 
                if isempty(nonzeros(BURSTS.IBI(:,n)))
                    BURSTS.IBImean(n)=0;
                    BURSTS.IBIstd(n)=0;
                else
                    BURSTS.IBImean(n) = mean(nonzeros(BURSTS.IBI(:,n)));
                    BURSTS.IBIstd(n) = std(nonzeros(BURSTS.IBI(:,n)));
                end
            end
            BURSTS.IBIn(isnan(BURSTS.IBIn))=0;
            [BURSTS.aeIBImean,BURSTS.aeIBIstd,BURSTS.aeIBIn]=CollectiveVariance(BURSTS.IBImean,BURSTS.IBIstd,BURSTS.IBIn); 
            BURSTS.aeIBImean(isnan(BURSTS.aeIBImean))=0;
            BURSTS.aeIBIstd(isnan(BURSTS.aeIBIstd))=0;
            BURSTS.aeIBIn(isnan(BURSTS.aeIBIn))=0;
            %BURSTS.aeN_IBI=length(nonzeros(BURSTS.IBI)); % all in one pot
            %BURSTS.aeIBImean = mean(nonzeros(BURSTS.IBI)); % all in one pot
            %BURSTS.aeIBIstd =  std(nonzeros(BURSTS.IBI)); % all in one pot
    end

    % Nested Function
    % --- Variance -----------------------------------------------------
    function [x,stdges,n]=CollectiveVariance(xj,sj,nj) 
        % xj: mean value of each electrode
        % sj: std value of each electrode
        % nj: number of elements of each electrode
        
        n = sum(nj,'omitnan'); % number of elements of entire chip
        if n>1
            %x = 1/n * sum(nj.*xj,'omitnan'); % mean value of entire chip
            x = mean(nonzeros(xj),'omitnan');
            varint = 1/(n-1) * sum(nj.*(sj.^2),'omitnan'); 
            varext = 1/(n-1) * sum(nj.*((xj-x).^2),'omitnan');
            varges = varint + varext; % variance of entire chip
        else
           x=xj(1);
           varges=0;
           n=nj(1);
        end
        
        stdges = sqrt(varges); % standard deviation of entire chip
    end
    
    
end %End BurstParameterCalculation