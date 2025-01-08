function joints = DefineJointStruct(experiment_data)
    % Takes the data and puts them in a "joint" struct.
    % The struct contains the data for each joint.
    joints.description_list = GetDescriptionList(experiment_data);
    joints.accelerations = GetJointAccelerations(experiment_data);  
    joints.velocities = GetJointVelocities(experiment_data);
    joints.positions = GetJointPositions(experiment_data);
end
%% Get joints data
function accelerations = GetJointAccelerations(experiment_data)
    % This function retrieves the joints acceleration data.    
    joint_number = GetNumberOfJoints(experiment_data);
    data_length = size(experiment_data.joints_state.accelerations.data, 3);
    accelerations = zeros(joint_number, data_length);
    for i = 1:joint_number
        accelerations(i, :) = [experiment_data.joints_state.accelerations.data(i, :)];
    end
end
function velocities = GetJointVelocities(experiment_data)
    % This function retrieves the joints velocity data. 
    joint_number = GetNumberOfJoints(experiment_data);
    data_length = size(experiment_data.joints_state.velocities.data, 3);
    velocities = zeros(joint_number, data_length);
    for i = 1:joint_number
        velocities(i, :) = [experiment_data.joints_state.velocities.data(i, :)];
    end
end
function positions = GetJointPositions(experiment_data)
    % This function retrieves the joints position data. 
    joint_number = GetNumberOfJoints(experiment_data);
    data_length = size(experiment_data.joints_state.positions.data, 3);
    positions = zeros(joint_number, data_length);
    for i = 1:joint_number
        positions(i, :) = [experiment_data.joints_state.positions.data(i, :)];
    end
end