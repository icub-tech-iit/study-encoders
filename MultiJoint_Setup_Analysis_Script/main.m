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

%% Motor and Joint position correlation
motor_pos_joint_space = (my_motor_A.Positions(:,1) - my_motor_A.Positions(1,1))/my_joint_A.ReductionRatios(1,1);
motor_joint_pos_difference = abs(motor_pos_joint_space - my_joint_A.Positions(:,1));

% Get raw data aksim2
raw_pos_askim2_joint_space = cast(squeeze(my_experiment_A.Data__.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data(1,1,:)), 'double');
raw_pos_askim2_joint_space = ((raw_pos_askim2_joint_space/2^(19))*2*pi)*(-1);
raw_pos_askim2_joint_space_unwrapped = unwrap(raw_pos_askim2_joint_space);
raw_pos_askim2_joint_space_unwrapped = (raw_pos_askim2_joint_space_unwrapped/(2*pi))*360;
raw_pos_askim2_joint_space_unwrapped = raw_pos_askim2_joint_space_unwrapped - raw_pos_askim2_joint_space_unwrapped(1);
aksim2_joint_pos_difference = abs(raw_pos_askim2_joint_space_unwrapped - my_joint_A.Positions(:,1));
% Get raw data amo
raw_pos_amo_joint_space = cast(squeeze(my_experiment_A.Data__.raw_data_values.eoprot_tag_mc_joint_status_addinfo_multienc.data(4,1,:)), 'double');
raw_pos_amo_joint_space = ((raw_pos_amo_joint_space/2^(20))*2*pi)*(-1);
raw_pos_amo_joint_space_unwrapped = unwrap(raw_pos_amo_joint_space);
raw_pos_amo_joint_space_unwrapped = (raw_pos_amo_joint_space_unwrapped/(2*pi))*360;
raw_pos_amo_joint_space_unwrapped = raw_pos_amo_joint_space_unwrapped - raw_pos_amo_joint_space_unwrapped(1);
amo_joint_pos_difference = abs(raw_pos_amo_joint_space_unwrapped - my_joint_A.Positions(:,1));

%% Display result:
my_aksim_encoder_A.computeDiagnosticError(my_experiment_A); % Compute diagnostic for experiment A
my_aksim_encoder_A.displayReport(); % Display diagnostic result for experiment A
fprintf('\n \n'); % Displays empty line between diagnostic display
%% Plot diagnostic data:
% If you have different experiments you need to declare an empty figure per
% plot. If you don't do this matlab will overwrite the previous plot.
figure(1)
my_aksim_encoder_A.plotDiagnosticOnRawData(my_experiment_A); % Plot experiment A diagnostic on raw values


%% Plot Motor data

figure(2)
PlotMotorData(timestamps, my_motor_A);

%% Plot Joint data

figure(3)
PlotJointData(timestamps, my_joint_A);

%% Plot correlation data
figure(4)
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


% Position differences
nexttile
plot(timestamps, motor_joint_pos_difference);
title("Motor to Joint position difference");


% Position differences
motor_joint_pos_difference = abs(motor_pos_joint_space - raw_pos_askim2_joint_space_unwrapped);
nexttile
plot(timestamps, motor_joint_pos_difference);
title("Motor to Joint position difference");

% Position differences
motor_joint_pos_difference = abs(motor_pos_joint_space - raw_pos_amo_joint_space_unwrapped);
nexttile
plot(timestamps, motor_joint_pos_difference);
title("Motor to Joint position difference");


figure(5)
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
polarplot(raw_pos_askim2_joint_space, my_motor_A.Currents);
title("raw askim2 positions to currents");

% Polar plot amo 2 currents
nexttile
polarplot(raw_pos_amo_joint_space, my_motor_A.Currents);
title("raw amo positions to currents");

%%
figure(6)
plot(timestamps, raw_pos_amo_joint_space);
hold on
plot(timestamps, raw_pos_amo_joint_space_unwrapped);
plot(timestamps, raw_pos_askim2_joint_space_unwrapped);
hold off

