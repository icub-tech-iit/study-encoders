%% Workspace Cleanup
close all; clear; clc;
%% % ------------------- Use notes --------------------- %%%
% Make sure your experiment ".mat" data is in the "Data" folder.
% Don't modify or remove these functions or folders location.
addpath('UtilityFunctions') % add utility functions to matlab path
add_resources_paths; % add resources to matlab path
%% Load data:
my_experiment_A = Experiment(); % Experiment 1 
my_experiment_A.LoadData('my_data_1.mat');
my_experiment_B = Experiment(); % Experiment 2
my_experiment_B.LoadData('my_data_2.mat');
%% Create encoder objects:
my_aksim_encoder = AksimEncoder(); % Create an object handling Aksim diagnostic
my_amo_encoder = AmoEncoder(); % Create an object handling Amo diagnostic
%% Display result:
my_aksim_encoder.computeDiagnosticError(my_experiment_A); % Compute diagnostic for experiment A
my_aksim_encoder.displayReport(); % Display diagnostic result for experiment A
fprintf('\n \n'); % Displays empty line between diagnostic display
my_aksim_encoder.computeDiagnosticError(my_experiment_B); % Compute diagnostic for experiment B
my_aksim_encoder.displayReport(); % Display diagnostic result for experiment B
%% Plot data:
my_aksim_encoder.plotDiagnosticOnRawData(my_experiment_A); % Plot experiment A diagnostic on raw values
my_aksim_encoder.plotDiagnosticOnRawData(my_experiment_B); % Plot experiment B diagnostic on raw values