%{
This code should:
 - Find the errors/warnings thrown by the Aksim2 encoder.
 - Analyse the number of errors for each type of error.
 - Plot the raw encoder values
 - Optionally plot the errors over them
%}

% Reset the environment
close all; clear; clc; 

% Load data from a folder.
% % Specify the relative path to the file and load it as 'datastruct':
datastruct = load("Data\voltage_dispersion.mat");
datastruct_name = fieldnames(datastruct);
test_name = datastruct_name{1};
experiment = datastruct.(test_name);

clear datastruct datastruct_name;

% Set speed for plotting purpose
speed = '10';

%% Functions definition for error computation and plotting

function diagnostic_error = diagn_error(diagnostic_data)

    n = length(diagnostic_data);

    diagnostic_error = struct( ...
        's', n, ...
        'rescaler', 100000, ... %for better visualization
        'counter', 0, ...
        'crc_count', 0, ...
        'c2l_count', 0, ...
        'invalidData_count', 0, ...
        'val', 0, ...
        'crc', zeros(n, 1), ...
        'c2l', zeros(n, 1), ...
        'invalidData', zeros(n, 1) ...
    );

    for d = 1:n
        %Select the last part of the message
        diagnostic_error.val = cast(bitand(diagnostic_data(d), 255), 'double');
        %Counts the number of error occurence
        if diagnostic_error.val ~= 0
            diagnostic_error.counter = diagnostic_error.counter + 1;
        end
        %Finds CRC error occurrence
        if bitget(diagnostic_error.val, 1) == 1
            diagnostic_error.crc(d) = diagnostic_error.rescaler;
            %counts the number of CRC errors
            if bitget(diagnostic_error.val, 2) == 0 && bitget(diagnostic_error.val, 3) == 0
                diagnostic_error.crc_count = diagnostic_error.crc_count + 1;
            end
        end
        %Finds C2L warning occurrence
        if bitget(diagnostic_error.val, 2) == 1
            diagnostic_error.c2l(d) = 2 * diagnostic_error.rescaler;
            %counts the number of C2L warnings
            diagnostic_error.c2l_count = diagnostic_error.c2l_count + 1;
        end
        %Finds invalid data error occurrence
        if bitget(diagnostic_error.val, 3) == 1
            diagnostic_error.invalidData(d) = 4 * diagnostic_error.rescaler;
            %counts the number of invalid data errors
            diagnostic_error.invalidData_count = diagnostic_error.invalidData_count + 1;
        end
    end

    % Calculate percentages
    diagnostic_error.crc_perc = (diagnostic_error.crc_count / diagnostic_error.s) * 100;
    diagnostic_error.c2l_perc = (diagnostic_error.c2l_count / diagnostic_error.s) * 100;
    diagnostic_error.invalidData_perc = (diagnostic_error.invalidData_count / diagnostic_error.s) * 100;
    error_tot_calc = diagnostic_error.crc_perc + diagnostic_error.c2l_perc + diagnostic_error.invalidData_perc;
    diagnostic_error.total_perc = (diagnostic_error.counter / diagnostic_error.s) * 100;

    % Display diagnostic results
    fprintf('CRC Error: %.2f%%\n', diagnostic_error.crc_perc);
    fprintf('C2L Error: %.2f%%\n', diagnostic_error.c2l_perc);
    fprintf('Invalid Data Error: %.2f%%\n', diagnostic_error.invalidData_perc);
    fprintf('Sum of %% errors: %.2f%%\n', error_tot_calc);
    fprintf('Total error calculation: %.2f%%\n', diagnostic_error.total_perc);
    
    %Ensures that the percentages are computed properly
    if error_tot_calc - diagnostic_error.total_perc == 0
        disp('Percentage error calculation is valid');
    end
end

% Error plotting function
function plotErr = plot_errors(e, d)

%Select non-zero error values to make a mask over the encoder raw values
    mask = struct( ...
        'crc', d.perc_err.crc > 0, ...
        'c2l', d.perc_err.c2l > 0, ...
        'invData', d.perc_err.invalidData > 0 ...
    );
    %Multiply the mask by th encoder values to overlap the plots
    plotErr = struct( ...
        'crc', double(e.rawData') .* double(mask.crc), ...
        'c2l', double(e.rawData') .* double(mask.c2l), ...
        'invData', double(e.rawData') .* double(mask.invData) ...
    );

    % Replace zeros with nan for proper plotting
    plotErr.crc(plotErr.crc == 0) = nan;
    plotErr.c2l(plotErr.c2l == 0) = nan;
    plotErr.invData(plotErr.invData == 0) = nan;
end

%% Fills an "e" struct, retaining useful values

e.rawData = experiment.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data(1, :); %encoder raw values
e.jointPosition = experiment.joints_state.positions.data(1, :); 
e.jointVelocity = experiment.joints_state.velocities.data(1, :);
e.motorCurrent = experiment.motors_state.currents.data(1, :);
e.motorPos = experiment.motors_state.positions.data(1, :);
e.diagnostic = experiment.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data(3, :); %vector of the errors
e.time = experiment.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.timestamps;
e.time = e.time - e.time(1);  % Defines a relative time interval

% Compute error percentages and data to be plotted
d.perc_err = diagn_error(e.diagnostic);
d.time = e.time;

plotErr = plot_errors(e, d);

%% Plots

%{ 
- Plot rawData with or without error marks.
- Set PLOT_ERRORS to one if you want to plot the errors over the encoder values.
- If the errors are not plotted, matlab will take care of the extra legend entries and ignore them.
%}

PLOT_ERRORS = 0;

figure(1);
plot(e.time, e.rawData, 'k', 'LineWidth', 0.5);
if(PLOT_ERRORS == 1)
    hold on;
    plot(d.time, plotErr.crc, '*', 'LineWidth', 1, 'Color', 'm');
    plot(d.time, plotErr.c2l, '*', 'LineWidth', 1, 'Color', 'r');
    plot(d.time, plotErr.invData, '*', 'LineWidth', 1, 'Color', 'b');
    hold off;
end
title('Encoder raw data (Joint position)');
subtitle(['Joint position, (joint speed: ', speed, ' $[\frac{deg}{sec}$])'], 'Interpreter', 'latex');
axis([-inf, inf, -2^15, 2.01^19]);
xlabel('Time (seconds)');
lgd = legend('Joint position', 'CRC error', 'C2L error', 'Invalid Data error');
lgd.FontSize = 5; lgd.Location = 'north'; lgd.Orientation = 'horizontal';

% Joint and motor states plots
figure(2);
subplot(2, 2, 1); plot(e.time, e.jointPosition, 'LineWidth', 1); title('Joint position', 'Interpreter', 'latex'); xlabel('Time (seconds)');
subplot(2, 2, 2); plot(e.time, e.motorPos, 'LineWidth', 1); title('Motor position', 'Interpreter', 'latex'); xlabel('Time (seconds)');
subplot(2, 2, 3); plot(e.time, e.jointVelocity, 'b--', 'LineWidth', 0.5); title('Joint velocity', 'Interpreter', 'latex'); xlabel('Time (seconds)');
subplot(2, 2, 4); plot(e.time, e.motorCurrent, 'b--', 'LineWidth', 0.5); title('Motor current', 'Interpreter', 'latex'); xlabel('Time (seconds)');
