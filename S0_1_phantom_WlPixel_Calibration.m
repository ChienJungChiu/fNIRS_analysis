%{
S0_1_wavelength

you can only make one settings for one person and one weeks and days

Chien-Jung Chiu
Last Update: 2024/2/18
%}
clc; clear all; close all;
%global Root_path;
Root_path='/Users/amandachiu/Desktop/NTU/fNIRS_analysis_code'; %please copy the path that your all matlab script putting in.
%input_folder = 'CJ_test';
input_folder = 'new_input';

%% Settings
Subject.folder_name={'Subject_7'}; 
Subject.day='Day1'; %Day1 for pre-test, Day2 for Post-test
laser_wavelength='TILS-810nm';

cd(fullfile(Root_path,input_folder,laser_wavelength,'phantom_WlPixel_calibration',Subject.folder_name{1}))

%% pre-test
% Mean signal calculation 
ph_s_pre = load('ph_s_pre.mat').I; 
mean_ph_s_pre = mean(ph_s_pre,3);
% Mean bg calculation 
ph_bg_pre = load('ph_bg_pre.mat').I; 
mean_ph_bg_pre = mean(ph_bg_pre,3);

%net signal calculation 
pre_mean_clear_signal = mean_ph_s_pre - mean_ph_bg_pre;

%% post-test
% Mean signal calculation 
ph_s_post = load('ph_s_post.mat').I; 
mean_ph_s_post = mean(ph_s_post,3);
%Mean bg calculation 
ph_bg_post = load('ph_bg_post.mat').I; 
mean_ph_bg_post = mean(ph_bg_post,3);

%net signal calculation 
post_mean_clear_signal = mean_ph_s_post - mean_ph_bg_post;

%% calculate pixel shift
pre_local_min = find(pre_mean_clear_signal==min(pre_mean_clear_signal(400:600)));
post_local_min = find(post_mean_clear_signal==min(post_mean_clear_signal(400:600)));
pixel_shift = pre_local_min - post_local_min;
local_min_pixel_shift = [];
local_min_pixel_shift = ["pre_local_min" "post_local_min" "pixel_shift"; pre_local_min post_local_min pixel_shift];

%% plot
figure;
plot(pre_mean_clear_signal);
hold on;
plot(post_mean_clear_signal);
legend('Pre-test','Post-test')

%% save
save local_min_pixel_shift.mat local_min_pixel_shift -mat
%saveas(local_min_pixel_shift,'local_min_pixel_shift.txt','txt')
% % plot all fiber SPECTRA 
% z = [1:1024];
% plot( z, I_n_r )