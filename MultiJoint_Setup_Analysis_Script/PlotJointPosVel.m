function PlotJointPosVel(experiment_data)
    joints = DefineJointStruct(experiment_data);
    figure(99)
    subplot(2,1,1)
    plot(GetTimestamps(experiment_data), joints.positions)
    title('Joint position')
    legend('Joint 0 (AMO)', 'Joint 1 (AKSIM)')
    subplot(2,1,2)
    plot(GetTimestamps(experiment_data), joints.velocities)
    title('Joint velocity')
    legend('Joint 0 (AMO)', 'Joint 1 (AKSIM)')
    sgtitle ('Joints position & Velocitiy')
end