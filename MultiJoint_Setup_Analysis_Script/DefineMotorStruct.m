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
function joint_number = GetNumberOfJoints(experiment_data)
    % Retrieve the number of joints of the setup
    joint_number = length(experiment_data.description_list);
end
function description_list = GetDescriptionList(experiment_data)
    description_list = experiment_data.description_list;
end
function accelerations = GetMotorAccelerations(experiment_data)
    % This function retrieves the motors acceleration data.
    joint_number = GetNumberOfJoints(experiment_data);
    data_length = size(experiment_data.motors_state.accelerations.data, 3);
    accelerations = zeros(joint_number, data_length);
        for i = 1:joint_number
            accelerations(i, :) = [experiment_data.motors_state.accelerations.data(i, :)];
        end
end
function velocities = GetMotorVelocities(experiment_data)
    % This function retrieves the motors velocity data.
    joint_number = GetNumberOfJoints(experiment_data);
    data_length = size(experiment_data.motors_state.velocities.data, 3);
    velocities = zeros(joint_number, data_length);
    for i = 1:joint_number
        velocities(i, :) = [experiment_data.motors_state.velocities.data(i, :)];
    end
end
function positions = GetMotorPositions(experiment_data)
    % This function retrieves the motors position data.
    joint_number = GetNumberOfJoints(experiment_data);
    data_length = size(experiment_data.motors_state.positions.data, 3);
    positions = zeros(joint_number, data_length);
    for i = 1:joint_number
        positions(i, :) = [experiment_data.motors_state.positions.data(i, :)];
    end
end  
function currents = GetMotorCurrents(experiment_data)
    % This function retrieves the motors current absorption data.
    joint_number = GetNumberOfJoints(experiment_data);
    data_length = size(experiment_data.motors_state.currents.data, 3);
    currents = zeros(joint_number, data_length);
    for i = 1:joint_number
        currents(i, :) = [experiment_data.motors_state.currents.data(i, :)];
    end
end
function pulse_width_modulation = GetMotorPWM(experiment_data)
    % This function retrieves the motors PWM data.
    joint_number = GetNumberOfJoints(experiment_data);
    data_length = size(experiment_data.motors_state.PWM.data, 3);
    pulse_width_modulation = zeros(joint_number, data_length);
    for i = 1:joint_number
        pulse_width_modulation(i, :) = [experiment_data.motors_state.PWM.data(i, :)];
    end
end