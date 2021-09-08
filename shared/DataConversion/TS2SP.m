function [ SP ] = TS2SP( TS, fs, mode )
%TS2SP Converts Time-Sampled Signal to Sample-Positioned Signal
%
% [ SP ] = TS2SP( TS, fs, mode )
%   SP:     Here the sample positions will be saved.
%   TS:     This data of time samples will be converted.
%   fs:     Samplingfrequency of the data.
%   mode:   'matrix'    MATLAB-Matrix-type of data.
%           'cell'      MATLAB-Cell-type of data.
%
%   See also SP2TS



if strcmp(mode, 'matrix')
	SP=TS.*fs;
elseif strcmp(mode, 'cell')
	SP=cell(numel(TS),1);
	for i=1:numel(TS)
        SP{i}=TS{i}.*fs;
	end 
else             
    fprintf('The choosen mode does not exist, please use help.\n')
end
            
end

