function [CellFormat] = Matrix2Cell(MatrixFormat)
%MATRIX2CELL Converts a Matrix to Cell format
%
% [CellFormat] = Matrix2Cell(MatrixFormat)
%   CellFormat:     Here the Data-Cell will be saved.
%   MatrixFormat:   This Matrix will be converted.
    
CellFormat=cell(size(MatrixFormat(1,:)));
N=numel(CellFormat);
for i=1:N
	%CellFormat{i}=MatrixFormat(any(~isnan(MatrixFormat(:,i)),2),i);
    CellFormat{i}=MatrixFormat(MatrixFormat(:,i)~=0 & ~isnan(MatrixFormat(:,i)),i);

    
                    % ignoring all NAN-values
                
end

end