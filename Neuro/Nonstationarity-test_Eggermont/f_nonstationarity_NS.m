function RES = f_nonstationarity_NS(P)
% Calculate indicator of Nonstaitionarity NS
p = 1-P;
NS = -log(p);
RES = NS;
