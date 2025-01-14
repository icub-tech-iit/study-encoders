function PlotError(experiment_data)
    joints = DefineJointStruct(experiment_data);
    joints = SetReductionRatios(joints, 100, 100);
    
    motors = DefineMotorStruct(experiment_data);

    error = ComputeError(joints, motors);
    figure(101)
    subplot(2,1,1)
    plot(GetTimestamps(experiment_data), error(1, :))
    title ('Joint 0 (AMO)')
    subplot(2,1,2)
    plot(GetTimestamps(experiment_data), error(2, :))
    title('Joint 1 (AKSIM)')
    legend('Error 0', 'Error 1')
    sgtitle('Angular position accuracy')
end