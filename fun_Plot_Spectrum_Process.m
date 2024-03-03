function fun_Plot_Spectrum_Process(Data,which_steps,Settings,track_index,Process_Spectrum)
%{
plot Grey level spectra after spectrum preprocess steps

Chien-Jung Chiu
Last Update: 2024/2/17
%}
channel_index = Settings.analysis.channel(track_index);
short_channel_index = Settings.hardware.detector.channel_pairs(channel_index,2);
long_channel_index = Settings.hardware.detector.channel_pairs(channel_index,1);

time_point=1;
figure_row = [];
figure_column = [];
figure_row=numel(fieldnames(Process_Spectrum));
figure_column=2;
figure_count=1; %initialized
wavelength=Settings.hardware.camera.wavelength;

%generate a figure
if track_index==1
   figure('units','normalized','outerposition',[0 0 1 1]);
end

%% raw spectrum
%long
figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
subplot(figure_row,figure_column,figure_count);
plot(1:size(Data.Rawdata(long_channel_index,:,:),2),Data.Rawdata(long_channel_index,:,time_point));
set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
xlabel('wavelength(nm)');
ylabel('Grey Level');
grid on;
axis([-inf inf -inf inf]);
title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' num2str(channel_index) '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
hold on;

%short
figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
subplot(figure_row,figure_column,figure_count+1);
plot(1:size(Data.Rawdata(short_channel_index,:,:),2),Data.Rawdata(short_channel_index,:,time_point));
set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
xlabel('wavelength(nm)');
ylabel('Grey Level');
grid on;
axis([-inf inf -inf inf]);
title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day  ' SDS: ' num2str(Settings.hardware.detector.SDS(2)) ' cm  ch: ' num2str(channel_index) '  Time Point: ' num2str(time_point)],'Raw Spectrum'});
hold on;

figure_count = figure_count+2;
if find(strcmp(Process_Spectrum.Options,'Remove Background'))~=0 
    %long
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count);
    plot(1:size(Data.Remove_background(long_channel_index,:,:),2),Data.Remove_background(long_channel_index,:,time_point));
    set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
    xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
    xlabel('wavelength(nm)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day  ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' num2str(channel_index) '  Time Point: ' num2str(time_point)],'Remove BackGround'});
    hold on;
    %short
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count+1);
    plot(1:size(Data.Remove_background(short_channel_index,:,:),2),Data.Remove_background(short_channel_index,:,time_point));
    set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
    xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
    xlabel('wavelength(nm)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(2)) ' cm  ch: ' num2str(channel_index) '  Time Point: ' num2str(time_point)],'Remove BackGround'});
    hold on;

    figure_count = figure_count+2;
end

if find(strcmp(Process_Spectrum.Options,'Remove Salt And Papper Noise'))~=0
    %long
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count);
    plot(1:size(Data.Remove_salt_papper(long_channel_index,:,:),2),Data.Remove_salt_papper(long_channel_index,:,time_point));
    set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
    xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
    xlabel('wavelength(nm)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' num2str(channel_index) '  Time Point: ' num2str(time_point)],'Remove Salt&Papper Noise(moving median)'});
    hold on;
    %short
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count+1);
    plot(1:size(Data.Remove_salt_papper(short_channel_index,:,:),2),Data.Remove_salt_papper(short_channel_index,:,time_point));
    set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
    xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
    xlabel('wavelength(nm)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(2)) ' cm  ch: ' num2str(channel_index) '  Time Point: ' num2str(time_point)],'Remove Salt&Papper Noise(moving median)'});
    hold on;


%     figure_count=figure_count+1;
%     subplot(figure_raw,figure_column,track_index+figure_column*figure_count);
%     plot(1:size(Data.Remove_salt_papper(track_index,:,:),2),Data.Remove_salt_papper(track_index,:,time_point));
%     set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
%     xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
%     xlabel('wavelength(nm)');
%     ylabel('Grey Level');
%     grid on;
%     axis([-inf inf -inf inf]);
%     title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name '  D' num2str(Settings.Subject.week_index) 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(track_index)) ' cm  ch: ' num2str(Settings.analysis.channel(track_index)) '  Time Point: ' num2str(time_point)],'Remove Salt&Papper Noise(moving median)'});
    figure_count = figure_count+2;
end

if find(strcmp(Process_Spectrum.Options,'Smooth Spectrum'))~=0
    %long
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count);
    plot(1:size(Data.Remove_salt_papper(long_channel_index,:,:),2),Data.Remove_Noisy(long_channel_index,:,time_point));
    set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
    xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
    xlabel('wavelength(nm)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(1)) ' cm  ch: ' num2str(channel_index) '  Time Point: ' num2str(time_point)],'Smooth Spectrum(moving average)'});
    hold on;
    %short
    figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
    subplot(figure_row,figure_column,figure_count+1);
    plot(1:size(Data.Remove_salt_papper(short_channel_index,:,:),2),Data.Remove_Noisy(short_channel_index,:,time_point));
    set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
    xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
    xlabel('wavelength(nm)');
    ylabel('Grey Level');
    grid on;
    axis([-inf inf -inf inf]);
    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name ' ' Settings.Subject.day ' SDS: ' num2str(Settings.hardware.detector.SDS(2)) ' cm  ch: ' num2str(channel_index) '  Time Point: ' num2str(time_point)],'Smooth Spectrum(moving average)'});
    hold on;
%    figure_count=figure_count+1;
%    subplot(figure_raw,figure_column,track_index+figure_column*figure_count);
%    plot(1:size(Data.Remove_Noisy(track_index,:,:),2),Data.Remove_Noisy(track_index,:,time_point));
%    set(gca,'xtick',1:round(length(wavelength)/10):length(wavelength));
%    xticklabels(round(wavelength(1:round(length(wavelength)/10):length(wavelength))));
%    xlabel('wavelength(nm)');
%    ylabel('Grey Level');
%    grid on;
%    axis([-inf inf -inf inf]);
%    title({[which_steps '  ' Settings.Laser.wavelength{1} ' ' figure_subject_name '  D' num2str(Settings.Subject.week_index) 'R' num2str(DMS_round) ' SDS: ' num2str(Settings.hardware.detector.SDS(track_index)) ' cm  ch: ' num2str(Settings.analysis.channel(track_index)) '  Time Point: ' num2str(time_point)],'Smooth Spectrum(moving average)'});

end
if track_index~=length(Settings.analysis.channel)
    figure;
end
if Settings.output.Is_Ploting_Figure == 0
    close all;
end

end