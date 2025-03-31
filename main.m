%% Workspace Cleanup
close all; clear; clc;

%% Add directories to MATLAB path
addpath('Encoders');
addpath('Encoders/Aksim');
addpath('Encoders/Amo');
addpath('Joint');
addpath('Motor');
addpath('Experiment');
addpath('Experiment/UtilityScripts');
addpath('SampleData');

%% Create and initialize Experiment
experiment = Experiment();
experiment.LoadData('data.mat');  % Load experiment data
% rawData = experiment.GetRawData();
% [diagData, nSamples] = experiment.GetDiagnosticData();
%% Set gearbox reduction ratios (for 3 joints, example values)
experiment.setReductionRatios(1);

%% Retrieve additional data


% timestamps = exp.GetTimestamps();

%% Create Joint and Motor objects
% jointObj = Joint(exp);
% motorObj = Motor(exp);

%% Create Encoder objects
encoder_0 = AksimEncoder();
encoder_0.JointNumber = 1;
encoder_0.Resolution = 2^19;
encoder_0.computeDiagnosticError(experiment);
encoder_0.displayReport();

encoder_1 = AmoEncoder();
encoder_1.JointNumber = 2;
encoder_1.Resolution = 2^20;
encoder_1.computeDiagnosticError(experiment);
encoder_1.displayReport();