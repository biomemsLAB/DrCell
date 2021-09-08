%% Utility - AN Cumulative distribution function computation
 
function [val]=ADinf(AN)
%Cumulative distribution function computation for the Anderson Darling statistics
%Values from Marsaglia G, Marsaglia J. Evaluating the Anderson-Darling Distribution.
%J. of Stat. Soft., 2004; 9(2):1-5.
if AN<2,
    val=1/sqrt(AN)*exp(-1.2337141/AN)*(2.00012+(0.247105-(0.0649821-(0.0347962-...
	(0.0116720-0.00168691*AN)*AN)*AN)*AN)*AN);
else
    val=exp(-exp(1.0776-(2.30695-(0.43424-(0.082433-(0.008056-...
	0.0003146*AN)*AN)*AN)*AN)*AN));
end
