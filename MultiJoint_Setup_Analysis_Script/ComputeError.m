function error = ComputeError(joints, motors)
    % This function computes the difference between the measurements
    % of the high-speed shaft encoder and the low-speed shaft encoder.
    gear_ratios = joints.reduction_ratios';
    if all(motors.positions(2, :) == 0)
        motors.positions(2, :) = motors.positions(1, :);
    end
    motor_to_joint_position = motors.positions./gear_ratios;
    error_offset = joints.positions - motor_to_joint_position;
    error = error_offset - mean(error_offset, 2);
end