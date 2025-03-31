classdef Joint
    properties
        DescriptionList
        Accelerations
        Velocities
        Positions
        ReductionRatios
    end
    
    methods
        function obj = Joint(experiment)
            % Constructor that initializes the joint properties using experiment data
            obj = obj.DefineJointStruct(experiment);
            % Assign the reduction ratios from the Experiment object
            obj.ReductionRatios = experiment.Data.reduction_ratios;
        end
        
        function obj = DefineJointStruct(obj, experiment)
            % Takes the data and assigns joint properties
            obj.DescriptionList = experiment.GetDescriptionList();
            obj.Accelerations = obj.GetJointAccelerations(experiment.Data);
            obj.Velocities = obj.GetJointVelocities(experiment.Data);
            obj.Positions = obj.GetJointPositions(experiment.Data);
        end
        
        function accelerations = GetJointAccelerations(~, experiment_data)
            accelerations = squeeze(experiment_data.joints_state.accelerations.data)';
        end
        
        function velocities = GetJointVelocities(~, experiment_data)
            velocities = squeeze(experiment_data.joints_state.velocities.data)';
        end
        
        function positions = GetJointPositions(~, experiment_data)
            positions = squeeze(experiment_data.joints_state.positions.data)';
        end
    end
end
