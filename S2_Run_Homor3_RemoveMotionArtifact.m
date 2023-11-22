
clc; clear all; close all;

global Root_path;
Root_path='C:\TILS_analysis_code\'; %please copy the path that your all matlab script putting in.
input_folder = 'CJ_test';
%% load settings file
laser_wavelength='TILS-810nm'; %1064nm , 810nm TILS,you can run both at once or invidual
day='Day1'; %Day1 for pre-test, Day2 for Post-test
folder_name='Subject_2'; 
input_dir = fullfile(Root_path,input_folder,laser_wavelength,day,folder_name);
if strcmp(day,'Day1')==1
    Settings = load(fullfile(input_dir,'settings_before.mat'));
elseif strcmp(day,'Day2')==1
    Settings = load(fullfile(input_dir,'settings_after.mat'));
else
    disp('You load the wrong data!!!');
end

%error code
assert(strcmp(day,Settings.Subject.day)==1,'You load the wrong day!')
assert(strcmp(folder_name,Settings.Subject.folder_name) == 1,'You load the wrong person!')
%% which to analysis
% which_steps = 'CST';  %[DMS Laser CST], which one to analysis
% analysis_dir = fullfile(Root_path,input_folder,laser_wavelength,Settings.Subject.day,folder_name,which_steps); %,Settings.Subject.week_index);
% Settings.analysis.channel=[ 2 4 ]; 

cd(fullfile(Root_path,'homer3','Homer3-master','Homer3-master'))
setpaths;
Homer3;