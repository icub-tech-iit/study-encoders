function PlotMotorDataTemperature(ts, motorObj)
%PLOTJOINTDATA Summary of this function goes here
%   Detailed explanation goes here
    tiledlayout(2,2);

    % Tile Position
    nexttile
    plot(ts, motorObj.Positions);
    title('Motor Positions');
    xlabel('timestamps [s]');
    ylabel('degrees [Deg]');

    % Tile PWM
    nexttile
    plot(ts, motorObj.PWMPercent);
    title('Motor PWMs');
    xlabel('timestamps [s]');
    ylabel('pwms [%]');

    % Tile Currents
    nexttile
    plot(ts, motorObj.Currents);
    title('Motor Currents');
    xlabel('timestamps [s]');
    ylabel('Ampere [A]');

    % Tile Acceleration
    nexttile
    plot(ts, motorObj.Temperatures);
    title('Motor Temperatures');
    xlabel('timestamps [s]');
    ylabel('Degree Celsius [C]');

end

