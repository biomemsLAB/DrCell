% written by MC
%
% Needs function 'BurstParameterCalculation.m'
% 
% Burstdetection input: 
% - Name: string containing the name of desired burstdetection algorithm
% - SPIKES: matrix containing timestamps of spikes in seconds (matrix NxM, N: nth spike position in seconds, M: electrode number)
% - rec_dur: recording duration in seconds
% optional input:
% - pref.SIB_min: minimal number of spikes per burst (default: 3 spikes per burst).
% - pref.ISI_max: maximal interspikeintervall in seconds (default: 0.1 s)
% - pref.IBI_min: minimal interburstintervall in seconds (default 0 s)
% Burstdetection output:
% - BURSTS (structure)
% - BURSTS.name: name of used burstalgorithm
% - BURSTS.BEG: timestamps of burstbegin in seconds (for every burst)
% - BURSTS.END: timestamps of burstend in seconds (for every burst)
% - BURSTS.CORE: core of burst (only available with 'wagenaar')
% - BURSTS.BD: burstduration in seconds (for every burst)
% - BURSTS.IBI: interburstintervall in seconds (for every burst)
% - BURSTS.SIB: number of spikes per burst (for every burst)
%
% - BURSTS.BR: burstrate in bursts per minute (one value per electrode)          
% - BURSTS.BDmean: mean burstduration (one value per electrode)
% - BURSTS.BDstd: standard deviation of BD (one value per electrode)     
% - BURSTS.IBImean: mean interburstintervall (one value per electrode)
% - BURSTS.IBIstd: standard deviation of IBI (one value per electrode)
% - BURSTS.SIBmean:  mean Spikes per Burst (one value per electrode)
% - BURSTS.SIBstd: standard deviation of SIB (one value per electrode)              
% - BURSTS.N: number of bursts (one value per electrode)
%
%
% - BURSTS.aeBRmean: mean burst rate (one value per chip)
% - BURSTS.aeBRstd: standard deviation burst rate (one value per chip)
% - BURSTS.aeBDmean: mean burstduration (one value per chip)
% - BURSTS.aeBDstd: standard deviation of BD (one value per chip)
% - BURSTS.aeIBImean: mean interburstintervall (one value per chip)
% - BURSTS.aeIBIstd: standard deviation of IBI (one value per chip)
% - BURSTS.aeSIBmean: mean number of spikes per burst (one value per chip)
% - BURSTS.aeSIBstd: standard deviation of SIB (one value per chip)
%
% - BURSTS.aeN_BR: number of all calculated burstrates
% - BURSTS.aeN_BD: number of all calculated BDs
% - BURSTS.aeN_IBI: number of all calculated IBIs
% - BURSTS.aeN_SIB: number of all calculated SIBs
% - BURSTS.aeN: number of all bursts (one value per chip)



function BURSTS=burstdetection(Name,SPIKES,rec_dur,pref)
    % init
    clear BURSTS
    BURSTS.SIB = zeros(1,size(SPIKES,2)); 
    BURSTS.BEG = zeros(1,size(SPIKES,2));
    BURSTS.END = zeros(1,size(SPIKES,2));
    BURSTS.BD = zeros(1,size(SPIKES,2)); 
       
    if nargin < 4
        SIB_min=3;
        ISI_max=0.1;
        IBI_min=0;
    else
        SIB_min=pref.SIB_min;
        ISI_max=pref.ISI_max;
        IBI_min=pref.IBI_min;
    end
    

    
    % select burstdetection method
    switch Name 
        case 'tam'
            BURSTS=Burstdetection_TAM(SPIKES);
        case 'baker'
            BURSTS=Burstdetection_ISImax(SPIKES,ISI_max,SIB_min,IBI_min);  
        case 'kapucu'
            BURSTS=Burstdetection_KAPUCU(SPIKES,0); % (SPIKES,BRS_Flag=0)
        case 'selinger_one_el'
            BURSTS=Burstdetection_SELINGER(SPIKES,ISI_max,0); % (SPIKES,ISI_max=100,Flag_all_el=1) calculate ISI_max for each electrode
        case 'selinger'
            BURSTS=Burstdetection_SELINGER(SPIKES,ISI_max,1); % (SPIKES,ISI_max=100,Flag_all_el=1) use ISIs of all electrodes 
        case 'cocatre'
            BURSTS=Burstdetection_COCATRE(SPIKES,rec_dur,1); % (SPIKES,rec_dur,Flag_all_el=1) use ISIs of all electrodes 
        case 'jungblut'
            BURSTS=Burstdetection_JUNGBLUT(SPIKES);
        case 'wagenaar3'
            BURSTS=Burstdetection_WAGENAAR3(SPIKES,IBI_min,rec_dur);
        case 'wagenaar4'
            BURSTS=Burstdetection_WAGENAAR4(SPIKES,IBI_min,rec_dur);
        case 'wagenaar'
            BURSTS=Burstdetection_WAGENAAR(SPIKES,rec_dur);
        case 'chiappalone'
            BURSTS=Burstdetection_ISImax(SPIKES,100,10,0);
        case '16Hz'
            BURSTS=Burstdetection_16Hz(SPIKES,ISI_max,SIB_min);
        otherwise
            errordlg(['Selected burstdetection "' Name '" not found'])
    end
    
    %BURSTS=validateBursts(BURSTS,SPIKES,rec_dur,0.05);
    BURSTS=BurstParameterCalculation(BURSTS,rec_dur);
    BURSTS.name=Name; % rewrite the current name of burstdetection algorithm
    BURSTS.PREF.SIB_min = SIB_min;
    BURSTS.PREF.ISI_max = ISI_max;
    BURSTS.PREF.IBI_min = IBI_min;

% --- Burstdetection_TAM -----------------
    function BURSTS=Burstdetection_TAM(SPIKES)
            
            BURSTS.SIB = zeros(1,size(SPIKES,2)); %Spikes per Burst for every Burst
            BURSTS.BEG = zeros(1,size(SPIKES,2));
            BURSTS.END = zeros(1,size(SPIKES,2));
            BURSTS.BD = zeros(1,size(SPIKES,2)); % Burstduration for every Burst
            
            SPIKES_offset(2:size(SPIKES,1)+1,:)=SPIKES(:,:); % copy of SPIKES with first place empty for pseudospike
            SPIKES_offset(1,:)=-300; % Pseudospike
            
            
            for n = 1:size(SPIKES,2)                                            % n: current collum = electrode     k: row in BURSTS    o: number of spikes in current burst
                SPIKES_offset(length(nonzeros(SPIKES_offset(:,n)))+1,n)=10000; % Pseudospike am ENDE
                m = 2; k=1; i=0; o=0; flag=0;                               % i: Zählt eins hoch wenn mehr als 3 Spikes im Burst  m: row in SPIKES = nter Spike
                if(size(nonzeros(SPIKES(:,n)),1) < 3)
                else    
                
                while (m+3 <= size(SPIKES_offset(:,n),1))                      % ...skip last two spikes:
                        for i=0:size(SPIKES_offset(:,n),1)-m-3 % m: potential burst begin, i: ith spike in burst
                           if(SPIKES_offset(m,n)-SPIKES_offset(m-1,n) > SPIKES_offset(m+2+i,n)-SPIKES_offset(m,n) & SPIKES_offset(m+3+i,n)-SPIKES_offset(m+2+i,n) > SPIKES_offset(m+2+i,n)-SPIKES_offset(m,n) & SPIKES_offset(m+3+i,n) > 0)
                               % if IBI1 > BD & IBI2 > BD
                               flag=1; % indicates that burst has been found
                               o=3+i; % number of spikes in burst
                               break
                           end
                        end
                        if flag==1
                            BURSTS.BEG(k,n)=SPIKES_offset(m,n);
                            BURSTS.SIB(k,n)=o;
                            BURSTS.END(k,n)=SPIKES_offset(m+o-1,n);
                            BURSTS.BD(k,n) = BURSTS.END(k,n)-BURSTS.BEG(k,n);
                            k=k+1;
                            m=m+o;
                            i=0; o=0;
                            flag=0;
                        else
                            m=m+1;
                        end
                end
                end
            end         
    end       
% --- Burstdetection_KAPUCU -----------------
    function BURSTS=Burstdetection_KAPUCU(SPIKES,BRS_Flag)

        BRS_Flag=NaN; % Burst related spikes (BRS) are not considered yet
        Min_Spikes = 3;                                             %%Minimum Spikes pro Burst Grenze

        for el=1:size(SPIKES,2) % for all available electrodes

                SPIKES_Array = SPIKES(:,el);    %%Signal einer Elektrode in SPIKES_Array schreiben

                if max(find(SPIKES_Array)) >= Min_Spikes            %%Testen, ob im vorliegenden Signal �berhaupt genug Spikes f�r einen Burst vorkommen (Min_Spikes = 3). Falls nicht: Algorithmus �berspringen und anschlie�end counter erh�hen. Falls doch: Algorithmus ausf�hren und counter erh�hen.


                        ISI_Spikes = diff(SPIKES_Array);                                    %%ISI-Zeiten berechnen aus Differenzen

                        max_time = max(ISI_Spikes);                                   %%Finde das Signal mit h�chster Zeit, um (sinnvolle) Obergrenze f�r Histogramm zu wissen (Untergrenze ist 0)
                        
                        % use "histcounts§ instead of "histogram" to avoid
                        % plotting in open figure window
                        [elements,edges]=histcounts(ISI_Spikes,100,'BinLimits',[0,max_time]);
                       Bins = length(elements);
                       Bin_size = edges(2) - edges(1);
                       Bin_space = edges;
                       Bin_center = edges + Bin_size/2;

                            
%                         Histo = histogram(ISI_Spikes,100,'BinLimits',[0,max_time]);   %%Histogramm aus ISI-SPIKES abspeichern. WICHTIG: Histogrammgrenzen mit 'BinLimits' setzen!!!
%                         Bins = Histo.NumBins;                                         %%Binanzahl des Histogramm auslesen und abspeichern
%                         Bin_size = Histo.BinWidth;                                    %%Binbreite des Histogramms abspeichern  
%                         Bin_space = Histo.BinEdges;
%                         Bin_center = (Histo.BinWidth)/2;                              %%(!!!!Achtung: eventuell sp�ter 1x eine halbe Bin abziehen... aber nur 1x!!!)

                        CMA = cumsum(elements)./(1:Bins);                         %%CMA-Formel (2) --> siehe KABUCU 2012
                        Maximum_Bin = find(CMA == max(CMA));                          %%Position des gr��ten Peaks in CMA finden = Binposition (Achtung!!!!!! Hier kann man theoretisch die Position um 1 verschieben)

                        skew = skewness(ISI_Spikes);                                  %%(Statistische) Schiefe berechnen

                        if skew < 1                                                   %%Parametertabelle f�r alpha1 und alpha2 nach skew(statistische Schiefe). NEGATIVE Schiefe wird bisher NICHT korrekt abgefangen! (Algorithmus ist hierf�r jedoch anscheinend auch nicht ausgelegt)
                            alpha1 = 1;        
                            alpha2 = 0.5;           
                        elseif skew < 4
                            alpha1 = 0.7;       
                            alpha2 = 0.5;
                        elseif skew < 9
                            alpha1 = 0.5;       
                            alpha2 = 0.3;
                        else
                            alpha1 = 0.3;       
                            alpha2 = 0.1;
                        end

                        %%%%Neue Grenzwerte f�r Bursts berechnen%%%%

                        CMA_alpha1 = CMA(Maximum_Bin)*alpha1;                            %%CMA * alpha1 f�r unteren Threshold                   
                        CMA_alpha2 = CMA(Maximum_Bin)*alpha2;                            %%CMA * alpha2 f�r oberen Trheshold

                        CMA_cut = CMA;                                                   %%%Neues CMA, wo wir alles unterhalb unseres gr��ten Peaks abschneiden (das interessiert uns nicht mehr)
                        CMA_cut(1:Maximum_Bin) = [];                                     %%%!!!!MAXIMUM_BIN MINUS 1?!?!!!!!!! --> n�, eigentlich egal

                        threshold_alpha1_array = find(CMA_cut <= CMA_alpha1);            %%Werte als Array speichern
                        threshold_alpha2_array = find(CMA_cut <= CMA_alpha2);            %%Werte als Array speichern
                        threshold_alpha1 = threshold_alpha1_array(1,1) + Maximum_Bin;    %%Erste Zelle aus Array auslesen. VORHER abgeschnittene Bins m�ssen wieder addiert werden!!!
                        threshold_alpha2 = threshold_alpha2_array(1,1) + Maximum_Bin;    %%Erste Zelle aus Array auslesen
                        threshold_alpha1_time(el) = threshold_alpha1 * Bin_size;             %%Threshold in Zeit (s), bezogen auf Bin-Breite
                        threshold_alpha2_time(el) = threshold_alpha2 * Bin_size;             %%Threshold in Zeit (s), bezogen auf Bin-Breite
                end 
        end
        BURSTS=Burstdetection_ISImax(SPIKES,threshold_alpha1_time,3,0); % Find Burst-Cores, (SPIKES,ISI_max,SIB_min,IBI_min)
    end % END Burstdetection_KAPUCU
% --- Burstdetection_SELINGER (TH_min= 10^-1 = 100 ms) [Under construction!]  ------
    function BURSTS=Burstdetection_SELINGER(SPIKES,TH_min,flag_all_el) 
        
        % if less than 3 spikes on an electrode, just init BURSTS and return
        if size(SPIKES,1) <= 3
            th = 0.1;
            BURSTS=Burstdetection_ISImax(SPIKES,th,3,0);
            return
        end

        % calculate ISIs
        ISI = diff(SPIKES,1);
        ISI(ISI<=0)=NaN;


       for n=1:size(SPIKES,2)

           if ~isempty(nonzeros(ISI(:,n)))   
               
               % log ISI:
               if flag_all_el
                   logISI=log10(nonzeros(ISI));
               else
                   logISI=log10(nonzeros(ISI(:,n))); % calculate ln(ISI), without zero because: ln(0)=inf
               end        
               
               % ISI-Histogram:
               %xvalues=log10(0.0001):0.1:log10(10); % xvalues for log10
               %[elements,edges]=histcounts(logISI,xvalues); 
               nbins=ceil(sqrt(length(logISI))); % number of bins is number of ISIs^0.5
               [elements,edges]=histcounts(logISI,nbins);
               %elements=elements/max(elements); % normalize hist
                
               % use bin-center as xvalues
               BinWidth=edges(2)-edges(1);
               bin_center=edges+BinWidth/2; 
               xvalues=bin_center(1:end-1);
               
               % delete elements <= 1 ms
               elements(xvalues<=-3)=0;
               
               if 1
               % smoot histogram by median (size 3) % alternativly use:
               % medfilt1
               for i=1:size(elements,2)
                   if i==1 % first time: use first point as i-1
                      smooth(i)=median([elements(i),elements(i),elements(i+1)]); 
                   end
                   if i==size(elements,2) % last time: use last point as i+1
                      smooth(i)=median([elements(i-1),elements(i),elements(i)]); 
                   end 
                   if i~=1 && i~=size(elements,2)
                      smooth(i)=median(elements(i-1:i+1));
                   end
               end
               %elements=smooth;
               end
                
               
               
   
%                % big ISIs have more weight (modification by MC):
%                w=(1:size(elements,2)).^3;
%                elements_w=elements.*w;
%                elements_w=elements_w/max(elements_w);
%                
%                % find peaks
%                temp=diff(smooth);
%                diffs=zeros(size(xvalues));
%                diffs(2:end)=temp;
%                diffs_backup=diffs;
%                
%                % peak1:
%                [~,x(1)]=max(diffs);
%                diffs(x(1))=0;
%                % peak2:
%                [~,x(2)]=max(diffs);
%                diffs(x(2))=0;
%                % peak3:
%                [~,x(3)]=max(diffs);

                % find threshold in ISI-histogram by means of Otsu-method
                if 1
                counts=elements';
                num_bins=size(counts,1);
                p = counts / sum(counts);
                omega = cumsum(p);
                mu = cumsum(p .* (1:num_bins)');
                mu_t = mu(end);
                sigma_b_squared = (mu_t * omega - mu).^2 ./ (omega .* (1 - omega));
                maxval = max(sigma_b_squared);
                idx = mean(find(sigma_b_squared == maxval));
                idx=round(idx);
                if ~isnan(idx)
                    TH=10^xvalues(idx);
                else
                    TH=0;
                end
                end

                if 0 % old code
                % find peaks
                [~,x(1)]=max(smooth);
                x(2)=size(smooth,2);
                x(3)=x(2);
                
               x=sort(x);
               
               % find minimum between peaks
               [Minimum1, index1]=min(smooth(x(1):x(2)));
               [Minimum2, index2]=min(smooth(x(2):x(3)));

               index1=index1+x(1)-1; % offset miteinrechnen, da bei min nur von peak1 bis peak2 gesucht wurde
               index2=index2+x(2)-1;

               TH1=xvalues(index1);
               TH2=xvalues(index2);
                end
               
                
                

               % plot
               if 0
               figure; hold on
               plot(xvalues,elements,'-.');
               plot(xvalues,smooth);
%               plot(xvalues,diffs_backup,'.');
               %text(xvalues(x(1)),smooth(x(1)),'max1');
               %text(xvalues(x(2)),smooth(x(2)),'max2');
               %text(xvalues(x(3)),smooth(x(3)),'max3');
               text(TH,0,'Th');
               %text(TH2,0,'th2');
               end

               if 0
               % select lowest minimum as threshold
               if Minimum2 <= Minimum1
                   TH=10^(TH2);
               else
                   TH=10^(TH1);
               end
               end

               % set TH to TH_min (e.g. 100 ms) if TH is lower
               if TH<TH_min
                   TH=TH_min;
               end
              
              
                   
           else
               TH=0;
           end
           th(n)=TH;
           %TH
       end
       BURSTS=Burstdetection_ISImax(SPIKES,th,3,0); % find bursts on current electrode n (SPIKES,ISI_max,SIB_min,IBI_min)
    end
% --- Burstdetection_COCATRE (ISI-Histogram, Smooth, Chi²-Test)  ------
    function BURSTS=Burstdetection_COCATRE(SPIKES,rec_dur,flag_all_el) 
        
        % calculate ISIs
        ISI = diff(SPIKES);
        ISI(ISI<=0)=NaN;

       for n=1:size(SPIKES,2)
           
  
           if ~isempty(nonzeros(ISI(:,n))) 
               % log ISI:
               if flag_all_el
                   logISI=nonzeros(ISI); % do not use logarithm
               else
                   logISI=ISI(:,n); % do not use logarithm
               end       
               nbins=ceil(sqrt(length(logISI))); % number of bins is number of ISIs^0.5
               [elements,edges]=histcounts(logISI,nbins);
               
               % use bin-center as xvalues
               BinWidth=edges(2)-edges(1);
               bin_center=edges+BinWidth/2; 
               xvalues=bin_center(1:end-1);
               
               % delete elements <= 1 ms
               elements(xvalues<=-3)=0;
               
               % smoot histogram by median (size 3)
               for i=1:size(elements,2)
                   if i==1 % first time: use first point as i-1
                      smooth(i)=median([elements(i),elements(i),elements(i+1)]); 
                   end
                   if i==size(elements,2) % last time: use last point as i+1
                      smooth(i)=median([elements(i-1),elements(i),elements(i)]); 
                   end 
                   if i~=1 && i~=size(elements,2)
                      smooth(i)=median(elements(i-1:i+1));
                   end
               end
               
               % find threshold (starting at the maximal bin (=left mode) as reference and compare the right ones, if right bin is bigger or equal to the reference, take this bin as the threshold)
               [~,max_pos]=max(smooth);
               TH=0; flag=0;
               for r=max_pos:size(smooth,2) % reference bin
                   for i=r:size(smooth,2)-1
                        if smooth(i+1) >= smooth(r) && flag==0 
                            TH=xvalues(r); flag=1;
                        end
                   end
               end
               
               % plot
               if 0
               figure; hold on
               plot(xvalues,elements,'.');
               plot(xvalues,smooth);
%                text(xvalues(x(1)),elements_w(x(1)),'max1');
%                text(xvalues(x(2)),elements_w(x(2)),'max2');
%                text(xvalues(x(3)),elements_w(x(3)),'max3');
               text(TH,0,'th');
%                text(TH2,elements(index2),'th2');
               end
                
               
           else
               TH=0;
           end
           th(n)=TH;
           %TH
       end
       BURSTS=Burstdetection_ISImax(SPIKES,th,3,0); % find bursts on current electrode n (SPIKES,ISI_max,SIB_min,IBI_min)
       
       % validate Bursts
       BURSTS=validateBursts(BURSTS,SPIKES,rec_dur,0.05);
    end
% --- Burstdetection_JUNGBLUT -----------------
    function BURSTS=Burstdetection_JUNGBLUT(SPIKES)
        BURSTS.SIB = zeros(1,size(SPIKES,2)); %Spikes per Burst for every Burst
        BURSTS.BEG = zeros(1,size(SPIKES,2));
        BURSTS.END = zeros(1,size(SPIKES,2));
        BURSTS.BD = zeros(1,size(SPIKES,2)); % Burstduration for every Burst
            
            
        maxISI_1_2 = 10; % in ms
        maxISI_3_n = 20; % in ms
        SIB_min = 3;
        minIBI = 500; % in ms
        
         for n = 1:size(SPIKES,2)                                            % n: current collum = electrode
                k = 1; m = 1;                                                   % k: row in BURSTS, m: row in SPIKES
                while m <= size(nonzeros(SPIKES(:,n)),1)-2                      % ...skip last two spikes:
                    if ((SPIKES(m+1,n)-SPIKES(m,n) <= (maxISI_1_2/1000)) && (SPIKES(m+2,n)-SPIKES(m+1,n) <= (maxISI_1_2/1000))) % check the first 3 spikes
                        candidate = SPIKES(m,n);   % safe postential Timestampfor a burst
                        m = m+2;
                        o = 3;                     % o: current number of Spikes in that Burst
                        if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        while SPIKES(m+1,n)-SPIKES(m,n) <= (maxISI_3_n/1000)
                            m = m+1;
                            o = o+1;
                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        end
                        
                        if o >= SIB_min
                            BURSTS.BEG(k,n)= candidate;
                            
                            %calculate burstduration
                            BURSTS.BD(k,n) = SPIKES(m,n)-SPIKES(m-o+1,n);
                            BURSTS.END(k,n)=BURSTS.BEG(k,n)+BURSTS.BD(k,n);
                            BURSTS.SIB(k,n) = o;
                            k = k+1;
                            
                            while SPIKES(m,n)-BURSTS.BEG(k-1,n)<=(minIBI/1000)
                                m = m+1;
                                if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            end
                        end
                    else
                        m = m+1;
                    end
                end
         end
    end
% --- Burstdetection_BAKER -----------------
    function BURSTS=Burstdetection_BAKER(SPIKES,maxISI,minSpikes)
        BURSTS.SIB = zeros(1,size(SPIKES,2)); %Spikes per Burst (pro el)
        BURSTS.BEG = zeros(1,size(SPIKES,2));
        BURSTS.END = zeros(1,size(SPIKES,2));
        BURSTS.BD = zeros(1,size(SPIKES,2)); %Burstduration
            
        maxISI_1_2= maxISI; % in ms
        maxISI_2_3= maxISI;
        minSpikes = minSpikes;
        minIBI = 0; % in ms
        
         for n = 1:size(SPIKES,2)                                            % n: current collum = electrode
                k = 1; m = 1;                                                   % k: row in BURSTS, m: row in SPIKES
                while m <= size(nonzeros(SPIKES(:,n)),1)-2                      % ...skip last two spikes:
                    if ((SPIKES(m+1,n)-SPIKES(m,n) <= (maxISI_1_2/1000)) && (SPIKES(m+2,n)-SPIKES(m+1,n) <= (maxISI_2_3/1000))) % check the first 3 spikes
                        candidate = SPIKES(m,n);   % safe postential Timestampfor a burst
                        m = m+2;
                        o = 3;                     % o: current number of Spikes in that Burst
                        if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        while SPIKES(m+1,n)-SPIKES(m,n) <= (maxISI_2_3/1000)
                            m = m+1;
                            o = o+1;
                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        end
                        
                        if o >= minSpikes
                            BURSTS.BEG(k,n)= candidate;
                            
                            %calculate burstduration
                            BURSTS.BD(k,n) = SPIKES(m,n)-SPIKES(m-o+1,n);
                            BURSTS.END(k,n)=BURSTS.BEG(k,n)+BURSTS.BD(k,n);
                            BURSTS.SIB(k,n) = o;
                            k = k+1;
                            
                            while SPIKES(m,n)-BURSTS.BEG(k-1,n)<=(minIBI/1000)
                                m = m+1;
                                if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            end
                        end
                    else
                        m = m+1;
                    end
                end
         end
    end
% --- Burstdetection_WAAGENAR4 [old version] -----------------
    function BURSTS=Burstdetection_WAGENAAR4(SPIKES,IBI_min,rec_dur)
        BURSTS.SIB = zeros(1,size(SPIKES,2)); %Spikes per Burst for every Burst
        BURSTS.BEG = zeros(1,size(SPIKES,2));
        BURSTS.END = zeros(1,size(SPIKES,2));
        BURSTS.BD = zeros(1,size(SPIKES,2)); % Burstduration for every Burst
        
        for n = 1:size(SPIKES,2)
                NR_SPIKES(n) = length(find(SPIKES(:,n)));
        end
        
         Spikerate = NR_SPIKES.*(1/rec_dur);
            tau1 = zeros(1,size(SPIKES,2));            % empty arrays...
            tau2 = zeros(1,size(SPIKES,2));
            Spikedelay1 = zeros(1,size(SPIKES,2));     % Delay in the core
            Spikedelay2 = zeros(1,size(SPIKES,2));     % Delay around the
            
            for n = 1:size(SPIKES,2)
                tau1(n) = 1/(4*Spikerate(n)); % in seconds
                tau2(n) = 1/(3*Spikerate(n));
                
                if tau1(n) > 1/10  % choose 100 ms or 1/4 MFR, wichever is smaller
                    Spikedelay1(n) = 1/10;
                else
                    Spikedelay1(n) = tau1(n);
                end
                
                if tau2(n) > 2/10 % choose 200 ms or 1/3 MFR, wichever is smaller
                    Spikedelay2(n) = 2/10;
                else
                    Spikedelay2(n) = tau2(n);
                end
                
                
                k = 1; m = 1;                                                   % k: row in BURSTS, m: row in SPIKES
                while m <= size(nonzeros(SPIKES(:,n)),1)-2                      % -2 at 4 Spikes in the core...until third last spike in SPIKES:
                    if ((SPIKES(m+1,n)-SPIKES(m,n)<=Spikedelay1(n)) && (SPIKES(m+2,n)-SPIKES(m+1,n)<=Spikedelay1(n)) && (SPIKES(m+2,n)-SPIKES(m+1,n)<=Spikedelay1(n)))
                        candidate = SPIKES(m,n);
                        FirstSpike = m;
                        m = m+3;
                        o = 4;
                        
                        if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        while SPIKES(m+1,n)-SPIKES(m,n) <= Spikedelay2(n)
                            m = m+1;
                            o = o+1;
                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        end
                        
                        if FirstSpike > 1
                            while SPIKES(FirstSpike,n) - SPIKES(FirstSpike-1,n) <= Spikedelay2(n)
                                FirstSpike = FirstSpike - 1;
                                o=o+1;
                                if FirstSpike <= 1, break, end
                            end
                        end
                        
                        if o >= 4
                            BURSTS.BEG(k,n)= candidate;
                            BURSTS.END(k,n)=SPIKES(m,n);
                            %calculate burstduration
                            BURSTS.BD(k,n) = SPIKES(m,n)-SPIKES(m-o+1,n);
                            BURSTS.SIB(k,n) = o;
                            k = k+1;
                            
                            while SPIKES(m,n)-BURSTS.BEG(k-1,n)<=(IBI_min/1000) 
                                m = m+1;
                                if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            end
                        end
                    else
                        m = m+1;
                    end
                end
            end
    end
% --- Burstdetection_WAAGENAR3 [old version]
    function BURSTS=Burstdetection_WAGENAAR3(SPIKES,IBI_min,rec_dur)
        BURSTS.SIB = zeros(1,size(SPIKES,2)); %Spikes per Burst for every Burst
        BURSTS.BEG = zeros(1,size(SPIKES,2));
        BURSTS.END = zeros(1,size(SPIKES,2));
        BURSTS.BD = zeros(1,size(SPIKES,2)); % Burstduration for every Burst
        
        for n = 1:(size(SPIKES,2))
                NR_SPIKES(n) = length(find(SPIKES(:,n)));
        end
        
         Spikerate = NR_SPIKES.*(1/rec_dur);
            tau1 = zeros(1,size(SPIKES,2));
            tau2 = zeros(1,size(SPIKES,2));
            Spikedelay1 = zeros(1,size(SPIKES,2));
            Spikedelay2 = zeros(1,size(SPIKES,2));
            
            for n = 1:size(SPIKES,2)
                tau1(n) = 1/(4*Spikerate(n));
                tau2(n) = 1/(3*Spikerate(n));
                
                if tau1(n) > 1/10
                    Spikedelay1(n) = 1/10;
                else
                    Spikedelay1(n) = tau1(n);
                end
                
                if tau2(n) > 2/10
                    Spikedelay2(n) = 2/10;
                else
                    Spikedelay2(n) = tau2(n);
                end
                
                
                k = 1; m = 1;
                while m <= size(nonzeros(SPIKES(:,n)),1)-2
                    if ((SPIKES(m+1,n)-SPIKES(m,n)<=Spikedelay1(n)) && (SPIKES(m+2,n)-SPIKES(m+1,n)<=Spikedelay1(n)))
                        
                        candidate = SPIKES(m,n);
                        FirstSpike = m;
                        m = m+2;
                        o = 3;
                        if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        while SPIKES(m+1,n)-SPIKES(m,n) <= Spikedelay2(n)
                            m = m+1;
                            o = o+1;
                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        end
                        if FirstSpike > 1
                            while SPIKES(FirstSpike,n) - SPIKES(FirstSpike-1,n) <= Spikedelay2(n)
                                FirstSpike = FirstSpike - 1;
                                o=o+1;
                                if FirstSpike <= 1, break, end
                            end
                        end
                        
                        if o >= 3
                            BURSTS.BEG(k,n)= candidate;
                            BURSTS.END(k,n)=SPIKES(m,n);
                            BURSTS.BD(k,n) = SPIKES(m,n)-SPIKES(m-o+1,n);
                            BURSTS.SIB(k,n) = o;
                            k = k+1;
                            
                           while SPIKES(m,n)-BURSTS.BEG(k-1,n)<=(IBI_min/1000)
                                m = m+1;
                                if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                           end
                        end
                    else
                        m = m+1;
                    end
                end
            end
    end
% --- Burstdetection_WAAGENAR -----------------
    function BURSTS=Burstdetection_WAGENAAR(SPIKES,rec_dur)
        BURSTS.SIB = zeros(1,size(SPIKES,2)); %Spikes per Burst for every Burst
        BURSTS.BEG = zeros(1,size(SPIKES,2));
        BURSTS.END = zeros(1,size(SPIKES,2));
        BURSTS.BD = zeros(1,size(SPIKES,2)); % Burstduration for every Burst
        BURSTS.CORE = zeros(1,size(SPIKES,2));
        
        for n = 1:(size(SPIKES,2))
                NR_SPIKES(n) = length(find(SPIKES(:,n)));
        end
        
         Spikerate = NR_SPIKES.*(1/rec_dur);
            tau1 = zeros(1,size(SPIKES,2));            % empty arrays...
            tau2 = zeros(1,size(SPIKES,2));
            Spikedelay1 = zeros(1,size(SPIKES,2));     % Delay in the core
            Spikedelay2 = zeros(1,size(SPIKES,2));     % Delay around the
            
            for n = 1:size(SPIKES,2)
                tau1(n) = 1/(4*Spikerate(n));
                tau2(n) = 1/(3*Spikerate(n));
                
                if tau1(n) > 1/10  % choose 100 ms or 1/4 MFR, wichever is smaller
                    Spikedelay1(n) = 1/10;
                else
                    Spikedelay1(n) = tau1(n);
                end
                
                if tau2(n) > 2/10 % choose 200 ms or 1/3 MFR, wichever is smaller
                    Spikedelay2(n) = 2/10;
                else
                    Spikedelay2(n) = tau2(n);
                end
                
                
                k = 1; m = 1;                                  % k: row in BURSTS, m: row in SPIKES
                while m+3 <= size(nonzeros(SPIKES(:,n)),1)                      %  4 Spikes in the core...until third last spike in SPIKES:
                    if ((SPIKES(m+1,n)-SPIKES(m,n)<=Spikedelay1(n)) && (SPIKES(m+2,n)-SPIKES(m+1,n)<=Spikedelay1(n)) && (SPIKES(m+3,n)-SPIKES(m+2,n)<=Spikedelay1(n)))
                        o = 4;
                        post=0; past=0; 
                        if m+4 >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        while SPIKES(m+4+post,n)-SPIKES(m+3+post,n) <= Spikedelay2(n) % while ISIs after core < 200 ms
                            post=post+1;
                            o = o+1;
                            if m+4+post >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                        end
                        
                        if m-1 > 1
                            while SPIKES(m-past,n) - SPIKES(m-1-past,n) <= Spikedelay2(n) % while ISIs before core < 200 ms
                                past=past+1;
                                o=o+1;
                                if m-1-past <= 1, break, end
                            end
                        end
                        
                        
                            BURSTS.BEG(k,n)= SPIKES(m-past,n);
                            BURSTS.CORE(k,n)=SPIKES(m,n);
                            BURSTS.END(k,n)=SPIKES(m+3+post,n);
                            BURSTS.BD(k,n) = BURSTS.END(k,n)-BURSTS.BEG(k,n);
                            BURSTS.SIB(k,n) = o;
                            k = k+1;
                            m=m+o-1;
                    else
                        m = m+1;
                    end
                end
            end
    end 
% --- Burstdetection_16Hz [Under construction]
    function BURSTS=Burstdetection_16Hz(SPIKES,ISI_max,SIB_min) % this burstcriteria is similar to baker(SIB_min=8, ISI_max=500)
   
            %bin=0.500; % in seconds
            bin=ISI_max/1000;
            
            
            %df=16; % Burstdefiniton: if spike-frequency rises by 16 Hz (df=6 => similar to baker(SIB_min=3, ISI_max=100))
            %dSPIKES = bin * df; % delta of 8 spikes per bin is needed to fit burstdefinition
            
            dSPIKES = SIB_min;
            
            for n=1:size(SPIKES,2)
                i=1;
                flag=0; % flag=1 -> burst begin has been detected
                
                % calculate all bins of current electrode
                for k=1:size(nonzeros(SPIKES(:,n)),1)
                    bin_start(k)=SPIKES(k,n); % spike defines bin-position
                    bin_end(k)=SPIKES(k,n)+bin;  
                    spikes_in_bin(k)=length(nonzeros(SPIKES(:,n)<=bin_end(k) & SPIKES(:,n)>=bin_start(k))); % how many spikes are inside bin
                end                              
                
                for k=1:size(nonzeros(SPIKES(:,n)),1)
                    if SPIKES(k,n)~=0
                        
                        % Burst begin
                        if spikes_in_bin(k) >= dSPIKES && flag==0 % if bin contains at least 8 spikes  -> burst begin
                            BURSTS.BEG(i,n)=SPIKES(k,n);
                            flag=1;  
                        end
                        
                        % Burst end
                        if flag==1 && k<=size(nonzeros(SPIKES(:,n)),1)-1
                            if bin_start(k+1)> bin_end(k) % if bin_k does not overlap with bin_k-1 -> burst end
                            BURSTS.END(i,n)=SPIKES(k,n);
                            BURSTS.BD(i,n)=BURSTS.END(i,n)-BURSTS.BEG(i,n);
                            BURSTS.SIB(i,n)=length(nonzeros(SPIKES(:,n)<=BURSTS.END(i,n) & SPIKES(:,n)>=BURSTS.BEG(i,n)));
                            flag=0;
                            i=i+1;
                            end
                        end
                        
                        % take last spike as burst end if burst end is
                        % missing
                        if k==size(nonzeros(SPIKES(:,n)),1) && flag==1
                            if size(nonzeros(BURSTS.BEG(:,n)),1)>size(nonzeros(BURSTS.END(:,n)),1)
                                BURSTS.END(i,n)=SPIKES(k,n);
                            end
                        end
                        
                    end
                end
                if i==1 % if no burst has been found on current electrode, then write zero
                   BURSTS.BEG(1,n)=0;
                   BURSTS.SIB(1,n)=0;
                   BURSTS.BD(1,n)=0;
               end
            end
 
    end
% --- Burstdetection_ISImax (tested, same as baker) -----------------
    function BURSTS=Burstdetection_ISImax(SPIKES,ISI_max,SIB_min,IBI_min) % ISI_max /s, IBI_min /s
        BURSTS.SIB = zeros(1,size(SPIKES,2)); %Spikes per Burst (pro el)
        BURSTS.BEG = zeros(1,size(SPIKES,2));
        BURSTS.END = zeros(1,size(SPIKES,2));
        BURSTS.BD = zeros(1,size(SPIKES,2)); %Burstduration 
        
        if size(ISI_max)==1 % if ISI_max contains only one value, create an array
            temp=ISI_max;
            for n=1:size(SPIKES,2)
                ISI_max(n)=temp;
            end
        end
        BURSTS.ISI_max=ISI_max;
        BURSTS.SIB_min=SIB_min;
        BURSTS.IBI_min=IBI_min;
        
         for n = 1:size(SPIKES,2)                                            % n: current collum = electrode
                k = 1; m = 1; i=0;                                                   % k: row in BURSTS, m: row in SPIKES
                while m <= size(nonzeros(SPIKES(:,n)),1)-1                      % ...skip last spike:
      
                        while SPIKES(m+1+i,n)-SPIKES(m+i,n) <= ISI_max(n)
                            i = i+1;
                            if m+i >= size(nonzeros(SPIKES(:,n)),1), break, end
                        end
                        o=1+i; % 1+i because i is increased by one if first two spikes fulfill the "while-loop" criteria
                        i=0;
                        if o >= SIB_min
                            BURSTS.BEG(k,n)= SPIKES(m,n);
                            BURSTS.END(k,n)=SPIKES(m+o-1,n);
                            BURSTS.BD(k,n) = BURSTS.END(k,n)-BURSTS.BEG(k,n);
                            BURSTS.SIB(k,n) = o;
                            k = k+1;
                            m=m+o;
                            
                            if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end % MC
                            
                            % IBI_min "Burst ilde time" 
                            while SPIKES(m,n)-BURSTS.END(k-1,n)<= IBI_min
                                m = m+1;
                                if m >= size(nonzeros(SPIKES(:,n)),1)-1, break, end
                            end
                        else
                        m = m+o;
                        end
                end
         end
    end
% --- Validate Bursts -----
    function BURSTS=validateBursts(BURSTS,SPIKES,rec_dur,p) % according to Cocatre et al.
        % validate Bursts
       % chi-square test, p<0.05
       % H0: number of spikes in burst (fo) = SIB_expected
       % SIB_expected (fe) = average spike frequency (f_average) * burstduration (BD)
       
       for n=1:size(BURSTS.BEG,2)
           if ~isempty(nonzeros(BURSTS.BEG(:,n)))
              f_average=length(nonzeros(SPIKES(:,n)))/rec_dur;
              for k=1:length(nonzeros(BURSTS.BEG(:,n)))
                  fe(k,n)=f_average*BURSTS.BD(k,n); % f_expected
                  fo(k,n)=BURSTS.SIB(k,n); % f_observed
              end
              % calculate chi square value
              chi=0;
              df=length(nonzeros((fe(:,n))))-1; % degree of freedom: number of summands - 1
              for j=1:size(fe(:,n),1)
                 chi = chi + ( ((fo(j,n)-fe(j,n))^2) /fe(j,n));
              end  
              table_value=chi2inv((1-p),df); % probabiltiy of error = 1%
              if chi > table_value
                 h(n)=1; % if chi value is greater than table value, than h1 is true, h0 is rejected  => Burst is valid   
              else
                  h(n)=0;
                  % delete bursts:
                 BURSTS.BEG(:,n)=0;
                 BURSTS.END(:,n)=0;
                 BURSTS.SIB(:,n)=0;
                 BURSTS.BD(:,n)=0;
              end
              BURSTS.h=h;
           else
               BURSTS.h=NaN; % not tested
           end
       end
    end
    
end