function fun_Plot_Final_Preprocess(Data,which_steps,Settings,track_index,Preprocess_Time)
%{
plot Grey level-time figure after time preprocess steps

Chien-Jung Chiu
Last Update:2025/5/31
%}

mkdir(fullfile('Processed_Data',Settings.Subject.day,Settings.Subject.folder_name{1},which_steps,'Preprocessed'))
cd(fullfile('Processed_Data',Settings.Subject.day,Settings.Subject.folder_name{1},which_steps,'Preprocessed'))

if Settings.output.Is_Ploting_Figure==0
    figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
elseif Settings.output.Is_Ploting_Figure==1
    figure('units','normalized','outerposition',[0 0 1 1],'visible','on');
end

channel_index = Settings.analysis.channel(track_index);
short_channel_index = Settings.hardware.detector.channel_pairs(channel_index,2);
long_channel_index = Settings.hardware.detector.channel_pairs(channel_index,1);

total_time=length(Data.time_series);
sampling_time = 20;
time_label_section = round(total_time/sampling_time);
for t = 1:time_label_section+1
     if t == 1
        time_label(t) = 1;
     else
        time_label(t) = sampling_time*(t-1)+1;
     end

end
figure_row = [];
figure_column = [];
figure_row=length(Preprocess_Time.Options);
figure_column=2;
% assert(figure_column==2, 'The settings of track2channel are wrong, please go back and check!!!');
figure_count=1; %initialized
%assign data
wavelength_index=round(length(Settings.analysis.wavelength_selection_database)/2);
% if strcmp(which_steps,'Laser')==1
%     DMS_round=1;
% elseif strcmp(which_steps,'DMS')==1   
%     DMS_round=Setting.experiment.DMS{index_struct.week,index_struct.subject,index_struct.TILS}.round(index_struct.DMS_round);
% elseif strcmp(which_steps,'CST')==1   
%     DMS_round=Setting.experiment.CST{index_struct.week,index_struct.subject,index_struct.TILS}.round(index_struct.CST_round);    
% end

%week=Setting.Subject.week_index{index_struct.subject}(index_struct.week);

%% generate a figure
% if track_index==1
   %figure('units','normalized','outerposition',[0 0 1 1]);
% end

%% raw spectrum
%long
figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
subplot(figure_row,figure_column,figure_count);
plot(1:size(Data.spectrum_processed_data(long_channel_index,:,:),3),reshape(Data.spectrum_processed_data(long_channel_index,wavelength_index,:),1,[]));
set(gca,'xtick',1:sampling_time:total_time);
xticklabels(time_label);
xlabel('time(sec)');
ylabel('Grey Level');
grid on;
axis([-inf inf -inf inf]);
%title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' channel_index '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' num2str(channel_index) '  Wavelength: ' num2str(Settings.analysis.wavelength_selection_database(wavelength_index)) 'nm'],'Spectrum Processed Data'});
hold on;

%short
figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
subplot(figure_row,figure_column,figure_count+1);
plot(1:size(Data.spectrum_processed_data(short_channel_index,:,:),3),reshape(Data.spectrum_processed_data(short_channel_index,wavelength_index,:),1,[]));
set(gca,'xtick',1:sampling_time:total_time);
xticklabels(time_label);
xlabel('time(sec)');
ylabel('Grey Level');
grid on;
axis([-inf inf -inf inf]);
%title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' channel_index '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(2)) ' cm  ch: ' num2str(channel_index) '  Wavelength: ' num2str(Settings.analysis.wavelength_selection_database(wavelength_index)) 'nm'],'Spectrum Processed Data'});
hold on;
figure_count = figure_count+2;

%%
if find(strcmp(Preprocess_Time.Options,'Remove ShotNoise'))~=0 
    %figure_count=figure_count+1;
    %long
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count);
    plot(1:size(Data.Remove_ShotNoise_signal(long_channel_index,:,:),3),reshape(Data.Remove_ShotNoise_signal(long_channel_index,wavelength_index,:),1,[]));
    set(gca,'xtick',1:sampling_time:total_time);
    xticklabels(time_label);
    xlabel('time(sec)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    %title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' channel_index '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' num2str(channel_index) '  Wavelength: ' num2str(Settings.analysis.wavelength_selection_database(wavelength_index)) 'nm'],'Remove ShotNoise(moving median)'});
    hold on;
    %short
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count+1);
    plot(1:size(Data.Remove_ShotNoise_signal(short_channel_index,:,:),3),reshape(Data.Remove_ShotNoise_signal(short_channel_index,wavelength_index,:),1,[]));
    set(gca,'xtick',1:sampling_time:total_time);
    xticklabels(time_label);
    xlabel('time(sec)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    %title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' channel_index '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(2)) ' cm  ch: ' num2str(channel_index) '  Wavelength: ' num2str(Settings.analysis.wavelength_selection_database(wavelength_index)) 'nm'],'Remove ShotNoise(moving median)'});
    hold on;

%   subplot(figure_raw,figure_column,track_index+figure_column*figure_count);
%   plot(1:size(Data.Remove_background(track_index,:,:),2),Data.Remove_background(track_index,:,time_point));
%   set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
%   xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
%   xlabel('wavelength(nm)');
%   ylabel('Grey Level');
%   grid on;
%   axis([-inf inf -inf inf]);
%   title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name '  D' num2str(Settings.Subject.week_index) 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(track_index)) ' cm  ch: ' num2str(Settings.analysis.channel(track_index)) '  Time Point: ' num2str(time_point)],'Remove BackGround'});
    figure_count = figure_count+2;
end

%%
if find(strcmp(Preprocess_Time.Options,'Remove Breath'))~=0
    %figure_count=figure_count+1;
    %long
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count);
    plot(1:size(Data.Remove_Breath(long_channel_index,:,:),3),reshape(Data.Remove_Breath(long_channel_index,wavelength_index,:),1,[]));
    set(gca,'xtick',1:sampling_time:total_time);
    xticklabels(time_label);
    xlabel('time(sec)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    %title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' channel_index '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' num2str(channel_index) '  Wavelength: ' num2str(Settings.analysis.wavelength_selection_database(wavelength_index)) 'nm'],'Remove Breath'});
    hold on;
    %short
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count+1);
    plot(1:size(Data.Remove_Breath(short_channel_index,:,:),3),reshape(Data.Remove_Breath(short_channel_index,wavelength_index,:),1,[]));
    set(gca,'xtick',1:sampling_time:total_time);
    xticklabels(time_label);
    xlabel('time(sec)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    %title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' channel_index '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(2)) ' cm  ch: ' num2str(channel_index) '  Wavelength: ' num2str(Settings.analysis.wavelength_selection_database(wavelength_index)) 'nm'],'Remove Breath'});
    hold on;
    figure_count = figure_count+2;
end

%%
if find(strcmp(Preprocess_Time.Options,'Remove Mayer'))~=0
    %figure_count=figure_count+1;
    %long
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count);
    plot(1:size(Data.Remove_MayerWave(long_channel_index,:,:),3),reshape(Data.Remove_MayerWave(long_channel_index,wavelength_index,:),1,[]));
    set(gca,'xtick',1:sampling_time:total_time);
    xticklabels(time_label);
    xlabel('time(sec)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    %title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' channel_index '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' num2str(channel_index) '  Wavelength: ' num2str(Settings.analysis.wavelength_selection_database(wavelength_index)) 'nm'],'Remove Mayer Wave'});
    hold on;
    %short
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count+1);
    plot(1:size(Data.Remove_MayerWave(short_channel_index,:,:),3),reshape(Data.Remove_MayerWave(short_channel_index,wavelength_index,:),1,[]));
    set(gca,'xtick',1:sampling_time:total_time);
    xticklabels(time_label);
    xlabel('time(sec)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    %title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' channel_index '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(2)) ' cm  ch: ' num2str(channel_index) '  Wavelength: ' num2str(Settings.analysis.wavelength_selection_database(wavelength_index)) 'nm'],'Remove Mayer Wave'});
    hold on;
    figure_count = figure_count+2;
end

saveas(gcf,[Settings.Subject.folder_name{1} '_' Settings.Subject.day '_' which_steps '_Ch' num2str(channel_index) '_FinalPreprocessed_by_time.jpg'])
%%
if Settings.output.Is_Ploting_Figure==0
    figure('units','normalized','outerposition',[0 0 1 1],'visible','off');
elseif Settings.output.Is_Ploting_Figure==1
    figure('units','normalized','outerposition',[0 0 1 1],'visible','on');
end
wavelength=Settings.analysis.wavelength_selection_database;
%wavelength=Settings.hardware.camera.wavelength;

%long
figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
subplot(2,1,1);
plot(1:size(Data.mean_time_Processed_Spectrum(long_channel_index,:),2),Data.mean_time_Processed_Spectrum(long_channel_index,:));
set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
xlabel('wavelength(nm)');
ylabel('Grey Level');
grid on;
axis([-inf inf -inf inf]);
%title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' channel_index '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' num2str(channel_index)],'(Mean time) Processed Spectrum'});
hold on;

%short
figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
subplot(2,1,2);
plot(1:size(Data.mean_time_Processed_Spectrum(short_channel_index,:),2),Data.mean_time_Processed_Spectrum(short_channel_index,:));
set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
xlabel('wavelength(nm)');
ylabel('Grey Level');
grid on;
axis([-inf inf -inf inf]);
title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day  ' SDS: ' num2str(Settings.hardware.detector.SDS(2)) ' cm  ch: ' num2str(channel_index)],'(Mean time) Processed Spectrum'});
hold on;


% figure_which_steps = strrep(which_steps,' ','_');
% mkdir(fullfile('Processed_Data',Settings.Subject.day,Settings.Subject.folder_name{1},which_steps))
% cd(fullfile('Processed_Data',Settings.Subject.day,Settings.Subject.folder_name{1},which_steps))
saveas(gcf,[Settings.Subject.folder_name{1} '_' Settings.Subject.day '_' which_steps '_Ch' num2str(channel_index) '_FinalPreprocessed_spectrum.jpg'])
% if track_index~=length(Settings.analysis.channel)
%     figure;
% end
% if Settings.output.Is_Ploting_Figure == 0
%     close all;
% end
cd(Settings.Root_path)
end