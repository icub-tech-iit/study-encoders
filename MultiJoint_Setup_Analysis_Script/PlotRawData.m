function PlotRawData(experiment_data)
    raw_data = GetRawData(experiment_data);
    number_of_joints = GetNumberOfJoints(experiment_data);

    if number_of_joints == 1
        figure(100)
        subplot(2, 1, 1)
        plot(GetTimestamps(experiment_data), raw_data(1,:), 'Color', "#e41a1c")
        subtitle('Primary encoder')
        subplot(2, 1, 2)
        plot(GetTimestamps(experiment_data), raw_data(2,:), 'Color', "#377eb8")
        subtitle('Secondary encoder')
        sgtitle('Raw data')

    elseif number_of_joints == 2
        figure(100)
        subplot(2,2,1)
        plot(GetTimestamps(experiment_data), raw_data(1,:), 'Color', "#e41a1c")
        subtitle('Joint 0 primary encoder')
        subplot(2,2,2)
        plot(GetTimestamps(experiment_data), raw_data(2,:), 'Color', "#377eb8")
        subtitle('Joint 1 primary encoder')
        subplot(2,2,3)
        plot(GetTimestamps(experiment_data), raw_data(3,:), 'Color', "#e41a1c")
        subtitle('Joint 0 secondary encoder')
        subplot(2,2,4)
        plot(GetTimestamps(experiment_data), raw_data(4,:), 'Color', "#377eb8")
        subtitle('Joint 1 secondary encoder')
        sgtitle('Raw data')

    elseif number_of_joints == 3
            % ᨐᵐᵉᵒʷ
    end

end