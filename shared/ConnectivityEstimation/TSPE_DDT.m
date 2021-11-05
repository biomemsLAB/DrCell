function [FM]=TSPE_DDT(CM, n)

if nargin == 1
    n = 1
end

%Beispielmatrix
%CM = [0, 3, 5, 7, 2; 5, 0, 4, 6, 3; 2, 4, 0, 4, 7; 5, 3, 2, 0, 5; 2, 1, 4, 2, 0]


%HT-Algo
CM1 = nonzeros(CM);
std_CM = std(CM1);
mean_CM = mean(CM1);
hard_treshold_CM = mean_CM + n * std_CM;
T1CM = CM;
T1CM(T1CM < hard_treshold_CM) = 0; % 0 oder nan
%

%DDT

RM = CM - T1CM;
TM = zeros(size(RM));

for i=1:size(RM, 1)
    for j=1:size(RM, 2)
        iRow = RM(i, :);
        iRow(1, j) = 0;
        std_iRow = std(nonzeros(iRow));
        mean_iRow = mean(nonzeros(iRow));
        TM(i, j) = mean_iRow + n * std_iRow ;  
    end
end

T2CM = RM;
T2CM(RM <= TM) = 0;
FM = T1CM + T2CM;
end