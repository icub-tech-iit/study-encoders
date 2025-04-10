%% Workspace Cleanup
close all; clear; clc;
%% % ------------------- Use notes --------------------- %%%
% Please do not modify these folders since the resources are located here.
% If you move these scripts you have to relocate them in order to let the script work. 
addpath('Encoders');
addpath('Encoders/Aksim');
addpath('Encoders/Amo');
addpath('Joint');
addpath('Motor');
addpath('Experiment');
addpath(genpath('Experiment/UtilityScripts'));
addpath('Data');
% ----- End of locate resources ----- %
%% Load data:
index4figures = 1;

my_experiment_A = Experiment(); % Experiment 1

my_experiment_A.LoadData('Data/data-torso-pitch-mj1/position_mode/torso_pitch_mj1_aksim_amo_sequence_pos_1744115348.918446.mat'); % Load the data

my_experiment_A.StartTime; % If not specified, StartTime = 0
my_experiment_A.EndTime; % If not specified, EndTime = end of the experiment

disp(['You are analyzing a ', num2str(my_experiment_A.EndTime - my_experiment_A.StartTime), ' [secs] long experiment.'])

my_experiment_A.setReductionRatios(100, 100);
timestamps = my_experiment_A.GetTimestamps()';
% my_experiment_B = Experiment(); % Experiment 2

%% Create encoder objects:
my_aksim_encoder_A = AksimEncoder(); % Create an object handling Aksim diagnostic for exp. A

my_amo_encoder = AmoEncoder(); % Create an object handling Amo diagnostic

my_joint_A = Joint(my_experiment_A); % Create an object handling Joint data
my_motor_A = Motor(my_experiment_A); % Create an object handling Motor data

%% Evaluate Diagnostic result:
my_aksim_encoder_A.computeDiagnosticError(my_experiment_A); % Compute diagnostic for experiment A
my_aksim_encoder_A.displayReport(); % Display diagnostic result for experiment A
fprintf('\n \n'); % Displays empty line between diagnostic display

%% Motor and Joint position correlation
motor_pos_joint_space = (my_motor_A.Positions(:,1) - my_motor_A.Positions(1,1))/my_joint_A.ReductionRatios(1,1);
motor_joint_pos_difference = abs(motor_pos_joint_space - my_joint_A.Positions(:,1));

%% Filter encoder data
raw_aksim2_data = cast(squeeze(my_experiment_A.Data__.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data), 'double');
aksim2_pos_filtered = FilterEncoderRawData(raw_aksim2_data(1,:), my_aksim_encoder_A, 'aksim2'); 
figure(index4figures)
plot(timestamps, aksim2_pos_filtered);
title("Filtered aksim2 position data");
index4figures = index4figures+1;

%% Unwrap aksim2 data (shift position when cross zero and rescale in joint space 0-360 degrees)
raw_pos_askim2_joint_space_unwrapped = UnwrapEncoderPosData(aksim2_pos_filtered, 2^(19));

% Calculate difference between aksim2 pos in joint space and calculated
% joint positions
aksim2_joint_pos_difference = abs(raw_pos_askim2_joint_space_unwrapped - my_joint_A.Positions(:,1));

figure(index4figures)
plot(timestamps, raw_pos_askim2_joint_space_unwrapped);
title("Rescaled unwrapped aksim2 positions");
index4figures = index4figures+1;
%% Unwrap amo data (shift position when cross zero and rescale in joint space 0-360 degrees)

% Get raw position amo from all raw data
raw_pos_amo = cast(squeeze(my_experiment_A.Data__.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data(4,1,:)), 'double');
raw_pos_amo_joint_space_unwrapped = UnwrapEncoderPosData(raw_pos_amo, 2^(20));

% Calculate difference between amo pos in joint space and calculated
% joint positions
amo_joint_pos_difference = abs(raw_pos_amo_joint_space_unwrapped - my_joint_A.Positions(:,1));

figure(index4figures)
plot(timestamps, raw_pos_amo_joint_space_unwrapped);
title("Rescaled unwrapped amo positions");
index4figures = index4figures+1;

%% Plot diagnostic data:
% If you have different experiments you need to declare an empty figure per
% plot. If you don't do this matlab will overwrite the previous plot.
figure(index4figures)
my_aksim_encoder_A.plotDiagnosticOnRawData(my_experiment_A); % Plot experiment A diagnostic on raw values
index4figures = index4figures+1;

%% Plot Motor data
figure(index4figures)
PlotMotorData(timestamps, my_motor_A);
index4figures = index4figures+1;

%% Plot Joint data
figure(index4figures)
PlotJointData(timestamps, my_joint_A);
index4figures = index4figures+1;

%% Plot motor 2 joint positions correlation data
figure(index4figures)
index4figures = index4figures+1;
tiledlayout(4,1);

% Joint positions correlation
nexttile
plot(timestamps, my_joint_A.Positions(:,1));
hold on
plot(timestamps, motor_pos_joint_space);
plot(timestamps, raw_pos_askim2_joint_space_unwrapped);
plot(timestamps, raw_pos_amo_joint_space_unwrapped);
hold off
legend('joint pos', 'motor pos joint space', 'aksim2 pos joint space', 'amo pos joint space');


% Motor 2 Joint position difference
nexttile
plot(timestamps, motor_joint_pos_difference);
title("Motor to Joint position difference");


% Motor 2 Aksim2 rescaled position differences
motor_joint_pos_difference = abs(motor_pos_joint_space - raw_pos_askim2_joint_space_unwrapped);
nexttile
plot(timestamps, motor_joint_pos_difference);
title("Motor to Aksim2 position difference");

% Motor 2 Amo rescaled position differences
motor_joint_pos_difference = abs(motor_pos_joint_space - raw_pos_amo_joint_space_unwrapped);
nexttile
plot(timestamps, motor_joint_pos_difference);
title("Motor to Amo position difference");

%% Plot positions to currents correlation data
figure(index4figures)
index4figures = index4figures+1;
tiledlayout(2,2);

% Polar plot motor 2 currents
nexttile
polarplot(my_motor_A.Positions, my_motor_A.Currents);
title("motor positions to currents");

% Polar plot joint 2 currents
nexttile
polarplot(my_joint_A.Positions, my_motor_A.Currents);
title("joint positions to currents");

% Polar plot aksim 2 currents
nexttile
polarplot(raw_aksim2_data(1,:)', my_motor_A.Currents);
title("raw askim2 positions to currents");

% Polar plot amo 2 currents
nexttile
polarplot(raw_pos_amo', my_motor_A.Currents);
title("raw amo positions to currents");

%% Plot joint to raw joint positions correlation data
figure(index4figures)
plot(timestamps, aksim2_joint_pos_difference);
hold on
plot(timestamps, amo_joint_pos_difference);
hold off
title("Raw position to estimated joint position differences");
legend("aksim2 to joint difference", "amo to joint difference")
index4figures = index4figures+1;

