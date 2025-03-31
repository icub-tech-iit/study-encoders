classdef Experiment
    properties
        Data % Store the loaded experiment data
    end
    
    methods
        function obj = LoadData(obj, data_path)
            % Load data from the specified path
            loaded_data = load(data_path);
            field_name = fieldnames(loaded_data);
            test_name = field_name{1};
            obj.Data = loaded_data.(test_name);
        end

        function description_list = GetDescriptionList(obj)
            % Retrieve the description list from experiment data
            description_list = obj.Data.description_list;
        end

        function joint_number = GetNumberOfJoints(obj)
            % Retrieve the number of joints of the setup
            joint_number = length(obj.Data.description_list);
        end
        
        function obj = setReductionRatios(obj, varargin)
            % Set the gearboxes reduction ratio for all joints
            joint_number = obj.GetNumberOfJoints();
            
            if ~isempty(varargin)
                reduction_ratios = cell2mat(varargin);
                if length(reduction_ratios) < joint_number
                    obj.Data.reduction_ratios = obj.HandleMissingGearboxes(reduction_ratios, joint_number);
                elseif length(reduction_ratios) > joint_number
                    obj.Data.reduction_ratios = obj.HandleExtraGearboxes(reduction_ratios, joint_number);
                else
                    obj.Data.reduction_ratios = reduction_ratios;
                end
            else
                % Initialize the field if it's not already present
                if ~isfield(obj.Data, 'reduction_ratios')
                    obj.Data.reduction_ratios = ones(1, joint_number); % Default to 1 if not provided
                end
                warning("No gearbox value found. The struct field will not be initialized.")
            end
        end
        
        function reduction_ratios = HandleExtraGearboxes(obj, reduction_ratios, joint_number)
            warning("Too many reduction ratios. Dropping extra arguments.");
            % Trim the extra reduction ratios
            reduction_ratios = reduction_ratios(1:joint_number);
        end
        
        function reduction_ratios = HandleMissingGearboxes(obj, reduction_ratios, joint_number)
            warning("Missing reduction ratios. Automatically setting missing values to one.");
            % Add missing reduction ratios (set to 1)
            reduction_ratios(length(reduction_ratios)+1:joint_number) = 1;
        end

        %% New Methods

        function raw_data = GetRawData(obj)
            % Retrieve raw data from the experiment data (encoders for each joint)
            joint_number = obj.GetNumberOfJoints();
            % Since we have a motor + a joint encoder for each joint, the encoders number is 2*joint_number
            encoders_number = 2 * joint_number;
            % Length of the data (3rd dimension of the raw data)
            data_length = size(obj.Data.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data, 3);
            raw_data = zeros(encoders_number, data_length);
            for i = 1:joint_number
                % Assign data for each encoder (primary and secondary)
                raw_data(i:(i + 1), :) = ...
                    obj.Data.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data((3*i - 2):(3*i - 1), :);
            end
        end

        function [diagnostic_data, number_of_samples] = GetDiagnosticData(obj)
            % Retrieve diagnostic data (e.g., joint status information)
            diagnostic_field = obj.Data.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data;
            diagnostic_data = zeros(size(diagnostic_field, 1), size(diagnostic_field, 3));
            diagnostic_data = diagnostic_field(3:3:size(diagnostic_field, 1), :);
            number_of_samples = length(diagnostic_data);
        end

        function timestamps = GetTimestamps(obj)
            % Retrieve timestamps from the experiment data
            timestamps = obj.Data.joints_state.positions.timestamps(1, :);
            timestamps = timestamps - timestamps(1); % Normalize to start from zero
        end
    end
end
