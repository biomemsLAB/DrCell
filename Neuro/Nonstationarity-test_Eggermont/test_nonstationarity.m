function RES = test_nonstationarity(TS,force,T,plot_bool)
%
% This function returns boolean values of the stationarity in Spiketrains. 
% It uses the empirical cumulative distribution function (ECDF) to 
% normalize the Spiketrain signal occurrences of neuronal cells on one 
% electrode.
%
% Function is based on: J.J. Eggermont B. Gourévitch. A simple indicator of nonstationarity of 
% firing rate in spike trains. In Journal of Neuroscience Methods, pages 181 – 187, 2007.
%
% "The p-value associated with the proposed stationarity (S) test (null hypothesis: the spike train is stationary) is p=1?P(AN < z). 
% Given the very small values of p that will be manipulated in the following, 
% we found it more convenient to use a nonstationarity indicatorNS =?ln(p)
% as a “surprise” value for AN" [Gourevitch and Eggermont, 2007]
%
% "we recommend a strict significance level for the S test, for example
% NS?5, which is equivalent to a p-value of 0.007. Notice
% that due to the accuracy of the approximation of P(AN < z) to
% 10?6, NS statistic values can not be very precise above 14." [Gourevitch and Eggermont, 2007]
%
%
% It is necessary to include the following functions to your workspace to
% use this functions:
                        % ns_detect.m
                        % ADinf.m
                        % not needed anymore: f_nonstationarity_ADT.m (Anderson Darling Test)
                        % not needed anymore: f_nonstationarity_P.m (Probability Value)
                        % not needed anymore: f_nonstationarity_NS.m (Indicator of Non-Stationarity)
%
% Input    
            % TS:        Timestamps 'double' (2-dimensional array)
            % force:     Minimum number  of neuronal Timestamps on one 
            %            electrode 'int' (min. 1000 recommended)
            % T:         Time of recorded test data 'double' (in s)    
            % plot_bool: 0 = no plots 'bool'
            %            1 = ECDF plots of timestamps on every electrode 

% Output  
            % SP_pos:    Spike positions of electrodes
            % SP_val:    Number of all Spiketrain TS values (one elctrode)
            % SP1_N:     Number of Spiketrain TS values (vector 1, T_split > 0)
            % S1:        Stationarity of Spiketrain (1 = stationary)

%
% Andreas Raeder            
            
    SP_el = 0;
    for el = 1:size(TS,2)
        if nnz(TS(:,el)) >= force
            SP_el = SP_el + 1;
        end
    end

    SP_pos = zeros([SP_el,1]);                                                 
    SP_val = zeros([SP_el,1]);
    SP_el = 0;  

    for el = 1:size(TS,2);            % Save position (pos) & value (val) in arrays
        nz = nnz(TS(:,el));
        if  nz >= force
            SP_el = SP_el + 1;
            SP_pos(SP_el,1) = el;
            SP_val(SP_el,1) = nz;
        end
    end

    AN1 = zeros(SP_el,1);
    P1 = zeros(SP_el,1);
    p1 = zeros(SP_el,1);
    NS1 = zeros(SP_el,1);

    for el = 1:SP_el
        SP = nonzeros(TS(:,SP_pos(el)));                                        % ecdf
        [odN1,tn1] = ecdf(SP);
        Zn1 = tn1/T;
        N1 = length(odN1);
        Fu1 = linspace(0,1,N1)';
        if plot_bool == 1
            figure(el)                                                          % plot figures of ecdf
            stairs(Zn1,odN1);
            title('empirical cumulative distribution function');
            xlabel('Zn');
            ylabel('range 0:1/N:1');
            grid on;
            hold on;
            plot(Fu1,odN1);
        end
        %AN1(el,1) = f_nonstationarity_ADT(Zn1); % custom written function
        %P1(el,1) = f_nonstationarity_P(AN1(el,1));
        %p1(el,1) = 1-P1(el,1);
        %NS1(el,1) = f_nonstationarity_NS(P1(el,1));
        
        [pvalue(el,1),NS1(el,1)]=ns_detect(SP,T); % original function from paper (supplementary material)
    end
    S1 = NS1 < 5; % if NS<5 then stationary
    RESOLUTION = struct('SP_pos',SP_pos, 'SP_val',SP_val, 'S1',S1);

RES = RESOLUTION;
end