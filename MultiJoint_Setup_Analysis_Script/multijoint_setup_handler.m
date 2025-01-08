close all; clear; clc ; % Reset the environment
%% Usage example

experiment_data = LoadData("Data\synthetic_data.mat");
% experiment_data = LoadData("Data\m20_ferrite.mat");
motors = DefineMotorStruct(experiment_data);
joints = DefineJointStruct(experiment_data);
raw_data = GetRawData(experiment_data);
joints = SetReductionRatios(joints, 100, 100);

%amo: 1048576, aksim: 2^19, mrie: 15040
joint0_encoders_resolution = SetEncoderResolution('aksim', 2^19);

diagnostic = SetEncoderTypeDiagnostic(experiment_data, 'aksim');
% plot(GetTimestamps(experiment_data), motors.currents)
figure(1)
subplot(2,2,1)
plot(GetTimestamps(experiment_data), raw_data(1,:), 'Color', "#D95319")
subtitle('Joint 0 primary encoder')
subplot(2,2,2)
plot(GetTimestamps(experiment_data), raw_data(2,:), 'Color', "#D95319")
subtitle('Joint 0 secondary encoder')
subplot(2,2,3)
plot(GetTimestamps(experiment_data), raw_data(3,:))
subtitle('Joint 1 primary encoder')
subplot(2,2,4)
plot(GetTimestamps(experiment_data), raw_data(4,:))
subtitle('Joint 1 secondary encoder')
sgtitle('Raw data')
