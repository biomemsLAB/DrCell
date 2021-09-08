function [] = Cell2ToolConnect(SPc, FrameEnd)
%CELL2TOOLCONNECT Saves a Cell of SamplePositions as the needed format in
%                 folder named InputForToolConnect/
%
% [] = Cell2ToolConnect(SPc, FrameEnd)
%   SPc:          This data of sample positions will be converted.
%   FrameEnd:     
%
%   See also Matrix2Cell
    


    if(isdir('InputForToolConnect'))
        rmdir('InputForToolConnect','s')  % delete old data
    end
    mkdir('InputForToolConnect')
    
    N=numel(SPc);
    
    %eval(sprintf('CellFormat{%d}=BrainWaveFormat.Ch%02d_%02d;', i+(u-1)*N,u,i))
    for i=1:N
        eval(sprintf('fileID = fopen(''InputForToolConnect/_%04d.txt'',''w'');',i));
        %fprintf(fileID,'%1d \n',numel(SPc{i}));
        fprintf(fileID,'%12d \n',uint64(FrameEnd));
        if ~ isempty(SPc{i})
            fprintf(fileID,'%12d \n',uint64(SPc{i}));
        end
        fprintf(fileID,'%12d \n',uint64(0));
        fclose(fileID);
    end
    %CellFormat{i+(u-1)*N}=find(CellFormat{i+(u-1)*N}==1);       

    %save()
    
end

