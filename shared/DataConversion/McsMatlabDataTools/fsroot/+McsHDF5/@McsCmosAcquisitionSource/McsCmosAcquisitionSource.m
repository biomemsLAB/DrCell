classdef McsCmosAcquisitionSource < handle
% Stores the contents of the Acquisition data source
%
% The different streams present in the Acquisition source are sorted into
% the {Channel,Event,Sensor,Spike}Stream fields where they are stored as
% cell arrays.
%
% (c) 2017 by Multi Channel Systems MCS GmbH

    properties (SetAccess = protected)
        ChannelStream = {}; % (cell array) McsAnalogStream objects, one for each channel stream
        EventStream = {};   % (cell array) McsEventStream objects, one for each event stream
        SensorStream = {};  % (cell array) McsFrameStream objects, one for each sensor stream
        SpikeStream = {};   % (cell array) McsCmosSpikeStream objects, one for each spike stream
        
        % Info - (struct) Information about the stream
        % The fields depend on the stream type and hold information about
        % each channel/entity in the stream, such as their IDs, labels,
        % etc.
        Info                
    end
    
    properties (Access = private)
        KnownStreams
    end
    
    methods
        function src = McsCmosAcquisitionSource(filename, acqStruct, cfg)
        % Reads an Acquisition source object inside a HDF5 file
        %
        % function src = McsCmosAcquisitionSource(filename, acqStruct, cfg)
        %
        % Input:
        %   filename    -   (string) Name of the HDF5 file
        %   acqStruct   -   (struct) The Acquisition subtree of the
        %                   structure generated by the h5info command
        %   cfg         -   (optional) configuration structure, containes
        %                   one or more of the following fields:
        %                   'dataType': The type of the data, can be one of
        %                   'double' (default), 'single' or 'raw'. For 'double'
        %                   and 'single' the data is converted to meaningful
        %                   units, while for 'raw' no conversion is done and
        %                   the data is kept in ADC units. This uses less
        %                   memory than the conversion to double, but you might
        %                   have to convert the data prior to analysis, for
        %                   example by using the getConvertedData function.
        %                   'timeStampDataType': The type of the time stamps,
        %                   can be either 'int64' (default) or 'double'. Using
        %                   'double' is useful for older Matlab version without
        %                   int64 arithmetic.
        %
        % Output:
        %   src         -   A McsCMosAcquisitionSource object
            if exist('h5info')
                mode = 'h5';
            else
                mode = 'hdf5';
            end

            dataAttributes = acqStruct.Attributes;
            for fni = 1:length(dataAttributes)
                [name, value] = McsHDF5.McsH5Helper.AttributeNameValueForStruct(dataAttributes(fni), mode);
                src.Info.(name) = value;
            end
            
            knownStreamTypes = McsHDF5.McsCmosAcquisitionSource.GetKnownStreamTypes();
            cfg.From = src.Info.From;
            cfg.To = src.Info.To;
            for gidx = 1:length(acqStruct.Groups)
                groupname = acqStruct.Groups(gidx).Name;
                
                typeID = McsHDF5.McsH5Helper.GetFromAttributes(acqStruct.Groups(gidx), 'ID.TypeID', mode);
                if ~isempty(typeID)
                    if knownStreamTypes.isKey(typeID)
                        type = knownStreamTypes(typeID);
                        src = McsHDF5.McsCmosAcquisitionSource.ConstructStream(acqStruct.Groups(gidx), type, src, filename, cfg);
                    else
                        warning(['Unknown stream: ' groupname]);
                    end
                else 
                    warning(['Unknown type: ' groupname]);
                end
            end
        end
    end
    
    methods (Static, Access = private)
        function streams = GetKnownStreamTypes()
            streams = containers.Map(...
            {...
                '9217aeb4-59a0-4d7f-bdcd-0371c9fd66eb', ...
                '09f288a5-6286-4bed-a05c-02859baea8e3', ...
                '15e5a1fe-df2f-421b-8b60-23eeb2213c45', ...
                '26efe891-c075-409b-94f8-eb3a7dd68c94'
            },...
            {
                'ChannelStream', ...
                'EventStream', ...
                'SensorStream', ...
                'SpikeStream'
            });
        end
        
        function src = ConstructStream(group, type, src, filename, cfg)
            if strcmp(type, 'ChannelStream')
                strm = McsHDF5.McsAnalogStream(filename, group, 'CMOS-MEA', cfg);
                src.ChannelStream = [src.ChannelStream {strm}];
            elseif strcmp(type, 'EventStream')
                strm = McsHDF5.McsEventStream(filename, group, 'CMOS-MEA', cfg);
                src.EventStream = [src.EventStream {strm}];
            elseif strcmp(type, 'SensorStream')
                strm = McsHDF5.McsFrameStream(filename, group, 'CMOS-MEA', cfg);
                src.SensorStream = [src.SensorStream {strm}];
            elseif strcmp(type, 'SpikeStream')
                strm = McsHDF5.McsCmosSpikeStream(filename, group, cfg);
                src.SpikeStream = [src.SpikeStream {strm}];
            end
        end
    end
end