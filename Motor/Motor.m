classdef Motor
    properties
        DescriptionList
        Accelerations
        Velocities
        Positions
        Currents
        PWM
    end
    
    methods
        function obj = Motor(experiment)
            % Constructor that initializes the motor properties using experiment data
            obj = obj.DefineMotorStruct(experiment);
        end
        
        function obj = DefineMotorStruct(obj, experiment)
            % Takes the data and assigns motor properties
            obj.DescriptionList = experiment.GetDescriptionList();
            obj.Accelerations = obj.GetMotorAccelerations(experiment.Data);
            obj.Velocities = obj.GetMotorVelocities(experiment.Data);
            obj.Positions = obj.GetMotorPositions(experiment.Data);
            obj.Currents = obj.GetMotorCurrents(experiment.Data);
            obj.PWM = obj.GetMotorPWM(experiment.Data);
        end
        
        function accelerations = GetMotorAccelerations(~, experiment_data)
            accelerations = squeeze(experiment_data.motors_state.accelerations.data)';
        end
        
        function velocities = GetMotorVelocities(~, experiment_data)
            velocities = squeeze(experiment_data.motors_state.velocities.data)';
        end
        
        function positions = GetMotorPositions(~, experiment_data)
            positions = squeeze(experiment_data.motors_state.positions.data)';
        end
        
        function currents = GetMotorCurrents(~, experiment_data)
            currents = squeeze(experiment_data.motors_state.currents.data)';
        end
        
        function pulse_width_modulation = GetMotorPWM(~, experiment_data)
            pulse_width_modulation = squeeze(experiment_data.motors_state.PWM.data)';
        end
    end
end
