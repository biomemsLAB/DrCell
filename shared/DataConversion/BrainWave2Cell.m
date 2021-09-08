function [CellFormat, SampleRate, StartFrame, StopFrame] = BrainWave2Cell( BrainWaveFormat, mode )
% BRAINWAVE2CELL  Converts the output format of BrainWave 
% to MATLAB Cell (SamplePositions).
%
% [OutputCell, SampleRate, StartFrame, StopFrame] = BRAINWAVE2CELL (BWF, mode)
%   OutputCell:     Here the Data-Cell will be saved 
%   SampleRate:     The SampleRate of the measured signal
%   StartFrame:     Number of samples where measurement beginns
%   StopFrame:      Number of samples where measurement ends
%   BWF:            Output-Format of the software BrainWaveX
%   mode:           'SpikeTrains' for exported SpikeTrains
%                   'RawData' for exported raw data 


SampleRate=BrainWaveFormat.SamplingFrequency;
StartFrame=BrainWaveFormat.StartFrame;  % in Samples, usually 0
StopFrame =BrainWaveFormat.StopFrame;   % in Samples

N=64;   % Electrodes per row (64 at 3Brain HD MEA)
CellFormat=cell(N*N,1);

if strcmp(mode, 'SpikeTrains')
    for i=1:N % Rows
        for u=1:N  % Columns
            if ~(i<=1 && u<=1) 
                eval(sprintf('CellFormat{%d}=BrainWaveFormat.Ch%02d_%02d;', i+(u-1)*N,u,i))
                CellFormat{i+(u-1)*N}=find(CellFormat{i+(u-1)*N}==1);       
            end
        end
    end    
elseif strcmp(mode, 'RawData')
    for i=1:N % Rows
        for u=1:N  % Columns
                CellFormat{i+(u-1)*N}=BrainWaveFormat.RawMatrix(i,u,:);       
        end
    end    
else    
    fprintf('The choosen mode does not exist, please use help.\n')
end





end

