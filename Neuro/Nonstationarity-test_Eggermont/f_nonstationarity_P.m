function RES = f_nonstationarity_P(AN)

% calculate P out of AN

format long
if AN<2
    P1 = (1./sqrt(AN));
    P2 = exp(-1.2337141./AN);
    P3 = (2.00012+(0.247105-(0.0649821-(0.0347962-(0.0116720-0.00168691*AN)*AN)*AN)*AN)*AN);
    P = P1*P2*P3;
else
    P = exp(-exp(1.0776-(2.30695-(0.43424-(0.082433-(0.008056-0.0003146*AN)*AN)*AN)*AN)*AN));
end
RES = P;