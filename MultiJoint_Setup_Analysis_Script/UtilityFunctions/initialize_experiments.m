%% Create and initialize diffent experiments:
% experiment 1
normale = Experiment();
normale.LoadData('4.3_normal_2.mat');
% experiment 2
no_condensatore = Experiment();
no_condensatore.LoadData('no_condensatore_1.mat');
% experiment 3
no_resistenza = Experiment();
no_resistenza.LoadData('4_3_no_res_2.mat');
% experiment 4
no_ferriti = Experiment();
no_ferriti.LoadData('no_ferriti_1.mat');
% experiment 5
no_resistenza_condensatore = Experiment();
no_resistenza_condensatore.LoadData('no_res_no_condensatore.mat');

% -------------------------------%
clear ans % Clear workspace from automatically generated variable "ans"