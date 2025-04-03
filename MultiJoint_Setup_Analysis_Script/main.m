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
addpath('Experiment/UtilityScripts');
addpath('Data');
% ----- End of locate resources ----- %
%% Load data:
my_experiment_A = Experiment(); % Experiment 1 
my_experiment_A.LoadData('4.3_normal_2.mat');
my_experiment_B = Experiment(); % Experiment 2
my_experiment_B.LoadData('torso_pitch_mj1_aksim_amo_position_1742988005.992320.mat');
%% Create encoder objects:
my_aksim_encoder_A = AksimEncoder(); % Create an object handling Aksim diagnostic for exp. A
my_aksim_encoder_B = AksimEncoder(); % Create an object handling Aksim diagnostic for exp. B

my_amo_encoder = AmoEncoder(); % Create an object handling Amo diagnostic
%% Display result:
my_aksim_encoder_A.computeDiagnosticError(my_experiment_A); % Compute diagnostic for experiment A
my_aksim_encoder_A.displayReport(); % Display diagnostic result for experiment A
fprintf('\n \n'); % Displays empty line between diagnostic display
my_aksim_encoder_B.computeDiagnosticError(my_experiment_B); % Compute diagnostic for experiment B
my_aksim_encoder_B.displayReport(); % Display diagnostic result for experiment B
%% Plot data:
% If you have different experiments you need to declare an empty figure per
% plot. If you don't do this matlab will overwrite the previous plot.

figure(1)
my_aksim_encoder_A.plotDiagnosticOnRawData(my_experiment_A); % Plot experiment A diagnostic on raw values

figure(2)
my_aksim_encoder_B.plotDiagnosticOnRawData(my_experiment_B); % Plot experiment B diagnostic on raw values