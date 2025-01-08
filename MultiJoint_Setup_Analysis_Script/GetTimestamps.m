function timestamps = GetTimestamps(experiment_data)
    % Retrieve timestamps    
    timestamps = experiment_data.joints_state.positions.timestamps(1, :);
    timestamps = timestamps - timestamps(1);
end