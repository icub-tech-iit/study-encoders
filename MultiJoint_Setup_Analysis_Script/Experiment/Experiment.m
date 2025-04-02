classdef Experiment < handle
    % Loads experimental data

    properties (Access = public)
        Data
    end
    
    methods
        function obj = LoadData(obj, dataPath)
            % Loads the data from the file            
            loadedData = load(dataPath);
            fn = fieldnames(loadedData);
            obj.Data = loadedData.(fn{1});
        end
        
        function descList = GetDescriptionList(obj)
            % Returns the joint description list.
            descList = obj.Data.description_list;
        end
        
        function nJoints = GetNumberOfJoints(obj)
            % Returns the number of joints.            
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

            obj.Data.reduction_ratios = ratios;
        end
        
        function rawData = GetRawData(obj)
            % Returns rearranged raw encoder data.
          
            nJoints = obj.GetNumberOfJoints();
            encodersNum = 2 * nJoints;

            rawArray = obj.Data.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data;
            dataLen = size(rawArray, 3);
            disp(dataLen)
            rawData = zeros(encodersNum, dataLen);

            for i = 1:nJoints
                % Primary encoder: row (3*i-2), Secondary: row (3*i-1)
                rawData(i*2-1:i*2, :) = rawArray((3*i-2):(3*i-1), :);
            end
        end
        
        function [diagData, nSamples] = GetDiagnosticData(obj)
            % Retrieves diagnostic data and sample count.

            diagArray = obj.Data.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data;
            % For diagnostic data, every third row is used.
            diagData = diagArray(3:3:size(diagArray,1), :);
            nSamples = size(diagData, 2);
        end
        
        function timestamps = GetTimestamps(obj)
            % Retrieves normalized timestamps.           
            timestamps = obj.Data.joints_state.positions.timestamps(1, :);
            timestamps = timestamps - timestamps(1);
        end
    end
end