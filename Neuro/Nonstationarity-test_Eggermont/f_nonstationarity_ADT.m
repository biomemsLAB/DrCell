function RES = f_nonstationarity_ADT(Zn)
%
%
    % This function delivers the calculeted value of the Anderson-Darling
    % Test (ADT) applied on one normalized ECDF Spike Train.
    %
    % Input: 
    %   Zn -> ECDF input normalized (stepfunction)
    %   N  -> Number of Spikez
    %
    % Output:
    %   AN -> Comparison of the area between the ECDF and its uniform law
    %
    % ©AR
    
sum_AN = 0;
N = length(Zn);
for n = 1:N
    sum_ANn = (2*n-1)*log(Zn(n) * (1 - Zn(N-n+1)));
    sum_AN = sum_AN + sum_ANn;
end
AN = - N - (1/N)*sum_AN; 
RES = AN;
end