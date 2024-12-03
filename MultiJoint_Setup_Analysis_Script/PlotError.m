function PlotError(experiment_data)
    joints = DefineJointStruct(experiment_data);
    joints = SetReductionRatios(joints, 100, 100);
    number_of_joints = length(joints.reduction_ratios);

    motors = DefineMotorStruct(experiment_data);

    error = ComputeError(joints, motors);


    if number_of_joints == 1
        figure(101)
        plot(GetTimestamps(experiment_data), error(1, :))
        title ('Joint 0')

    elseif number_of_joints == 2
        figure(101)
        subplot(2,1,1)
        plot(GetTimestamps(experiment_data), error(1, :))
        title ('Joint 0 (AMO)')
        subplot(2,1,2)
        plot(GetTimestamps(experiment_data), error(2, :))
        title('Joint 1 (AKSIM)')
        legend('Error 0', 'Error 1')
        sgtitle('Angular position accuracy')


    elseif number_of_joints == 3
            % ᨐᵐᵉᵒʷ
    end

end