function fun_RMSPE(Data,Settings,which_steps)
%{
Calculate and plot RMSPE (long and short channel together)

Chein-Jung Chiu
Last Update: 2024/2/18
%}
wl_num = length(Data.wavelength_selection);
Intensity_measure_exp = exp(Data.deltaOD_all);
Intensity_cal2_exp = exp(Data.calculate_deltaOD_2);
Intensity_cal3_exp = exp(Data.calculate_deltaOD_3);
RMSPE_2 = sqrt((sum((((Intensity_cal2_exp - Intensity_measure_exp)./Intensity_measure_exp)*100).^2,1))/(2*wl_num));
RMSPE_3 = sqrt((sum((((Intensity_cal3_exp - Intensity_measure_exp)./Intensity_measure_exp)*100).^2,1))/(2*wl_num));

cd(Settings.homer_dir)
figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');
% fig = figure;
figure
plot(RMSPE_2);
hold on;
plot(RMSPE_3);
title([figure_subject_name ' ' Settings.Subject.day ' ' which_steps ' Ch' num2str(Data.channel) ' RMSPE ']);ylabel('%');xlabel('Time(sec)');
legend('RMSPE 2','RMSPE 3','Location','best')
% save_figure = getframe(fig);
saveas(gcf,[Settings.Subject.folder_name{1} '_' Settings.Subject.day '_' which_steps '_Ch' num2str(Data.channel) '_RMSPE.jpg'])
end