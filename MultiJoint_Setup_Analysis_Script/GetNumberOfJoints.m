function joint_number = GetNumberOfJoints(experiment_data)
    % Retrieve the number of joints of the setup
    joint_number = length(experiment_data.description_list);
end