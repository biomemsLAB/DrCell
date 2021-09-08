function [ TS ] = SP2TS( SP,fs,mode )
%SP2TS Converts Sample-Positioned Signal to Time-Sampled Signal
%
% [ TS ] = SP2TS( SP, fs, mode )
%   TS:     Here the time samples will be saved.
%   SP:     This data of sample positions will be converted.
%   fs:     Samplingfrequency of the data.
%   mode:   'matrix'    MATLAB-Matrix-type of data.
%           'cell'      MATLAB-Cell-type of data.
%
%   See also TS2SP




if strcmp(mode, 'matrix')
	TS=SP./fs;
elseif strcmp(mode, 'cell')
	TS=cell(numel(SP),1);
	for i=1:numel(SP)
        TS{i}=SP{i}./fs;
	end 
else    
    fprintf('The choosen mode does not exist, please use help.\n')
end

end