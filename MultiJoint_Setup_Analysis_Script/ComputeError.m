function error = ComputeError(joints, motors)
    % This function computes the difference between the measurements
    % of the high-speed shaft encoder and the low-speed shaft encoder.
    gear_ratios = joints.reduction_ratios';
    number_of_joints = length(gear_ratios);
    if number_of_joints == 2
        if all(motors.positions(2, :) == 0)
            motors.positions(2, :) = motors.positions(1, :);
        elseif number_of_joints == 3
            % ᨐᵐᵉᵒʷ
        end
    end    
    motor_to_joint_position = motors.positions./gear_ratios;
    error_offset = joints.positions - motor_to_joint_position;
    error = error_offset; %error_offset - mean(error_offset, 2);
end