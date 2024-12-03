close all; clear; clc ; % Reset the environment
%% Usage example
experiment_data = LoadData("DatiAksim_Andre/4.3_normal_2.mat");
motors = DefineMotorStruct(experiment_data);
joints = DefineJointStruct(experiment_data);
joints = SetReductionRatios(joints, 160);
raw_data = GetRawData(experiment_data);
%% Encoders diagnostic
%amo: 1048576, aksim: 2^19, mrie: 15040
joint1_encoders_resolution = SetEncoderResolution('aksim', 2^19);
diagnostic_j1 = SetEncoderTypeDiagnostic(experiment_data, 'aksim');
PlotDiagnostic(experiment_data, 'aksim', diagnostic_j1);
