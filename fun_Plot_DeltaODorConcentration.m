function fun_Plot_DeltaODorConcentration(Data,Plot_Option,Settings,which_steps)                      
%{
plot DeltaOD, concentration change -> including residuals

Chien-Jung Chiu
Last Update: 2024/2/14
%}

plot_time_series = round(size(Data.deltaOD_all,2)/2);
time_rate = 5; %for spectra view, plot spectra each 5 sec
wl_position_start = find(Data.wavelength_selection==700,1);
wl_position_medium = find(Data.wavelength_selection==800,1);
wl_position_end = find(Data.wavelength_selection==900,1);

% select which wavelength to plot figure by time
%plot_wavelength = [find(Data.wavelength_selection==760,1) find(Data.wavelength_selection==800,1) find(Data.wavelength_selection==850,1)];
plot_wavelength = [760 800 850];
figure_subject_name = strrep(Settings.Subject.folder_name{1},'_',' ');

cd(Settings.homer_dir)

% for t = plot_time_series
    if Plot_Option.compare_deltaOD == 1
        %short channel by time
        figure;
        
        for wl = 1:length(plot_wavelength)
            subplot(length(plot_wavelength),2,2*wl-1);
            plot(Data.deltaOD_all(find(Data.wavelength_selection==plot_wavelength(wl),1),:),'r','LineWidth',1);
            hold on;
            plot(Data.calculate_deltaOD_2(find(Data.wavelength_selection==plot_wavelength(wl),1),:),'g','LineWidth',1);
            hold on;
            plot(Data.calculate_deltaOD_3(find(Data.wavelength_selection==plot_wavelength(wl),1),:),'b','LineWidth',1);
            hold on;
            title([ figure_subject_name ' ' which_steps ' Ch' num2str(Data.channel) ' \DeltaOD Short Channel ' num2str(plot_wavelength(wl)) 'nm']);ylabel('\DeltaOD');xlabel('Time(sec)');
            legend('measured','fit 2-chromophore','fit 3-chromophore','Location','best','FontSize',8); %,'Box','off')
            
            %long channel by time
            subplot(length(plot_wavelength),2,2*wl);
            plot(Data.deltaOD_all(find(Data.wavelength_selection==plot_wavelength(wl),1)+size(Data.wavelength_selection,1),:),'r','LineWidth',1);
            hold on;
            plot(Data.calculate_deltaOD_2(find(Data.wavelength_selection==plot_wavelength(wl),1)+size(Data.wavelength_selection,1),:),'g','LineWidth',1);
            hold on;
            plot(Data.calculate_deltaOD_3(find(Data.wavelength_selection==plot_wavelength(wl),1)+size(Data.wavelength_selection,1),:),'b','LineWidth',1);
            hold on;
            title([figure_subject_name ' ' which_steps ' Ch' num2str(Data.channel) ' \DeltaOD Long Channel ' num2str(plot_wavelength(wl)) 'nm']);ylabel('\DeltaOD');xlabel('Time(sec)');
            legend('measured','fit 2-chromophore','fit 3-chromophore','Location','best','FontSize',8); %,'Box','off')
        end
        % saveas(gcf,[Settings.Subject.folder_name{1} '_' which_steps '_Ch' num2str(Data.channel) '_deltaOD_by_time.jpg'])

    end
    
    if Plot_Option.deltaOD_spectra == 1
        plotbar=waitbar(0,'Ploting short channel deltaOD spectra by time...');
        %cd(Settings.homer_dir)
        v = VideoWriter([Settings.Subject.folder_name{1} '_' Settings.Subject.day '_' which_steps '_Ch' num2str(Data.channel) '_DeltaOD_spectra.avi'] );
        v.FrameRate = 1;
        open(v)
        % writeVideo(v,A)
        % close(v)
        % delete(f);

        %short channel by wavelength
        for t = 1:floor(plot_time_series/time_rate)
            waitbar(t/floor(plot_time_series/time_rate),plotbar,'Ploting short channel deltaOD spectra by time...'); 
            figure;
            plot(Data.deltaOD_all(wl_position_start:wl_position_end,t*time_rate),'r','LineWidth',1);
            hold on;
            plot(Data.calculate_deltaOD_2(wl_position_start:wl_position_end,t*time_rate),'g','LineWidth',1);
            hold on;
            plot(Data.calculate_deltaOD_3(wl_position_start:wl_position_end,t*time_rate),'b','LineWidth',1);
            hold on;
            title([figure_subject_name ' ' which_steps ' Ch' num2str(Data.channel) ' Short Channel \DeltaOD Spectra ' num2str(time_rate*t) 'sec']);ylabel('\DeltaOD');
            xlabel('Wavelength(nm)');xticks([1:10:wl_position_end-wl_position_start+1]);xticklabels({'700','750','800','850','900'});  %please check the wavelength range yoou choose to plot at the beginning of this function
            legend('measured','fit 2-chromophore','fit 3-chromophore','Location','best')
            set(gcf,'visible','off')
            
            %long channel by wavelength
            figure;
            plot(Data.deltaOD_all(wl_position_start+size(Data.wavelength_selection,1):wl_position_end+size(Data.wavelength_selection,1),t*time_rate),'r','LineWidth',1);
            hold on;
            plot(Data.calculate_deltaOD_2(wl_position_start+size(Data.wavelength_selection,1):wl_position_end+size(Data.wavelength_selection,1),t*time_rate),'g','LineWidth',1);
            hold on;
            plot(Data.calculate_deltaOD_3(wl_position_start+size(Data.wavelength_selection,1):wl_position_end+size(Data.wavelength_selection,1),t*time_rate),'b','LineWidth',1);
            hold on;
            title([figure_subject_name ' ' which_steps ' Ch' num2str(Data.channel) ' Long Channel \DeltaOD Spectra ' num2str(time_rate*t) 'sec']);ylabel('\DeltaOD ');
            xlabel('Wavelength(nm)');xticks([1:10:wl_position_end-wl_position_start+1]);xticklabels({'700','750','800','850','900'});  %please check the wavelength range yoou choose to plot at the beginning of this function
            legend('measured','fit 2-chromophore','fit 3-chromophore','Location','best')
            set(gcf,'visible','off')
            A = getframe(gcf);
            writeVideo(v,A)
        end
        
        close(v)
        delete(plotbar);
    end
    
    if Plot_Option.residual_spectra == 1
        %short channel by wavelength
        figure;
        yyaxis left
        plot(Data.residualDeltaOD_23_spectra(wl_position_start:wl_position_end,plot_time_series),'r','LineWidth',2);
        title([figure_subject_name ' ' which_steps 'Ch' num2str(Data.channel) ' Residual \DeltaOD Short Channel']);xlabel('Wavelength(nm)');ylabel('Residual Difference (\DeltaOD)');
        xticks([1:10:wl_position_end-wl_position_start+1]);xticklabels({'700','750','800','850','900'});%please check the wavelength range yoou choose to plot at the beginning of this function
        hold on;
        yyaxis right
        plot(Data.cytoxidase_molar_coefficient(wl_position_start:wl_position_end),'g','LineWidth',2);
        ylabel('molar absorption coefficient (1/M/cm)) ');
        legend('Residual Difference 2-3','oxCCO Molar Coefficient')
        
        %long channel by wavelength
        figure;
        yyaxis left
        plot(Data.residualDeltaOD_23_spectra(wl_position_start+size(Data.wavelength_selection,1):wl_position_end+size(Data.wavelength_selection,1),plot_time_series),'r','LineWidth',2);
        title([figure_subject_name ' ' which_steps 'Ch' num2str(Data.channel) ' Residual \DeltaOD Long Channel']);xlabel('Wavelength(nm)');ylabel('Residual Difference (\DeltaOD)');
        xticks([1:10:wl_position_end-wl_position_start+1]);xticklabels({'700','750','800','850','900'});%please check the wavelength range yoou choose to plot at the beginning of this function
        hold on;
        yyaxis right
        plot(Data.cytoxidase_molar_coefficient(wl_position_start:wl_position_end),'g','LineWidth',2);
        ylabel('molar absorption coefficient (1/M/cm)) ');
        legend('Residual Difference 2-3','oxCCO Molar Coefficient')
        
    end
    
    if Plot_Option.concentration == 1
        %short channel by time
        figure;
        plot(Data.delta_concentration_2(1,:),'LineWidth',1); %HbO
        hold on;
        plot(Data.delta_concentration_3(1,:),'LineWidth',1); %HbO
        hold on;
        plot(Data.delta_concentration_2(2,:),'LineWidth',1); %Hb
        hold on;
        plot(Data.delta_concentration_3(2,:),'LineWidth',1); %Hb
        hold on;
        title([figure_subject_name ' ' which_steps 'Ch' num2str(Data.channel) ' Concentration Short Channel']);ylabel('Concentration');xlabel('Time(sec)');      
        legend('fit 2-HbO','fit 3-HbO','fit 2-Hb','fit 3-Hb')
        
        %long channel by time
        figure;
        plot(Data.delta_concentration_2(3,:),'LineWidth',1); %HbO
        hold on;
        plot(Data.delta_concentration_3(3,:),'LineWidth',1); %HbO
        hold on;
        plot(Data.delta_concentration_2(4,:),'LineWidth',1); %Hb
        hold on;
        plot(Data.delta_concentration_3(4,:),'LineWidth',1); %Hb
        hold on;
        plot(Data.delta_concentration_3(5,:),'LineWidth',1); %oxCCO
        title([figure_subject_name ' ' which_steps 'Ch' num2str(Data.channel) ' Concentration Long Channel']);ylabel('Concentration');xlabel('Time(sec)');      
        legend('fit 2-HbO','fit 3-HbO','fit 2-Hb','fit 3-Hb','fit 3-oxCCO')
    end   
    
    if Plot_Option.residual_concentration == 1
        %short channel by time
        figure;
        plot(Data.residualConcentration_23(1,:),'LineWidth',1); %HbO
        hold on;
        plot(Data.residualConcentration_23(2,:),'LineWidth',1); %Hb
        title([figure_subject_name ' ' which_steps 'Ch' num2str(Data.channel) ' Residual Concentration Short Channel']);ylabel('\Delta Concentration');xlabel('Time(sec)');      
        legend('fit 2-3 HbO','fit 2-3 Hb','Location','best')
        legend('Location','n')
        
        %long channel by time
        figure;
        plot(Data.residualConcentration_23(3,:),'LineWidth',1); %HbO
        hold on;
        plot(Data.residualConcentration_23(4,:),'LineWidth',1); %Hb
        title([figure_subject_name ' ' which_steps 'Ch' num2str(Data.channel) ' Residual Concentration Long Channel']);ylabel('\Delta Concentration');xlabel('Time(sec)');      
        legend('fit 2-3 HbO','fit 2-3 Hb','Location','best')
    end
  
% end    
end

