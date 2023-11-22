
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
which_steps = 'Laser';  %[DMS Laser CST], which one to analysis
%analysis_dir = fullfile(Root_path,input_folder,laser_wavelength,Settings.Subject.day,folder_name,which_steps); %,Settings.Subject.week_index);
Settings.analysis.channel=[ 2 4 ]; 

%% mian
%must be one of [DMS Laser CST], or else print ERROR!!!
%% laser 
for channel_index = 1:length(Settings.analysis.channel)
    homor_dir = fullfile(Root_path,input_folder,laser_wavelength,'Homer3_Input_MA0_Intensity',[ folder_name '_' day '_' which_steps],['Ch' num2str(Settings.analysis.channel(channel_index))]);
    if find(strcmp(which_steps,'Laser'))~=0
%         homor_output = load(fullfile(homor_dir,[ folder_name '_' day '_' which_steps '_Homer3InputSignal.nirs']),'-mat');
        homor_output = load(fullfile(homor_dir,[ folder_name '_' day '_' which_steps '_Homer3InputSignal.mat']));
        MBLL_input_deltaOD = homor_output.output.dod.dataTimeSeries;
        disp('YOU!!!')

    elseif find(strcmp(which_steps,'DMS'))~=0

    elseif find(strcmp(which_steps,'CST'))~=0

    else
        disp('YOU DID NOT SET A CORRECT STEP TO ANALYZE!!!')
    end
    %% main
    wavelength_selection = wavelength_selection';
    mean_pathlength = load(fullfile('mean_path','TCThesis','Pathlength_TCThesis_Subject_5.mat'));
    mean_pathlength = mean_pathlength.B;
    mean_pathlength = interp1(mean_pathlength(:,1), mean_pathlength(:,2:end),wavelength_selection);
    mean_pathlength = cat(2,wavelength_selection,mean_pathlength);

    molar_extinction_coefficient = load(fullfile('molar_extinction_coefficient','MolarExtinctionCoefficient.mat'));
    molar_extinction_coefficient = molar_extinction_coefficient.molar_extinction_coefficient;
    HbO2_molar_coefficient =((interp1(molar_extinction_coefficient(:,1), molar_extinction_coefficient(:,2),wavelength_selection)).*2.303); %M
    Hb_molar_coefficient =(( interp1(molar_extinction_coefficient(:,1), molar_extinction_coefficient(:,3),wavelength_selection)).*2.303);  %M
    cytoxidase_molar_coefficient =(( interp1(molar_extinction_coefficient(:,1), molar_extinction_coefficient(:,4),wavelength_selection)).*2.303);  %M
    new_molar_extinction_coefficient=[wavelength_selection HbO2_molar_coefficient Hb_molar_coefficient cytoxidase_molar_coefficient];

    approach1_ratio = 0;
    sensitivity_matrix_3=[(mean_pathlength(:,2)+approach1_ratio.*mean_pathlength(:,3)).* new_molar_extinction_coefficient(:,2:3)  mean_pathlength(:,5).*new_molar_extinction_coefficient(:,2:4) ; 
                               (mean_pathlength(:,7)+approach1_ratio.*mean_pathlength(:,8)).* new_molar_extinction_coefficient(:,2:3)  mean_pathlength(:,10).*new_molar_extinction_coefficient(:,2:4)]; 
    sensitivity_matrix_2=[(mean_pathlength(:,2)+approach1_ratio.*mean_pathlength(:,3)).* new_molar_extinction_coefficient(:,2:3)  mean_pathlength(:,5).*new_molar_extinction_coefficient(:,2:3) ; 
                               (mean_pathlength(:,7)+approach1_ratio.*mean_pathlength(:,8)).* new_molar_extinction_coefficient(:,2:3)  mean_pathlength(:,10).*new_molar_extinction_coefficient(:,2:3)]; 

end