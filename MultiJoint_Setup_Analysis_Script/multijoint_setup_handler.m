close all; clear; clc ; % Reset the environment
%% Usage example
experiment_data = LoadData("movimento_pwm_2.mat");
motors = DefineMotorStruct(experiment_data);
joints = DefineJointStruct(experiment_data);
joints = SetReductionRatios(joints, 100, 100);
raw_data = GetRawData(experiment_data);
%% Encoders diagnostic
%amo: 1048576, aksim: 2^19, mrie: 15040
joint0_encoders_resolution = SetEncoderResolution('amo', 2^20);
joint1_encoders_resolution = SetEncoderResolution('aksim', 2^19);
diagnostic_j1 = SetEncoderTypeDiagnostic(experiment_data, 'aksim');
diagnostic_j0 = SetEncoderTypeDiagnostic(experiment_data, 'amo');
%% Plotting functions
PlotRawData(experiment_data);
PlotError(experiment_data);
PlotJointPosVel(experiment_data);
PlotMotorStates(experiment_data);
PlotDiagnostic(experiment_data, 'aksim', diagnostic_j1)