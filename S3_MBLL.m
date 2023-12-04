
clc; clear all; close all;

global Root_path;
Root_path='/home/md703/Documents/CJ/TILS_analysis_code'; %please copy the path that your all matlab script putting in.
input_folder = 'CJ_test';
%% load settings file
laser_wavelength='TILS-810nm'; %1064nm , 810nm TILS,you can run both at once or invidual
day='Day1'; %Day1 for pre-test, Day2 for Post-test
folder_name='Subject_5'; 
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
%analysis_dir = fullfile(Root_path,input_folder,laser_wavelength,Settings.Subject.day,folder_name,which_steps); %,Settings.Subject.week_index);
Settings.analysis.channel=[ 2 5 6 ]; 

%% plot figure settings
plot_compare_deltaOD = 1;
plot_residual_spectra = 1;
plot_concentration = 1;
plot_residual_concentration = 1;

%% mian
%must be one of [DMS Laser CST], or else print ERROR!!!
for channel_index = 1:length(Settings.analysis.channel)
    Data.channel = Settings.analysis.channel(channel_index);
    homor_dir = fullfile(Root_path,input_folder,laser_wavelength,'Homer3_Input_MA0_Intensity',[ folder_name '_' day '_' which_steps],['Ch' num2str(Settings.analysis.channel(channel_index))]);
    homor_output = load(fullfile(homor_dir,'homerOutput',[ folder_name '_' day '_' which_steps '_Homer3InputSignal.mat']));
    input_deltaOD = homor_output.output.dod.dataTimeSeries;
    
    %seperate long and short channel
    for column_num = 1:(size(input_deltaOD,2)/2)
        deltaOD_short(:,column_num) = input_deltaOD(:,column_num);
        deltaOD_long(:,column_num) = input_deltaOD(:,column_num+1);
    end
    Data.deltaOD_all = [deltaOD_short deltaOD_long]';
    
    %% main
    Data.wavelength_selection = Settings.analysis.wavelength_selection_database';
    original_mean_pathlength = load(fullfile('mean_path','TCThesis',['Pathlength_TCThesis_' folder_name '.mat'])).B;
    mean_pathlength = interp1(original_mean_pathlength(:,1),original_mean_pathlength(:,2:end),Data.wavelength_selection);
    Data.mean_pathlength = cat(2,Data.wavelength_selection,mean_pathlength);

    molar_extinction_coefficient = load(fullfile('molar_extinction_coefficient','MolarExtinctionCoefficient.mat'));
    molar_extinction_coefficient = molar_extinction_coefficient.molar_extinction_coefficient;
    Data.HbO2_molar_coefficient =((interp1(molar_extinction_coefficient(:,1), molar_extinction_coefficient(:,2),Data.wavelength_selection)).*2.303); %M
    Data.Hb_molar_coefficient =(( interp1(molar_extinction_coefficient(:,1), molar_extinction_coefficient(:,3),Data.wavelength_selection)).*2.303);  %M
    Data.cytoxidase_molar_coefficient =(( interp1(molar_extinction_coefficient(:,1), molar_extinction_coefficient(:,4),Data.wavelength_selection)).*2.303);  %M
    new_molar_extinction_coefficient=[Data.wavelength_selection Data.HbO2_molar_coefficient Data.Hb_molar_coefficient Data.cytoxidase_molar_coefficient];  %[HbO2 Hb oxCCO]

    approach1_ratio = 0;  %The ratio between scalp and skull, we assume the pathlength of skull is a propotion of scalp's.
    Data.sensitivity_matrix_3=[(Data.mean_pathlength(:,2)+approach1_ratio.*Data.mean_pathlength(:,3)).* new_molar_extinction_coefficient(:,2:3)  Data.mean_pathlength(:,5).*new_molar_extinction_coefficient(:,2:4) ;   %superficial layer
                               (Data.mean_pathlength(:,7)+approach1_ratio.*Data.mean_pathlength(:,8)).* new_molar_extinction_coefficient(:,2:3)  Data.mean_pathlength(:,10).*new_molar_extinction_coefficient(:,2:4)];  %deep layer
    Data.sensitivity_matrix_2=[(Data.mean_pathlength(:,2)+approach1_ratio.*Data.mean_pathlength(:,3)).* new_molar_extinction_coefficient(:,2:3)  Data.mean_pathlength(:,5).*new_molar_extinction_coefficient(:,2:3) ; 
                               (Data.mean_pathlength(:,7)+approach1_ratio.*Data.mean_pathlength(:,8)).* new_molar_extinction_coefficient(:,2:3)  Data.mean_pathlength(:,10).*new_molar_extinction_coefficient(:,2:3)]; 
    Data.delta_concentration_2=Data.sensitivity_matrix_2\Data.deltaOD_all; %unit: molar
    Data.delta_concentration_3=Data.sensitivity_matrix_3\Data.deltaOD_all;
    Data.residualConcentration_23 = Data.delta_concentration_2(1:4,:) - Data.delta_concentration_3(1:4,:);

    Data.calculate_deltaOD_2 = Data.sensitivity_matrix_2*Data.delta_concentration_2;
    Data.calculate_deltaOD_3 = Data.sensitivity_matrix_3*Data.delta_concentration_3;
    Data.residualDeltaOD_23_spectra = Data.calculate_deltaOD_2 - Data.calculate_deltaOD_3;
    
    %% plot figure
    fun_Plot_DeltaODorConcentration(Data,plot_compare_deltaOD,plot_residual_spectra,plot_concentration,plot_residual_concentration)
end