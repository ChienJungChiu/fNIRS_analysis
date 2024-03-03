%{
S1_PreProcessed_1
You can only analyze one kind of experiments (steps) for a person at a
time
Please run sections by sections!!!
This program will do the spectrum domain data process first, then do the
time domain data process.
It will automatically save the processed data results (with .mat file) and
also generate the delta OD and the file wich could be used for Homor3 after
the data signal process steps.

Chien-Jung Chiu
Last Update: 2023/12/4
%}
clc; clear all; close all;

%global Root_path;
Root_path='/Users/amandachiu/Desktop/NTU/fNIRS_analysis_code'; %please copy the path that your all matlab script putting in.
input_folder = 'CJ_test';
%% load settings file
laser_wavelength='TILS-810nm'; %1064nm , 810nm TILS,you can run both at once or invidual
day='Day1'; %Day1 for pre-test, Day2 for Post-test
folder_name='Subject_6'; 
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
which_steps = 'DMS';  %[DMS Laser CST], which one to analysis
analysis_dir = fullfile(Root_path,input_folder,laser_wavelength,Settings.Subject.day,folder_name,which_steps); %,Settings.Subject.week_index);
Settings.analysis.channel=[1]; 
%Settings.analysis.channel = 1:size(Settings.hardware.detector.channel_pairs,1);

%% Process_Spectrum_Option
Preprocess_Spectrum.Options={'Remove Background' 'Remove Salt And Papper Noise' 'Smooth Spectrum' 'Smooth Pathlength'};  %  'Remove Background' 'Remove Salt And Papper Noise' 'Smooth Spectrum' 'Smooth Pathlength'
Preprocess_Spectrum.median_filter_window_size=5; %points   set 0 if you do not use median filter
Preprocess_Spectrum.smooth_filter_window_size=5; %points   set 0 if you do not use moving AVG filter
Preprocess_Spectrum.smooth_pathlength_window_size=5;
Settings.Preprocess_Spectrum = Preprocess_Spectrum;
%% output settings
Settings.output.Is_Writing_Excel = 1;
Settings.output.Is_Ploting_Figure = 1;
Settings.output.Is_Output_Movie = 1;

%% Process_Time_Option
if strcmp(which_steps,'DMS') ~= 0
    Preprocess_Time.Options={'Remove ShotNoise' 'Remove Breath' 'Remove Motion Artifact'}; %you can selected key in 'Remove ShotNoise' 'Remove Breath' 'Remove Motion Artifact'
else
    Preprocess_Time.Options={'Remove ShotNoise' 'Remove Breath' 'Remove Mayer' 'Remove Motion Artifact'}; %you can selected key in 'Remove ShotNoise' 'Remove Breath' 'Remove Mayer' 'Remove Motion Artifact'
end

Preprocess_Time.smooth_factor.motion_artifact.DMS=0.0085; % precentage   input 0 if do not need any smooth
Preprocess_Time.smooth_factor.Time_Noise.DMS=0.005; % precentage
Preprocess_Time.smooth_factor.motion_artifact.laser=0.014; % precentage  input 0 if do not need any smooth
Preprocess_Time.smooth_factor.Time_Noise.laser=0.005; % precentage
Preprocess_Time.smooth_factor.motion_artifact.CST=0.0085; % precentage   input 0 if do not need any smooth
Preprocess_Time.smooth_factor.Time_Noise.CST=0.005; % precentage

Preprocess_Time.smooth_factor.DeltaOD.DMS=0; %precentage
Preprocess_Time.smooth_factor.DeltaOD.laser=0; %precentage
Preprocess_Time.smooth_factor.DeltaOD.CST=0; %precentage

Preprocess_Time.smooth_factor.Concentration.DMS=0; %precentage
Preprocess_Time.smooth_factor.Concentration.laser=0; %precentage
Preprocess_Time.smooth_factor.Concentration.CST=0; %precentage
Settings.Preprocess_Time = Preprocess_Time;

%the scale on the figure
figure_time_scale.all.DMS=20; %sec
figure_time_scale.all.laser=60; %sec
figure_time_scale.all.CST=60; %sec
Settings.analysis.figure_time_scale = figure_time_scale;

% baseline settings
Settings.analysis.baseline_time_length.DMS=119; %sec
Settings.analysis.baseline_time_length.laser=120; %sec
Settings.analysis.baseline_time_length.CST=119; %sec

Settings.analysis.baseline_time_show_in_figure.DMS=119; %sec
Settings.analysis.baseline_time_show_in_figure.laser=120;
Settings.analysis.baseline_time_show_in_figure.CST=119;
%% error code
if find(strcmp(which_steps,'Laser'))~=0  %if you didn't choose in which_steps, you won't enter
  if Settings.analysis.MA_round(2)~=0 
    error('In S1, Settings.analysis.MA_round(3) must be 0 for laser !!!!!');
  end
elseif find(strcmp(which_steps,'DMS'))~=0 
  if Settings.analysis.MA_round(1)~=0
    error('In S1, Settings.analysis.MA_round(1) must be 0 for DMS Before !!!!!');
  end
elseif find(strcmp(which_steps,'CST'))~=0 
  if Settings.analysis.MA_round(3)~=0
    error('In S1, Settings.analysis.MA_round(4) must be 0 for CST Before !!!!!');
  end
end

%% mian
%must be one of [DMS Laser CST], or else print ERROR!!!
%% laser 
if find(strcmp(which_steps,'Laser'))~=0
    %read data
    laser_path = fullfile(Root_path,input_folder,laser_wavelength,day,folder_name,which_steps);
    rawdata.laser.settings = load(fullfile(laser_path,'LaserResult.mat'));  %includes Exposure, Accumulate(how many frames did it take average), Kinetic(how many frames did camera take after one click)
    rawdata.laser.baseline = load(fullfile(laser_path,'baselineLaser.mat'));
    rawdata.laser.background = load(fullfile(laser_path,'backgroundLaser.mat'));
    rawdata.laser.recovery = load(fullfile(laser_path,'recovery.mat')).I;
    baseline_time_length=size(rawdata.laser.baseline.I,3);
    recovery_time_length=size(rawdata.laser.recovery,3);
    %define
    rawdata.laser.trail_combine_mat=[]; 
    stimulate_time_length=[];
    for laser_index=1:Settings.Laser.trails
       rawdata.laser.stimulate{laser_index}=double(importdata(fullfile(laser_path,['laser' num2str(laser_index) '.mat'])).I);
       rawdata.laser.trail_combine_mat=cat(3,rawdata.laser.trail_combine_mat,rawdata.laser.stimulate{laser_index});
       stimulate_time_length=cat(1,stimulate_time_length,size(rawdata.laser.stimulate{laser_index},3));
    end
    %combine all data
    rawdata.laser.Time_Length=cat(1,baseline_time_length,stimulate_time_length,recovery_time_length);
    rawdata.laser.all=cat(3,rawdata.laser.baseline.I,rawdata.laser.trail_combine_mat,rawdata.laser.recovery);
    assert((Settings.hardware.camera.HFullpixel./Settings.hardware.camera.Hbin)==size(rawdata.laser.all,2),'The pixel or Hbin setting is wrong!!!');
    
    rawdata.laser.background=rawdata.laser.background.I;
    rawdata.laser.sample_time=rawdata.laser.settings.results.Kinetic;
    rawdata.laser.real_time=rawdata.laser.sample_time*(1:size(rawdata.laser.all,3));
    
    %spectrum domain process (including remove background) 
    Data.laser = fun_Spectrum_Process(rawdata.laser.all,rawdata.laser.background,'none',Preprocess_Spectrum,which_steps,Settings);
    Data.laser = fun_Time_Process(Data.laser.Final_Spectrum_Processed_Data_with_selected_wavelength,rawdata,Preprocess_Time,which_steps,Settings);
    
    %save mat.
%     cd(Settings.output_dir{1});
%     save([which_steps '_after_process' strrep(num2str(Settings.analysis.channel),' ','') '.mat'],'Data','Settings')
%     cd(Settings.Root_path);     

%    Actaul_Time=Settings.Laser.baseline+Settings.Laser.per_stimulate*Settings.Laser.trails+Settings.Laser.recovery;
    
%% DMS
elseif  find(strcmp(which_steps,'DMS'))~=0
    DMS_path = fullfile(Root_path,input_folder,laser_wavelength,day,folder_name,which_steps);
    DMSBG_path = fullfile(Root_path,input_folder,laser_wavelength,day,folder_name,[which_steps 'BG']);
    rawdata.DMS.baseline=importdata(fullfile(DMS_path,'DMSbaseline.mat'));
    temp = [];
    for DMS_BG_trails_index=1:Settings.DMS.background_trails
        temp=importdata(fullfile(DMSBG_path,['DMStrial' num2str(DMS_BG_trails_index) '.mat']));
        DMS_BG(DMS_BG_trails_index,:,:,:) = temp;
    end
    % mean of all DMStrails background
    average_trail_BG=mean(DMS_BG,1);
    rawdata.DMS.average_trail_BG = reshape(average_trail_BG,size(average_trail_BG,2),size(average_trail_BG,3),size(average_trail_BG,4));
    rawdata.DMS.game_result=importdata(fullfile(DMS_path,'DMSResults.mat'));

    for DMS_trial_index= 1 : Settings.DMS.trails
        rawdata.DMS.stimulate{DMS_trial_index}=importdata(fullfile(DMS_path,['DMStrial' num2str(DMS_trial_index) '.mat']));                        
    end

    sample_time=rawdata.DMS.game_result.Kinetic;
    Data.DMS.baseline = fun_Spectrum_Process(rawdata.DMS,rawdata.DMS.average_trail_BG,'none',Preprocess_Spectrum,'DMS Global Baseline',Settings);

    rawdata.DMS.stimulate_time_length=[]; %define
    clear Data.DMS.baseline_time_length;
    %initialize 
    rawdata.DMS.baseline_time_length=size(Data.DMS.baseline.Final_Spectrum_Processed_Data_with_selected_wavelength,3);

    %each DMS trails process invidivually
    Data.DMS.all.stimulate = [];
    for DMS_trail_index=1:Settings.DMS.trails
        Preprocess_Spectrum.DMS_trail=DMS_trail_index;
        DMS_stimulate_ReactionTime=rawdata.DMS.game_result.ResponseTime(DMS_trail_index);
        Data.DMS.stimulate(DMS_trail_index) = fun_Spectrum_Process(rawdata.DMS,rawdata.DMS.average_trail_BG,DMS_stimulate_ReactionTime,Preprocess_Spectrum,'DMS Stimulate',Settings);
        Data.DMS.all.stimulate=cat(3,Data.DMS.all.stimulate,Data.DMS.stimulate(DMS_trail_index).Final_Spectrum_Processed_Data_with_selected_wavelength);
        
        time_temp=size(Data.DMS.stimulate(DMS_trail_index).Final_Spectrum_Processed_Data_with_selected_wavelength,3);
        rawdata.DMS.stimulate_time_length=cat(1,rawdata.DMS.stimulate_time_length,time_temp);
    end
    rawdata.DMS.all_time_length = cat(1,rawdata.DMS.baseline_time_length,rawdata.DMS.stimulate_time_length);
    Data.DMS.all = cat(3,Data.DMS.baseline.Final_Spectrum_Processed_Data_with_selected_wavelength,Data.DMS.all.stimulate);
    
    Actaul_Time=Settings.DMS.baseline+Settings.DMS.trails*sum(Settings.DMS.interval);
    rawdata.DMS.real_time=linspace(0,Actaul_Time,size(Data.DMS.all,3));
    
    Data.DMS = fun_Time_Process(Data.DMS.all,rawdata,Preprocess_Time,which_steps,Settings);
    
    %save mat.
%     cd(Settings.output_dir{1});
%     save([which_steps '_after_process' strrep(num2str(Settings.analysis.channel),' ','') '.mat'],'Data','Settings')
%     cd(Settings.Root_path);     

    
%% CST
elseif  find(strcmp(which_steps,'CST'))~=0
    CST_path = fullfile(Root_path,input_folder,laser_wavelength,day,folder_name,which_steps);
    CSTBG_path = fullfile(Root_path,input_folder,laser_wavelength,day,folder_name,[which_steps 'BG']);
    rawdata.CST.baseline=importdata(fullfile(CST_path,'CSTbaseline.mat'));
    rawdata.CST.stimulate=importdata(fullfile(CST_path,'CardSorting.mat'));
    rawdata.CST.game_result=importdata(fullfile(CST_path,'results.mat'));
    if size(rawdata.CST.baseline,3) ~= Settings.CST.baseline
        disp('The setting baseline does not match the experiment data baseline!!!');
    end
    rawdata.CSTBG.baseline=importdata(fullfile(CSTBG_path,'CSTbaseline.mat'));
    rawdata.CSTBG.stimulate=importdata(fullfile(CSTBG_path,'CardSorting.mat'));
    rawdata.CSTBG.all=cat(3,rawdata.CSTBG.baseline,rawdata.CSTBG.stimulate);

    rawdata.CST.sample_time=rawdata.CST.game_result.Kinetic;
    rawdata.CST.real_time.baseline=rawdata.CST.sample_time*(1:size(rawdata.CST.baseline,3));
    rawdata.CST.real_time.stimulate=rawdata.CST.sample_time*(1:size(rawdata.CST.stimulate,3));
    rawdata.CST.real_time.all = cat(2,rawdata.CST.real_time.baseline,rawdata.CST.real_time.stimulate);
    
    Data.CST.baseline = fun_Spectrum_Process(rawdata.CST.baseline,rawdata.CSTBG.all,'none',Preprocess_Spectrum,which_steps,Settings);
    Data.CST.stimulate = fun_Spectrum_Process(rawdata.CST.stimulate,rawdata.CSTBG.all,'none',Preprocess_Spectrum,which_steps,Settings);
    Data.CST.all = cat(3,Data.CST.baseline.Final_Spectrum_Processed_Data_with_selected_wavelength,Data.CST.stimulate.Final_Spectrum_Processed_Data_with_selected_wavelength);

    Data.CST = fun_Time_Process(Data.CST.all,rawdata,Preprocess_Time,which_steps,Settings);

else
    disp("You enter a wrong step to deal with!!! Please check which_steps to do with!!!")
end
    
%save mat.
cd(Settings.output_dir{1});
save([which_steps '_after_process' strrep(num2str(Settings.analysis.channel),' ','') '.mat'],'Data','Settings')
disp('You save the .mat file after using this S1_PreProcessed_1 code!!!')
cd(Settings.Root_path);   