function [outputArg1,outputArg2] = fun_DMS_concentration_block_average(Data,Settings,which_steps)
%{
for DMS, do concentration block average
we don't analyze deltaOD block average because of the complexity of high
domain (wavelength).

Chien-Jung Chiu
Last Update: 2024/4/29
%}

cd(Settings.homer_dir)
figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');

trail_num = Settings.DMS.trails;
baseline = Settings.DMS.baseline;
stimulate = Settings.DMS.stimulate;

sum2 = 0;
sum3 = 0;
figure('units','normalized','outerposition',[0 0 1 1]);
for trail_index = 1:trail_num
    Concentration_2{trail_index} = Data.delta_concentration_2(:,baseline+1+(trail_index-1)*stimulate:baseline+trail_index*stimulate); %2 absorption assumption
    Concentration_3{trail_index} = Data.delta_concentration_3(:,baseline+1+(trail_index-1)*stimulate:baseline+trail_index*stimulate); %3 absorption assumption
    Time{trail_index} = [baseline+1+(trail_index-1)*stimulate baseline+trail_index*stimulate];
    
    %shift to zero (start from beginning)
    shifted_2{trail_index} = Concentration_2{trail_index} - Concentration_2{trail_index}(:,1);
    shifted_3{trail_index} = Concentration_3{trail_index} - Concentration_3{trail_index}(:,1); 

    %sum
    sum2 = sum2+shifted_2{trail_index};
    sum3 = sum3+shifted_3{trail_index};
    %subplot(1,2,1);plot(Concentration_2{trail_index}(2,:));hold on;subplot(1,2,2);plot(shift_concentration_2{trail_index}(2,:));hold on;legend
end

block_average_2 = sum2/trail_num;
block_average_3 = sum3/trail_num;

subplot(2,1,1);plot(block_average_2');hold on;
title([figure_subject_name ' ' Settings.Subject.day ' ' which_steps ' Ch' num2str(Data.channel) ' Assumption2 DMS Block Average ']);ylabel('\Delta Concentration');xlabel('Time(sec)');
legend('Hb superficial','HbO superficial','Hb GM','HbO GM','Location','best')
subplot(2,1,2);plot(block_average_3');hold on;
title([figure_subject_name ' ' Settings.Subject.day ' ' which_steps ' Ch' num2str(Data.channel) ' Assumption3 DMS Block Average ']);ylabel('\Delta Concentration');xlabel('Time(sec)');
legend('Hb superficial','HbO superficial','Hb GM','HbO GM','oxCCO_GM','Location','best')
saveas(gcf,[Settings.Subject.folder_name{1} '_' Settings.Subject.day '_' which_steps '_Ch' num2str(Data.channel) '_DMS_Concentration_block_average.jpg'])

end