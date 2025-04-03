classdef Joint < handle
    %   Represents joint-specific data extracted from an Experiment object,
    %   including kinematic data and gearbox reduction ratios.
    
    properties (Access = public)
        DescriptionList
        Accelerations
        Velocities
        Positions
        ReductionRatios
    end
    
    methods
        function obj = Joint(exp)
            % Joint constructor extracts joint data from an Experiment instance.            
            obj.DescriptionList = exp.GetDescriptionList();
            obj.Accelerations = obj.GetJointAccelerations(exp.Data);
            obj.Velocities = obj.GetJointVelocities(exp.Data);
            obj.Positions = obj.GetJointPositions(exp.Data);
            if isfield(exp.Data, 'reduction_ratios')
                obj.ReductionRatios = exp.Data.reduction_ratios;
            else
                obj.ReductionRatios = ones(1, numel(obj.DescriptionList));
            end
        end
        
        function acc = GetJointAccelerations(~, data)
            acc = squeeze(data.joints_state.accelerations.data)';
        end
        
        function vel = GetJointVelocities(~, data)
            vel = squeeze(data.joints_state.velocities.data)';
        end
        
        function pos = GetJointPositions(~, data)            
            pos = squeeze(data.joints_state.positions.data)';
        end
    end
end
