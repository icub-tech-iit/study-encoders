classdef Experiment < handle
    % Loads experimental data
    properties (Access = public)
        Data__
        StartTime % Time in seconds, [] if not set
        EndTime   % Time in seconds, [] or 'end' if not set
        StartIndex__ % Index, calculated based on StartTime
        EndIndex__   % Index, calculated based on EndTime
    end

    properties (Access = private, Dependent)
        ExperimentDuration
        MeanSampleTime
    end

    methods
        function duration = get.ExperimentDuration(obj)
            if ~isempty(obj.Data__) && isfield(obj.Data__, 'joints_state') && isfield(obj.Data__.joints_state, 'positions') && isfield(obj.Data__.joints_state.positions, 'timestamps')
                duration = obj.Data__.joints_state.positions.timestamps(1, :);
            else
                duration = [];
            end
        end

        function ts = get.MeanSampleTime(obj)
            if length(obj.ExperimentDuration) > 1
                ts = mean(diff(obj.ExperimentDuration));
            else
                ts = NaN;
            end
        end

        function obj = LoadData(obj, dataPath)
            loadedData = load(dataPath);
            fn = fieldnames(loadedData);
            if ~isempty(fn)
                obj.Data__ = loadedData.(fn{1});
                obj.updateIndices();
            else
                error('Loaded data file is empty.');
            end
        end

        function set.StartTime(obj, value)
            if isnumeric(value) && isscalar(value) && value >= 0
                obj.StartTime = value;
                obj.updateIndices();
            elseif isempty(value)
                warning('StartTime is empty, setting it to 0.');
                obj.StartTime = [];
                obj.updateIndices();
            else
                warning('StartTime must be a non-negative scalar numeric value or empty.');
                obj.StartTime = [];
                obj.updateIndices();
            end
        end

        function set.EndTime(obj, value)
            if isnumeric(value) && isscalar(value) && value >= 0
                obj.EndTime = value;
                obj.updateIndices();
            elseif ischar(value) && strcmp(value, 'end')
                obj.EndTime = 'end';
                obj.updateIndices();
            elseif isempty(value)
                warning('EndTime is empty. Loading the whole experiment.');
                obj.EndTime = [];
                obj.updateIndices();
            else
                warning('EndTime must be a non-negative scalar numeric value, "end", or empty.');
                obj.EndTime = [];
                obj.updateIndices();
            end
        end

        function updateIndices(obj)
            if isempty(obj.Data__) || isempty(obj.ExperimentDuration) || isnan(obj.MeanSampleTime)
                obj.StartIndex__ = [];
                obj.EndIndex__ = [];
                return;
            end

            if isempty(obj.StartTime)
                obj.StartIndex__ = 1;
            else
                calculatedStart = round(obj.StartTime / obj.MeanSampleTime) + 1;
                obj.StartIndex__ = max(1, calculatedStart);
            end

            dataLength = length(obj.ExperimentDuration);
            
            if isempty(obj.EndTime) || (ischar(obj.EndTime) && strcmp(obj.EndTime, 'end'))
                obj.EndIndex__ = dataLength;
            elseif isnumeric(obj.EndTime)
                calculatedEnd = round(obj.EndTime / obj.MeanSampleTime) + 1;
                obj.EndIndex__ = min(dataLength, max(obj.StartIndex__, calculatedEnd));
            else
                obj.EndIndex__ = dataLength; % Default to end on invalid EndTime
            end
        end

        function descList = GetDescriptionList(obj)
            if ~isempty(obj.Data__) && isfield(obj.Data__, 'description_list')
                descList = obj.Data__.description_list;
            else
                descList = {};
            end
        end

        function nJoints = GetNumberOfJoints(obj)
            descList = obj.GetDescriptionList();
            nJoints = numel(descList);
        end

        function setReductionRatios(obj, varargin)
            % Sets gearbox reduction ratios for each joint.
            % If fewer ratios are provided than joints, missing values default to 1.
            % if more are provided, the extras are discarded.

            nJoints = obj.GetNumberOfJoints();
            ratios = cell2mat(varargin);
            if isempty(ratios)
                warning('No gearbox values provided. Reduction ratios remain uninitialized.');
                return;
            end
            if numel(ratios) < nJoints
                warning('Missing ratios: setting unspecified ratios to 1.');
                ratios(end+1:nJoints) = 1;
            elseif numel(ratios) > nJoints
                warning('Too many ratios: extra values will be dropped.');
                ratios = ratios(1:nJoints);
            end
            if ~isempty(obj.Data__)
                obj.Data__.reduction_ratios = ratios;
            else
                warning('Data not loaded. Cannot set reduction ratios.');
            end
        end

        function rawData = GetRawData(obj)
            if isempty(obj.Data__) || ~isfield(obj.Data__.raw_data_values, 'eoprot_tag_mc_joint_status_addinfo_multienc') || isempty(obj.StartIndex__) || isempty(obj.EndIndex__)
                rawData = [];
                return;
            end
            rawArray = obj.Data__.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data;
            nJoints = obj.GetNumberOfJoints();
            encodersNum = 2 * nJoints;
            rawData = zeros(encodersNum, obj.EndIndex__ - obj.StartIndex__ + 1);
            for i = 1:nJoints
                indices = obj.StartIndex__:obj.EndIndex__;
                rawData(i*2-1:i*2, :) = rawArray((3*i-2):(3*i-1), indices);
            end
        end

        function [diagData, nSamples] = GetDiagnosticData(obj)
            if isempty(obj.Data__) || ~isfield(obj.Data__.raw_data_values, 'eoprot_tag_mc_joint_status_addinfo_multienc') || isempty(obj.StartIndex__) || isempty(obj.EndIndex__)
                diagData = [];
                nSamples = 0;
                return;
            end
            diagArray = obj.Data__.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data;
            diagData = diagArray(3:3:size(diagArray,1), obj.StartIndex__:obj.EndIndex__);
            nSamples = size(diagData, 2);
        end

        function timestamps = GetTimestamps(obj)
            if isempty(obj.Data__) || ~isfield(obj.Data__, 'joints_state') || ~isfield(obj.Data__.joints_state, 'positions') || ~isfield(obj.Data__.joints_state.positions, 'timestamps') || isempty(obj.StartIndex__) || isempty(obj.EndIndex__)
                timestamps = [];
                return;
            end
            allTimestamps = obj.Data__.joints_state.positions.timestamps(1, :);
            timestamps = allTimestamps(obj.StartIndex__:obj.EndIndex__);
            if ~isempty(timestamps)
                timestamps = timestamps - timestamps(1);
            end
        end
    end
end