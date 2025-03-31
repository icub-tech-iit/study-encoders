classdef Motor < handle
    %   Represents motor-specific data extracted from an Experiment object,
    %   including kinematic and electrical measurements.
    
    properties (Access = public)
        DescriptionList
        Accelerations
        Velocities
        Positions
        Currents
        PWM
    end
    
    methods
        function obj = Motor(exp)
            % Motor Constructor extracts motor data from an Experiment instance.
            
            obj.DescriptionList = exp.GetDescriptionList();
            obj.Accelerations = obj.GetMotorAccelerations(exp.Data);
            obj.Velocities = obj.GetMotorVelocities(exp.Data);
            obj.Positions = obj.GetMotorPositions(exp.Data);
            obj.Currents = obj.GetMotorCurrents(exp.Data);
            obj.PWM = obj.GetMotorPWM(exp.Data);
        end
        
        function acc = GetMotorAccelerations(~, data)
            acc = squeeze(data.motors_state.accelerations.data)';
        end
        
        function vel = GetMotorVelocities(~, data)
            vel = squeeze(data.motors_state.velocities.data)';
        end
        
        function pos = GetMotorPositions(~, data)
            pos = squeeze(data.motors_state.positions.data)';
        end
        
        function curr = GetMotorCurrents(~, data)
            curr = squeeze(data.motors_state.currents.data)';
        end
        
        function pwmVal = GetMotorPWM(~, data)
            pwmVal = squeeze(data.motors_state.PWM.data)';
        end
    end
end
