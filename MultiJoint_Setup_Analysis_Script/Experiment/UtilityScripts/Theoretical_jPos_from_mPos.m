function jPos_vs_mPos = Theoretical_jPos_from_mPos(my_motor_A, my_joint_A)
    % Removes offset, compute joint position from motor position
    jPos_from_mPos = (my_motor_A.Positions(:,1) - my_motor_A.Positions(1,1))/my_joint_A.ReductionRatios(1,1);
    % Compute the absolute difference between theoretical vs. measured joint position.
    jPos_vs_mPos = abs(jPos_from_mPos - my_joint_A.Positions(:,1));
end