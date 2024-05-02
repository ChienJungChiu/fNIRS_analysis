%{
Open Homer3 in specific path and save the file
I use Homer3-1.32.3 since the latest version which couldn't load the file successfully may not work.


Chien-Jung Chiu
Last Update: 2023/12/4
%}
clc; clear all; close all;

%global Root_path;
Root_path='/Users/amandachiu/Desktop/NTU/fNIRS_analysis_code'; %please copy the path that your all matlab script putting in.
input_folder = 'new_input';
%% load settings file
laser_wavelength='TILS-810nm'; %1064nm , 810nm TILS,you can run both at once or invidual
day='Day2'; %Day1 for pre-test, Day2 for Post-test
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
%% which to save
which_steps = 'DMS';  %[DMS Laser CST], which one to analysis
save_dir = fullfile(Root_path,input_folder,laser_wavelength,Settings.Subject.day,folder_name,which_steps); %,Settings.Subject.week_index);
% Settings.analysis.channel=[ 2 6 ]; 
Settings.analysis.channel=1:size(Settings.hardware.detector.channel_pairs,1) ;

% cd(fullfile(Root_path,'homer3','Homer3-master','Homer3-master'))
cd(fullfile(Root_path,'Homer3-1.32.3'))
setpaths;
Homer3;

keyboard();  %key in "dbcont" to keep running the code
cd(Root_path)
% mkdir('Processed Data');
% cd('Processed Data')
for channel_index = 1:length(Settings.analysis.channel)
    homer3_output = load(fullfile(Root_path,input_folder,laser_wavelength,'Homer3_Input_MA0_Intensity',[folder_name '_' Settings.Subject.day '_' which_steps], ['Ch' num2str(Settings.analysis.channel(channel_index))],'homerOutput',[ folder_name '_' day '_' which_steps '_Homer3InputSignal.mat'])).output.dod;
    deltaOD.all = homer3_output.dataTimeSeries;
    deltaOD.time = homer3_output.time;
    mkdir(fullfile('Processed_Data',Settings.Subject.day,folder_name,which_steps))
    cd(fullfile('Processed_Data',Settings.Subject.day,folder_name,which_steps))
    save([folder_name '_' Settings.Subject.day '_' which_steps ['_Ch' num2str(Settings.analysis.channel(channel_index))] '_DeltaOD.mat'],'deltaOD') %,'-ascii')
    cd(Root_path)
    %mkdir(,[])
    %load()
    disp('You successfully save a deltaOD file!!!')
end
disp('Done!!!')
% disp('You successfully save the deltaOD file!!!')