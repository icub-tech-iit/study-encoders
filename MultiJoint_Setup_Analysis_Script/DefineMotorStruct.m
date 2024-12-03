function motors = DefineMotorStruct(experiment_data)
    % Takes the data and puts them in a "motor" struct.
    % The struct contains the data for each motor.
    motors.description_list = GetDescriptionList(experiment_data);
    motors.accelerations = GetMotorAccelerations(experiment_data);  
    motors.velocities = GetMotorVelocities(experiment_data);
    motors.positions = GetMotorPositions(experiment_data);
    motors.currents = GetMotorCurrents(experiment_data);
    motors.PWM = GetMotorPWM(experiment_data);
end
%% Get motors data
function description_list = GetDescriptionList(experiment_data)
    description_list = experiment_data.description_list;
end
function accelerations = GetMotorAccelerations(experiment_data)
    accelerations = squeeze(experiment_data.motors_state.accelerations.data)';
end
function velocities = GetMotorVelocities(experiment_data)
    velocities = squeeze(experiment_data.motors_state.velocities.data)';
end
function positions = GetMotorPositions(experiment_data)
    positions = squeeze(experiment_data.motors_state.positions.data)';
end  
function currents = GetMotorCurrents(experiment_data)
    currents = squeeze(experiment_data.motors_state.currents.data)';
end
function pulse_width_modulation = GetMotorPWM(experiment_data)
    pulse_width_modulation = squeeze(experiment_data.motors_state.PWM.data)';
end