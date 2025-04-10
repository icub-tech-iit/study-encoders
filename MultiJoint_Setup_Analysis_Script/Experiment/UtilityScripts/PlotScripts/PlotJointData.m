function PlotJointData(ts, jointObj)
%PLOTJOINTDATA Summary of this function goes here
%   Detailed explanation goes here
    tiledlayout(3,1);

    % Tile Position
    nexttile
    plot(ts, jointObj.Positions);
    title('Joint Positions');
    xlabel('timestamps [s]');
    ylabel('degrees [Deg]');
    legend("Joint primary encoder", "Joint secondary encoder");

    % Tile Velocity
    nexttile
    plot(ts, jointObj.Velocities);
    title('Joint Velocities');
    xlabel('timestamps [s]');
    ylabel('degrees/s [Deg/s]');

    % Tile Acceleration
    nexttile
    plot(ts, jointObj.Accelerations);
    title('Joint Accelerations');
    xlabel('timestamps [s]');
    ylabel('degrees/ s^{2} [Deg/s^{2}]');

end

