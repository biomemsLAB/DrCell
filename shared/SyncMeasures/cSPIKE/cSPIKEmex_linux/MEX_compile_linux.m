%% Compile file for MEX functions. 
% The file compiles the MEXes and the C++ classes mplementing the MEXes.

path_full=mfilename('fullpath'); % get path of this script
[path,~] = fileparts(path_full); % separate path from filename
cd(path)

%mex ('CFLAGS="\$CFLAGS -std=c99"', 'mexAdaptiveISIDistance.cpp', 'Spiketrain.cpp', 'DataReader.cpp', 'Spiketrains.cpp', 'Pair.cpp', 'ISIProfile.cpp', 'SPIKEProfile.cpp')

%% Distance measure functions
mex -Dchar16_t=uint16_T mexAdaptiveISIDistance.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp

mex -Dchar16_t=uint16_T mexAdaptiveSPIKEDistance.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp

mex -Dchar16_t=uint16_T mexAdaptiveSPIKESynchro.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp

mex -Dchar16_t=uint16_T mexAdaptiveRateIndependentSPIKEDistance.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp

%% Matrix functions
mex -Dchar16_t=uint16_T mexAdaptiveISIDistanceMatrix.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp

mex -Dchar16_t=uint16_T mexAdaptiveSPIKEDistanceMatrix.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp


%% Profile functions
mex -Dchar16_t=uint16_T mexAdaptiveISIDistanceProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp

mex -Dchar16_t=uint16_T mexAdaptiveSPIKEDistanceProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp

mex -Dchar16_t=uint16_T mexAdaptiveSPIKESynchroProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
