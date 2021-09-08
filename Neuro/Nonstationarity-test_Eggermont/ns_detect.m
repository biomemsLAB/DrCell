function [pvalue,NS]=ns_detect(tn,T)
% Test for nonstationarity detection in a spike train.
%
%USE : [pvalue,test_times]=ns_detect(tn,T)
%
%INPUT :  tn - spike times
%         T - length of recording
%
%OUTPUT : pvalue - pvalue of the test
%         NS - surprise statistic
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
 
%% Checking input
if nargin<2,
    error('Second argument missing. Please, specify T');
end;
 
%% Statistics and outputs
Zn=tn(:)/T;
 
if Zn(end)>=1,
    error('T must be strictly greater than the time arrival of the last spike');
end;
 
N=length(Zn);
 
AN=-N-1/N*(2*(1:N)-1)*log(Zn.*(1-Zn(end:-1:1)));
pvalue=1-ADinf(AN);
if pvalue<10^-5,
    warning('pvalue<10^-5,limit of accuracy exceeded, pvalue and NS values may not be precise');
end;
NS=-log(pvalue);
