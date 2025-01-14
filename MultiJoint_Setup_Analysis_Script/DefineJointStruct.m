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
        accelerations= squeeze(experiment_data.joints_state.accelerations.data);
end
function velocities = GetJointVelocities(experiment_data)
    % This function retrieves the joints velocity data. 
        velocities = squeeze(experiment_data.joints_state.velocities.data);
end
function positions = GetJointPositions(experiment_data)
    % This function retrieves the joints position data. 
        positions = squeeze(experiment_data.joints_state.positions.data);
end