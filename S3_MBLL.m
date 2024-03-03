%{
Using Modified Beer Lambert Law analyze homer3 output
including calculate RMSPE and plot deltaOD, residuals, and concentration

Chien-Jung Chiu
Last update:2024/2/18
%}
clc; clear all; close all;

%global Root_path;
Root_path='/Users/amandachiu/Desktop/NTU/fNIRS_analysis_code'; %please copy the path that your all matlab script putting in.
input_folder = 'new_input';
%% load settings file
laser_wavelength='TILS-810nm'; %1064nm , 810nm TILS,you can run both at once or invidual
day='Day1'; %Day1 for pre-test, Day2 for Post-test
folder_name='Subject_7'; 
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
Settings.analysis.channel=[ 1 ]; 
%Settings.analysis.channel = 1:size(Settings.hardware.detector.channel_pairs,1);

Processed_Data = load(fullfile(input_dir,[which_steps '_after_process' strrep(num2str(Settings.analysis.channel),' ','') '.mat']));


%% plot figure settings
Plot_Option.compare_deltaOD = 1;
Plot_Option.deltaOD_spectra = 1;
Plot_Option.residual_spectra = 1;
Plot_Option.concentration = 1;
Plot_Option.residual_concentration = 1;

%% mian
%must be one of [DMS Laser CST], or else print ERROR!!!
for channel_index = 1:length(Settings.analysis.channel)
    Data.channel = Settings.analysis.channel(channel_index);
    signal_index_long = Settings.hardware.detector.channel_pairs(Data.channel,1);   %long
    signal_index_short = Settings.hardware.detector.channel_pairs(Data.channel,2);   %short

    %load from the file I've saved and origanized.
    Settings.homer_dir = fullfile(Root_path,'Processed_Data',day,folder_name,which_steps);
    homor_output = load(fullfile(Settings.homer_dir,[ folder_name '_' day '_' which_steps '_Ch' num2str(Settings.analysis.channel(channel_index)) '_DeltaOD.mat']));
    input_deltaOD = homor_output.deltaOD.all;

    %load from the original Homer3 output files.
    % homor_dir = fullfile(Root_path,input_folder,laser_wavelength,'Homer3_Input_MA0_Intensity');
    % %load(fullfile(Root_path,input_folder,laser_wavelength,'Homer3_Input_MA0_Intensity',[folder_name '_' Settings.Subject.day '_' which_steps], ['Ch' num2str(Settings.analysis.channel(channel_index))],'homerOutput',[ folder_name '_' day '_' which_steps '_Homer3InputSignal.mat']))
    % homor_output = load(fullfile(homor_dir,[ folder_name '_' day '_' which_steps], ['Ch' num2str(Settings.analysis.channel(channel_index))],'homerOutput',[ folder_name '_' day '_' which_steps '_Homer3InputSignal.mat']));
    % %input_deltaOD = homor_output.deltaOD.dataTimeSeries;
    % input_deltaOD = homor_output.output.dod.dataTimeSeries;
    
    %seperate long and short channel
    for column_num = 1:(size(input_deltaOD,2)/2)
        deltaOD.short(:,column_num) = input_deltaOD(:,column_num);
        deltaOD.long(:,column_num) = input_deltaOD(:,column_num+1);
    end
    
    
    %% shift baseline cause we want to change homor baseline(all time mean) into only baseline mean; different wavelength have different shift value  
    if strcmp(which_steps,'Laser') == 1
        %baseline = Settings.Laser.baseline;
        shifted_deltaOD_short = deltaOD.short - Processed_Data.Data.laser.shift_baseline(signal_index_short,:);
        shifted_deltaOD_long = deltaOD.long - Processed_Data.Data.laser.shift_baseline(signal_index_long,:);
        Data.deltaOD_all = [shifted_deltaOD_short shifted_deltaOD_long]';
    elseif strcmp(which_steps,'DMS') == 1
        %baseline = Settings.DMS.baseline;
        shifted_deltaOD_short = deltaOD.short - Processed_Data.Data.DMS.shift_baseline(signal_index_short,:);
        shifted_deltaOD_long = deltaOD.long - Processed_Data.Data.DMS.shift_baseline(signal_index_long,:);
        Data.deltaOD_all = [shifted_deltaOD_short shifted_deltaOD_long]';
        
        %DMS block average
        %[DMS_block_average.deltaOD_spectra,DMS_block_average.deltaOD_time,DMS_each_trail_data.deltaOD] = fun_DMS_block_average(Data.deltaOD_all,Settings,homor_output,1,1);
    elseif strcmp(which_steps,'CST') == 1
        %baseline = Settings.CST.baseline;
        shifted_deltaOD_short = deltaOD.short - Processed_Data.Data.CST.shift_baseline(signal_index_short,:);
        shifted_deltaOD_long = deltaOD.long - Processed_Data.Data.CST.shift_baseline(signal_index_long,:);
        Data.deltaOD_all = [shifted_deltaOD_short shifted_deltaOD_long]';
    end
    
    % Data.deltaOD_all = [shifted_deltaOD_short shifted_deltaOD_long]';

    
    %% main
    Data.wavelength_selection = Settings.analysis.wavelength_selection_database';
    %original_mean_pathlength = load(fullfile('mean_path','TCThesis',['Pathlength_TCThesis_' folder_name '.mat'])).B;
    original_mean_pathlength = load(fullfile('mean_path','TCThesis',['Pathlength_TCThesis_Subject_6.mat'])).mean_pathlength; %choose which PL you want to put in
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
    disp('MBLL calculation is done.');

    
    % cd(Settings.homer_dir)
    %% calculate RMSPE
    disp('Calculating RMSPE...');     
    fun_RMSPE(Data,Settings,which_steps)
    cd(Root_path)
    
    %% plot figure
    disp('Start Plotting figures...');
    fun_Plot_DeltaODorConcentration(Data,Plot_Option,Settings,which_steps)
    cd(Root_path)
    
    %% for DMS, do concentration block average
    disp('Start doing DMS concentration block average...');
    if strcmp(which_steps,'DMS') == 1
        fun_DMS_concentration_block_average(Data,Settings,which_steps)
    end
    cd(Root_path)
end