%{
S0_settings

you can only make one settings for one person and one weeks and days

Chien-Jung Chiu
Last Update: 2024/2/18
%}
clc; clear all; close all;
%global Root_path;
Root_path='/Users/amandachiu/Desktop/NTU/fNIRS_analysis_code'; %please copy the path that your all matlab script putting in.
%input_folder = 'CJ_test';
input_folder = 'new_input';

%% subject setting, First in First Out in program running
Subject.folder_name={'Subject_8'}; 
%% week setting
Subject.day='Day1'; %Day1 for pre-test, Day2 for Post-test


%% analysis settings
analysis.Is_Placebo = 0; %setting if the TILS is Pablco; 0, if actually did the TILS; 1, if didn't do TILS
%initialize the times of doing removing motion artifact,   MA_round is how many times motion artifact that you correct for Homer3, if you correct for one time , key in 1
analysis.MA_round = [0 0 0]; %[DMS laser CST];
analysis.wavelength_selection_database=[660:5:980];

%% Hardware settings
hardware.detector.SDS=[3 0.8]; %cm  SDS, [long short]
hardware.source=1; %total number of sources you use in experiment
hardware.camera.Hbin=8;
hardware.camera.HFullpixel=1024;

% setting track position
hardware.detector.short_channel_num = 2;
hardware.detector.long_channel_num = 8;
hardware.detector.channel_pairs(1,:)=[1 10]; %you need to put long channel first, then short channel  EX:track1=>long & track6=>short
hardware.detector.channel_pairs(2,:)=[5 9]; %you need to put long channel first, then short channel  EX:track2=>long & track4=>short
hardware.detector.channel_pairs(3,:)=[2 10]; %you need to put long channel first, then short channel  EX:track2=>long & track4=>short
hardware.detector.channel_pairs(4,:)=[6 9]; %you need to put long channel first, then short channel  EX:track2=>long & track4=>short
hardware.detector.channel_pairs(5,:)=[4 10]; %you need to put long channel first, then short channel  EX:track2=>long & track4=>short
hardware.detector.channel_pairs(6,:)=[8 9]; %you need to put long channel first, then short channel  EX:track2=>long & track4=>short
hardware.detector.channel_pairs(7,:)=[3 10];
hardware.detector.channel_pairs(8,:)=[7 9];
hardware.detector.short_channel = [10 9];

% analysis.hardware_channel=[ 2 4 6 ]; 
% error code
assert(size(hardware.detector.short_channel,2)== hardware.detector.short_channel_num,'The total number of short channel does not match!!!')
assert(size(hardware.detector.channel_pairs,1)== hardware.detector.long_channel_num,'The total number of long channel does not match!!!')
assert(size(hardware.detector.channel_pairs,2)== 2,'There should only be 2 tracks for a channel!!!')
    
% setting wavelength boundary
%設定汞氬燈校正之後的波長極端值
hardware.camera.wavelength_boundary=[576.4584 1145.7];  %before
%hardware.camera.wavelength_boundary=[560.02 1098.2509];  %before
%hardware.camera.wavelength_boundary{2}=[523.32 1075.0182];  %after
% hardware.camera.wavelength_boundary{1,2,1}=[560.02 1098.2509];  %new%subject2after
% hardware.camera.wavelength_boundary{2,1,1}=[523.32 1075.0182];  %new%subject1_2before
% hardware.camera.wavelength_boundary{2,2,1}=[560.02 1098.2509];  %new%subject3_4_5_6before
% hardware.camera.wavelength_boundary{3,1,1}=[544.14 1095.8382];  %new%subject6after
% hardware.camera.wavelength_boundary{3,2,1}=[549.86 1088.0909];  %new%subject5_after

% calculation
hardware.camera.wavelength=linspace(hardware.camera.wavelength_boundary(1),hardware.camera.wavelength_boundary(2),hardware.camera.HFullpixel/hardware.camera.Hbin); %before
%hardware.camera.wavelength{2}=linspace(hardware.camera.wavelength_boundary{2}(1),hardware.camera.wavelength_boundary{2}(2),hardware.camera.HFullpixel/hardware.camera.Hbin); %after
% hardware.camera.wavelength{2,2,2}=linspace(hardware.camera.wavelength_boundary{2,2}(1),hardware.camera.wavelength_boundary{2,2}(2),hardware.camera.HFullpixel/hardware.camera.Hbin);



%% TILS settings
Laser.wavelength={'TILS-810nm'}; %1064nm , 810nm TILS
% laser, unit:sec
Laser.baseline=120; %sec
Laser.per_stimulate=5; %sec
Laser.recovery=298; %sec
Laser.trails=10;  % how many times did you do while you are doing laser


%% DMS, unit:data time point
DMS.baseline=119; 
DMS.recovery=30;
%DMS.recovery=0; subject_7 post test
%DMS.round=[1]; %select rounds that you want to analysis 
DMS.background_trails=3;
DMS.trails=30; % how many questions do you have while you are doing DMS test
DMS.interval=[4 5 5 8]; %unit:sec; each time for [stimuls retention probe ITI], ex: stimuls:4 secs, retention:5 secs, probe:5 secs, ITI:8 secs 
DMS.stimulate=sum(DMS.interval);

%% CST, unit:
CST.baseline=120;%119;%32; %sec
CST.recovery=0; %sec
CST.trails=48;
%CST.round=[1]; %select rounds that you want to analysis


%% output settings
output_dir = fullfile(Root_path,input_folder,Laser.wavelength,Subject.day,Subject.folder_name);
cd(output_dir{1});
if strcmp(Subject.day,'Day1') == 1
    save settings_before.mat
    disp('Successfully save the file(settings_before.mat)!');
elseif strcmp(Subject.day,'Day2') == 1
    save settings_after.mat
    disp('Successfully save the file(settings_after.mat)!');
else
    disp('Error!!! Please check this settings is for pre-test or post-test!!!')
end
% mkdir(output_dir{1});
cd(Root_path)
disp('DONE!!!');