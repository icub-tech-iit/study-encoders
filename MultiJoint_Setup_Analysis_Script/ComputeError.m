function error = ComputeError(joints, motors)
    % This function computes the difference between the measurements
    % of the high-speed shaft encoder and the low-speed shaft encoder.
    joint_positions = joints.positions;
    motor_positions = motors.positions;
    gear_ratios = joints.reduction_ratios';
    motor_to_joint_position = motor_positions./gear_ratios;
    error_offset = joint_positions - motor_to_joint_position;
    error = error_offset - mean(error_offset, 2);
end