close all; clear; clc; % Reset the environment
%% Compute data
dataPath = "Data\m20_ferrite.mat"; % Relative path of the experiment data
experimentData = loadData(dataPath);
experiment = fillStruct(experimentData);
diagnostic = computeDiagnosticError(experiment);
calculatePercentages(diagnostic)
%% Plots
timeOffset = 11585; % Time before the actual test starts
plotEnable = true; % Bool flag that enables error plotting
if plotEnable
    plotSpeedTitle = '10'; % Set speed for plot title
    errorPlot = prepareErrorPlot(experiment.rawData, diagnostic); % Prepare error plot data
    plotErrors(experiment, errorPlot, diagnostic, plotSpeedTitle)
    plotJointMotorStates(experiment, plotSpeedTitle)
    plotJointPos_vs_JointPosCalculated(experiment)
end
%% Functions definitions
function experimentData = loadData(dataPath)
    % Load data from the specified path
    loadedData = load(dataPath);
    fieldName = fieldnames(loadedData);
    testName = fieldName{1};
    experimentData = loadedData.(testName);
end
function experiment = fillStruct(experimentData)
%% Fills an "e" struct, retaining useful values
experiment = struct( ...
    'rawData', experimentData.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data(1, :), ...
    'jointPosition', experimentData.joints_state.positions.data(1, :), ...
    'jointVelocity', experimentData.joints_state.velocities.data(1, :), ...
    'motorCurrent', experimentData.motors_state.currents.data(1, :), ...
    'motorPosition', experimentData.motors_state.positions.data(1, :), ...
    'diagnosticData', experimentData.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data(3, :), ...
    'time', experimentData.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.timestamps ...
);
experiment.time = experiment.time - experiment.time(1); % Relative time
end
function maskedData = applyMask(rawData, mask)
    maskedData = double(rawData') .* double(mask); % Apply the mask
    maskedData(maskedData == 0) = nan; % Replace zeros with NaN for plotting
end
function diagnosticStruct = initDiagnosticStruct(experiment)
    n = length(experiment.diagnosticData);
    diagnosticStruct = struct( ...
        'totalSamples', n, ...
        'rescaler', 1, ...
        'crcCount', 0, ...
        'c2lCount', 0, ...
        'invalidDataCount', 0, ...
        'C2L_invalidDataCount', 0, ...
        'CRC_invalidDataCount', 0, ...
        'CRC_InvData_C2LCount', 0, ...
        'C2L_CRCCount', 0, ...
        'crc', zeros(n, 1), ...
        'c2l', zeros(n, 1), ...,
        'invalidData', zeros(n, 1), ...
        'C2L_CRC', zeros(n, 1), ...
        'CRC_invalidData', zeros(n, 1), ...
        'C2L_invalidData', zeros(n, 1), ...
        'CRC_InvData_C2L', zeros(n, 1) ...
    );
diagnosticStruct.time = experiment.time; % Matches time between experiment and diagnostic
end
function diagnostic_data = computeDiagnosticError(experiment)
    %% Struct initialization
    diagnostic_data = initDiagnosticStruct(experiment);    
    for d = 1:diagnostic_data.totalSamples
        diagnostic_data.value = bitand(experiment.diagnosticData(d), double(0xFFFF));
        switch diagnostic_data.value
           
            case 0x01 % Checks for CRC
                    diagnostic_data.crc(d) = diagnostic_data.rescaler;
                    diagnostic_data.crcCount = diagnostic_data.crcCount + 1;
           
            case 0x02  % Checks C2L
                    diagnostic_data.c2l(d) = diagnostic_data.rescaler;
                    diagnostic_data.c2lCount = diagnostic_data.c2lCount + 1; 
           
            case 0x03  % Checks for C2L + CRC
                    diagnostic_data.C2L_CRC(d) = diagnostic_data.rescaler;
                    diagnostic_data.C2L_CRCCount = diagnostic_data.C2L_CRCCount + 1;
                    diagnostic_data.crcCount = diagnostic_data.crcCount + 1;
            
            case 0x04 % Checks for Invalid Data
                    diagnostic_data.invalidData(d) = diagnostic_data.rescaler;
                    diagnostic_data.invalidDataCount = diagnostic_data.invalidDataCount + 1;
            
            case 0x05 % Checks for CRC + Invalid Data
                    diagnostic_data.CRC_invalidData(d) = diagnostic_data.rescaler;
                    diagnostic_data.CRC_invalidDataCount = diagnostic_data.CRC_invalidDataCount + 1;
                    diagnostic_data.crcCount = diagnostic_data.crcCount + 1;
            
            case 0x06  % Checks for C2L + Invalid Data
                    diagnostic_data.C2L_invalidData(d) = diagnostic_data.rescaler;
                    diagnostic_data.C2L_invalidData = diagnostic_data.C2L_invalidData + 1;   
            
            case 0x07 % Checks for CRC + C2L + Invalid Data
                    diagnostic_data.CRC_InvData_C2L(d) = diagnostic_data.rescaler;
                    diagnostic_data.CRC_InvData_C2LCount = diagnostic_data.CRC_InvData_C2LCount + 1;
                    diagnostic_data.crcCount = diagnostic_data.crcCount + 1;
        end
    end
end
function calculatePercentages(diagnostic)
    %% Calculate percentages
    % Pure errors
    diagnostic.crcPercentage = (diagnostic.crcCount / diagnostic.totalSamples) * 100;
    diagnostic.c2lPercentage = (diagnostic.c2lCount / diagnostic.totalSamples) * 100;
    diagnostic.invalidDataPercentage = (diagnostic.invalidDataCount / diagnostic.totalSamples) * 100;

    % Mixed errors
    diagnostic.CRC_invalidDataPercentage =  (diagnostic.CRC_invalidDataCount / diagnostic.totalSamples) * 100;
    diagnostic.C2L_invalidDataPercentage =  (diagnostic.C2L_invalidDataCount / diagnostic.totalSamples) * 100;
    diagnostic.CRC_InvData_C2LPercentage =  (diagnostic.CRC_InvData_C2LCount / diagnostic.totalSamples) * 100;
    
    % Total error as sum of the single errors
    diagnostic.totalError = diagnostic.crcPercentage + ...
                            diagnostic.c2lPercentage + ...
                            diagnostic.invalidDataPercentage + ...
                            diagnostic.CRC_invalidDataPercentage + ...
                            diagnostic.C2L_invalidDataPercentage + ...
                            diagnostic.CRC_InvData_C2LPercentage;

    % Display diagnostic results
    fprintf('STANDARD ERRORS \n')
    fprintf('CRC Error: %.4f%%\n', diagnostic.crcPercentage);
    fprintf('C2L Error: %.4f%%\n', diagnostic.c2lPercentage);
    fprintf('Invalid Data Error: %.4f%%\n', diagnostic.invalidDataPercentage);
    fprintf('\n')
    fprintf('MIXED ERRORS \n')
    fprintf('CRC + Invalid data Error: %.4f%%\n', diagnostic.CRC_invalidDataPercentage);
    fprintf('C2L + Invalid data Error: %.4f%%\n', diagnostic.C2L_invalidDataPercentage);
    fprintf('CRC + InvalidData+ C2L Error: %.4f%%\n', diagnostic.CRC_InvData_C2LPercentage);
    fprintf('\n')
    fprintf('Sum of %% errors: %.4f%%\n', diagnostic.totalError);
end
function errorPlotData = prepareErrorPlot(rawData, diagnostic)
    % Select non-zero error values to make a mask over the encoder raw values
    mask = struct( ...
        'crc', diagnostic.crc > 0, ...
        'c2l', diagnostic.c2l > 0, ...
        'invalidData', diagnostic.invalidData > 0, ...
        'CRC_invalidData', diagnostic.CRC_invalidData > 0, ...
        'C2L_invalidData', diagnostic.C2L_invalidData > 0, ...
        'CRC_InvData_C2L', diagnostic.CRC_InvData_C2L > 0 ...
    );
    % Multiply the mask by th encoder values to overlap the plots
    errorPlotData = struct( ...
        'crc', applyMask(rawData, mask.crc), ...
        'c2l', applyMask(rawData, mask.c2l), ...
        'invalidData', applyMask(rawData, mask.invalidData), ...
        'CRC_invalidData', applyMask(rawData, mask.CRC_invalidData), ...
        'C2L_invalidData', applyMask(rawData, mask.C2L_invalidData), ...
        'CRC_InvData_C2L', applyMask(rawData, mask.CRC_InvData_C2L) ...
    );   
end
function plotErrors(experiment, errorPlot, diagnostic, plotSpeedTitle)
    figure(1);
    plot(experiment.time, experiment.rawData, 'k', 'LineWidth', 0.5);
    hold on;
        plot(diagnostic.time, errorPlot.crc, '*', 'LineWidth', 1, 'Color', 'r');
        plot(diagnostic.time, errorPlot.c2l, '*', 'LineWidth', 1, 'Color', 'g');
        plot(diagnostic.time, errorPlot.invalidData, '*', 'LineWidth', 1, 'Color', '#0578f1');
    hold off;
        title('Encoder raw data (Joint position)');
        subtitle(['Joint position, (joint speed: ', plotSpeedTitle, ' $[\frac{deg}{sec}$])'], 'Interpreter', 'latex');
        axis([-inf, inf, -2^15, 2.01^19]);
        xlabel('Time (seconds)');
        lgd = legend('Joint position', 'CRC error', 'C2L error', 'Invalid Data error');
        lgd.FontSize = 5; lgd.Location = 'north'; lgd.Orientation = 'horizontal';
        set(gca,'color', [0.9 0.9 0.9]);
end
function plotJointMotorStates(experiment, plotSpeedTitle) 
    %% Plots the joints and the motors states
    figure(2);
    subplot(2, 2, 1); plot(experiment.time, experiment.jointPosition, 'LineWidth', 1); subtitle('Joint Position', 'Interpreter', 'latex'); xlabel('Time (s)');
    subplot(2, 2, 2); plot(experiment.time, experiment.motorPosition, 'LineWidth', 1); subtitle('Motor Position', 'Interpreter', 'latex'); xlabel('Time (s)');
    subplot(2, 2, 3); plot(experiment.time, experiment.jointVelocity, 'b--', 'LineWidth', 0.5); subtitle('Joint Velocity', 'Interpreter', 'latex'); xlabel('Time (s)');
    subplot(2, 2, 4); plot(experiment.time, experiment.motorCurrent, 'b--', 'LineWidth', 0.5); subtitle('Motor Current', 'Interpreter', 'latex'); xlabel('Time (s)');
    sgtitle(['Joint and motor states, ', plotSpeedTitle, ' [$\frac{deg}{sec}$]'], 'Interpreter', 'latex')
end
function plotJointPos_vs_JointPosCalculated(experiment, timeOffset)

    meanSamplingTime = mean(diff(experiment.time)); % Mean sampling time
    jPos = experiment.jointPosition(timeOffset:end) - experiment.jointPosition(timeOffset); %remove the data offset
    mPos = experiment.motorPosition(timeOffset:end) - experiment.motorPosition(timeOffset); %remove the data offset
    gearRatio = 100;
    jPosCalculated = mPos/gearRatio;
    
    err= jPosCalculated-jPos;
    maxErr = max(err); minErr = min(err);
    maxIndex = find(err == maxErr); minIndex = find(err == minErr);

    figure(3)
    plot(experiment.time(timeOffset:end), err)
    hold on
        plot([experiment.time(1) experiment.time(end)], [maxErr maxErr], 'r--')
        plot([experiment.time(1) experiment.time(end)], [minErr minErr], 'b--')
        plot(experiment.time(maxIndex) + timeOffset*meanSamplingTime, maxErr, 'rx', 'LineWidth',2)
        plot(experiment.time(minIndex) + timeOffset*meanSamplingTime, minErr, 'bx', 'LineWidth',2)
    hold off
    title('Joint position error')
    subtitle('Aksim2 data vs Computed joint position')
end
%% Clear some data to organize the workspace
clear dataPath loadedData fieldName testName lgd plotEnable
