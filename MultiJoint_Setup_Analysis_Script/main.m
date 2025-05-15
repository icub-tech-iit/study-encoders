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

my_experiment_A.LoadData('Data/torso_pitch_mj1_amo_aksim_continuous_torque_no_load_1744971861.978592.mat'); % Load the data

my_experiment_A.StartTime; % If not specified, StartTime = 0
my_experiment_A.EndTime; % If not specified, EndTime = end of the experiment


disp(['You are analyzing a ', num2str(my_experiment_A.EndTime-my_experiment_A.StartTime), ' [secs] long experiment.'])

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
title("Positions transformed and scaled to the joint space")
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

%% Plot information for max velocity slides

figure(index4figures)
tiledlayout(2,2);
sgtitle("Maximum Velocity Test - No Load")

nexttile
    plot(timestamps(), my_motor_A.PWMPercent());
      xlabel('timestamps [s]');
    ylabel('PWMs (%)');
 title ("Motor PWM")

idxmin = find(my_joint_A.Velocities == min(my_joint_A.Velocities))';
idxmax = find(my_joint_A.Velocities == max(my_joint_A.Velocities))';

X = timestamps;
Y = my_joint_A.Velocities;

[val0,idx0] = min(my_joint_A.Velocities(:));
[val1,idx1] = max(my_joint_A.Velocities(:)); 

nexttile
    plot(timestamps(), my_motor_A.Currents());
      xlabel('timestamps [s]');
    ylabel('Current (A)');
 title ("Motor Current")

nexttile
plot(timestamps, my_joint_A.Velocities);
hold on
plot(timestamps(idx0),my_joint_A.Velocities(idx0),'or')
plot(timestamps(idx1),my_joint_A.Velocities(idx1),'om')
text(X(idx0), Y(idx0), sprintf('Min Joint Velocity = %.2f deg/s', val0), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Color', 'r');

text(X(idx1), Y(idx1), sprintf('Max Joint Velocity = %.2f deg/s', val1), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'm');
hold off

ylabel('degrees/s [Deg/s]');
title ("Joint Velocity");

nexttile
    plot(timestamps, my_motor_A.Temperatures);
        xlabel('timestamps [s]');
    ylabel('Degrees Celcius [C]');
title ("Motor Temperature")

index4figures = index4figures+1;


%% Plot information for Peak Torque

figure(index4figures)
tiledlayout(4,1);
sgtitle("Pendulum Test (10kg Load)")

nexttile
    plot(timestamps, my_motor_A.Currents);
      xlabel('timestamps [s]');
    ylabel('Amperes [A]');
 title ("Currents")

 nexttile
plot(timestamps, my_joint_A.Positions(:,1));
xlabel('timestamps [s]');
ylabel('degrees/s [Deg/s]');
title ("Joint Position");


nexttile
plot(timestamps, my_joint_A.Velocities);
xlabel('timestamps [s]');
ylabel('degrees/s [Deg/s]');
title ("Joint Velocity");


nexttile
    plot(timestamps, my_motor_A.Temperatures);
        xlabel('timestamps [s]');
    ylabel('Degrees Celcius [C]');
title ("Motor Temperature")

index4figures = index4figures+1;




%%
time_interval_array = find(timestamps>=35 & timestamps<=100);

% PWM_max = 32000*0.96;
%PWM_max_sub_array = find(my_motor_A.PWMPercent>=96);
PWM_max_sub_array = find(my_motor_A.PWMPercent<=96);

% figure(index4figures)
% plot(timestamps(PWM_max_sub_array),my_joint_A.Velocities(PWM_max_sub_array,1))

figure(index4figures)
tiledlayout(2,2);
sgtitle("Maximum Velocity Test - No Load " + ...
    "at 96% PWM")

nexttile
    plot(timestamps(time_interval_array), my_motor_A.PWMPercent(time_interval_array,1));
      xlabel('timestamps [s]');
    ylabel('PWMs (%)');
 title ("Motor PWM")

  nexttile
    plot(timestamps(time_interval_array), my_motor_A.Currents(time_interval_array,1));
      xlabel('timestamps [s]');
    ylabel('Currents (A)');
 title ("Currents")

[val0,idx0] = min(my_joint_A.Velocities(time_interval_array,1));
[val1,idx1] = max(my_joint_A.Velocities(time_interval_array,1)); 

nexttile
plot(timestamps(time_interval_array), my_joint_A.Velocities(time_interval_array,1));
hold on
plot(timestamps(time_interval_array(idx0)),my_joint_A.Velocities(time_interval_array(idx0)),'or')
plot(timestamps(time_interval_array(idx1)),my_joint_A.Velocities(time_interval_array(idx1)),'om')
yline(mean(my_joint_A.Velocities(time_interval_array,1)), 'g')

text(timestamps(time_interval_array(idx0)), my_joint_A.Velocities(time_interval_array(idx0)), sprintf('Min Joint Velocity = %.2f deg/s', val0), ...
  'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'Color', 'r');

text(timestamps(time_interval_array(idx1)), my_joint_A.Velocities(time_interval_array(idx1)), ...
    sprintf('Max Joint Velocity = %.2f deg/s', val1), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'm');

% text(timestamps(time_interval_array(idx1)), mean(my_joint_A.Velocities(time_interval_array,1), ...
%    sprintf('Mean Joint Velocity = %.2f deg/s', mean(my_joint_A.Velocities(time_interval_array,1))), ...
%     'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'Color', 'g');

hold off

ylabel('degrees/s [Deg/s]');
title ("Joint Velocity");

nexttile
    plot(timestamps(time_interval_array), my_motor_A.Temperatures(time_interval_array,1));
        xlabel('timestamps [s]');
    ylabel('Degrees Celcius [C]');
title ("Motor Temperature")

index4figures = index4figures+1;

%%
time_interval_array = find(timestamps>20 & timestamps<300);

figure(index4figures)
tiledlayout(2,2);
sgtitle("Maximum Velocity Test - No Load " + ...
    "at -96% PWM")

nexttile
    plot(timestamps(time_interval_array), my_motor_A.PWMPercent(time_interval_array,1));
      xlabel('timestamps [s]');
    ylabel('PWMs (%)');
 title ("Motor PWM")

 nexttile
    plot(timestamps(time_interval_array), my_motor_A.Currents(time_interval_array,1));
      xlabel('timestamps [s]');
    ylabel('Currents (A)');
 title ("Currents")

[val0,idx0] = min(my_joint_A.Velocities(time_interval_array,1));
[val1,idx1] = max(my_joint_A.Velocities(time_interval_array,1)); 

nexttile
plot(timestamps(time_interval_array), my_joint_A.Velocities(time_interval_array,1));
hold on
plot(timestamps(time_interval_array(idx0)),my_joint_A.Velocities(time_interval_array(idx0)),'or')
plot(timestamps(time_interval_array(idx1)),my_joint_A.Velocities(time_interval_array(idx1)),'om')
yline(mean(my_joint_A.Velocities(time_interval_array,1)), 'g')

text(timestamps(time_interval_array(idx0)), my_joint_A.Velocities(time_interval_array(idx0)), sprintf('Min Joint Velocity = %.2f deg/s', val0), ...
  'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'Color', 'r');

text(timestamps(time_interval_array(idx1)), my_joint_A.Velocities(time_interval_array(idx1)), ...
    sprintf('Max Joint Velocity = %.2f deg/s', val1), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'Color', 'm');

text(timestamps(time_interval_array(idx0)), mean(my_joint_A.Velocities(time_interval_array,1)), ...
    sprintf('Mean Joint Velocity = %.2f deg/s', mean(my_joint_A.Velocities(time_interval_array,1))), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', 'Color', 'g');


hold off

ylabel('degrees/s [Deg/s]');
title ("Joint Velocity");

nexttile
    plot(timestamps(time_interval_array), my_motor_A.Temperatures(time_interval_array,1));
        xlabel('timestamps [s]');
    ylabel('Degrees Celcius [C]');
title ("Motor Temperature")

index4figures = index4figures+1;

%% Plot information for Continuous Torque

figure(index4figures)
tiledlayout(4,1);
sgtitle("90 Degree Hold Test (20kg Load)")

nexttile
    plot(timestamps, my_motor_A.Currents);
      xlabel('timestamps [s]');
    ylabel('Amperes [A]');
 title ("Currents")


t1 = 48.96;   % Time when position set to 90 degrees (was set for 310 seconds)
t2 = 570.521;  % Time when position set to -90 (was set for 310 seconds)
t3 = 789.392;  % Time when continuous hold finished

set_positions = zeros(size(timestamps));  
set_positions(timestamps >= t1 & timestamps < t2) = 90;
set_positions(timestamps >= t2 & timestamps < t3) = -90;
set_positions(timestamps >= t3) = 0;

nexttile
plot(timestamps, set_positions, '--', 'Color', "#77AC30", "LineWidth",1.3);
hold on 
plot(timestamps, raw_pos_amo_joint_space_unwrapped, 'Color', '#7E2F8E',"LineWidth",1.3);
xlabel('timestamps [s]');
ylabel('degrees/s [Deg/s]');
title ("Joint Position");
legend('Reference signal', 'Joint position')

joint_pos_error = raw_pos_amo_joint_space_unwrapped - set_positions;
nexttile
plot(timestamps, joint_pos_error);
xlabel('timestamps [s]');
ylabel('degrees/s [Deg/s]');
title ("Joint Position Error");

nexttile
    plot(timestamps, my_motor_A.Temperatures);
        xlabel('timestamps [s]');
    ylabel('Degrees Celcius [C]');
title ("Motor Temperature")

index4figures = index4figures+1;
%% Plot information for Continuous Torque (excluding position error when moving to target pos) 

figure(index4figures)
tiledlayout(2,1);
sgtitle("90 Degree Hold Test (0kg Load)")

t1 = 69.399;   % Time when position set to 90 degrees (was set for 310 seconds)
t2 = t1+310;  % Time when position set to -90 (was set for 310 seconds)
t3 = t2+310;  % Time when continuous hold finished

set_positions = zeros(size(timestamps));  
set_positions(timestamps >= t1 & timestamps < t2) = 90;
set_positions(timestamps >= t2 & timestamps < t3) = -90;
set_positions(timestamps >= t3) = 0;

nexttile
plot(timestamps, set_positions, '--', 'Color', "#77AC30", "LineWidth",1.3);
hold on 
plot(timestamps, raw_pos_amo_joint_space_unwrapped, 'Color', '#7E2F8E',"LineWidth",1.3);
xlabel('timestamps [s]');
ylabel('degrees/s [Deg/s]');
title ("Joint Position");
legend('Reference signal', 'Joint position')


joint_pos_error = raw_pos_amo_joint_space_unwrapped - set_positions;
joint_pos_error(timestamps >= t1 & timestamps < t1+10) = NaN;
joint_pos_error(timestamps >= t2 & timestamps < t2+10) = NaN;
joint_pos_error(timestamps >= t3 & timestamps < t3+10) = NaN;
joint_pos_error(timestamps >= t3+10) = 0;

nexttile
plot(timestamps, joint_pos_error);
xlabel('timestamps [s]');
ylabel('degrees/s [Deg/s]');
title ("Joint Position Error");

index4figures = index4figures+1;