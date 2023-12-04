function fun_Plot_DeltaODorConcentration(Data,plot_compare_deltaOD,plot_residual_spectra,plot_concentration,plot_residual_concentration)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
plot_time_series = round(size(Data.deltaOD_all,2)/2);
wavelength_position_start = find(Data.wavelength_selection==700,1);
wavelength_position_medium = find(Data.wavelength_selection==800,1);
wavelength_position_end = find(Data.wavelength_selection==900,1);

% for t = plot_time_series
    if plot_compare_deltaOD == 1
        %short channel bt time
        figure;
        plot(Data.deltaOD_all(wavelength_position_medium,:),'r','LineWidth',2);
        hold on;
        plot(Data.calculate_deltaOD_2(wavelength_position_medium,:),'g','LineWidth',2);
        hold on;
        plot(Data.calculate_deltaOD_3(wavelength_position_medium,:),'b','LineWidth',2);
        hold on;
        title(['Ch' num2str(Data.channel) ' Short Channel']);ylabel('\DeltaOD');xlabel('Time(sec)');
        legend('measured','fit 2-chromophore','fit 3-chromophore')
        
        %long channel bt time
        figure;
        plot(Data.deltaOD_all(wavelength_position_medium+size(Data.wavelength_selection,1),:),'r','LineWidth',2);
        hold on;
        plot(Data.calculate_deltaOD_2(wavelength_position_medium+size(Data.wavelength_selection,1),:),'g','LineWidth',2);
        hold on;
        plot(Data.calculate_deltaOD_3(wavelength_position_medium+size(Data.wavelength_selection,1),:),'b','LineWidth',2);
        hold on;
        title(['Ch' num2str(Data.channel) ' Long Channel']);ylabel('\DeltaOD');xlabel('Time(sec)');
        legend('measured','fit 2-chromophore','fit 3-chromophore')
    end 
    
    if plot_residual_spectra == 1
        %short channel by wavelength
        figure;
        yyaxis left
        plot(Data.residualDeltaOD_23_spectra(wavelength_position_start:wavelength_position_end,plot_time_series),'r','LineWidth',2);
        title(['Ch' num2str(Data.channel) ' Short Channel']);xlabel('Wavelength(nm)');ylabel('Residual Difference (\DeltaOD)');
        xticks([1:10:90]);xticklabels({'700','750','800','850','900'});
        hold on;
        yyaxis right
        plot(Data.cytoxidase_molar_coefficient(wavelength_position_start:wavelength_position_end),'g','LineWidth',2);
        ylabel('molar absorption coefficient (1/M/cm)) ');
        legend('Residual Difference 2-3','oxCCO Molar Coefficient')
        
        %long channel by wavelength
        figure;
        yyaxis left
        plot(Data.residualDeltaOD_23_spectra(wavelength_position_start+size(Data.wavelength_selection,1):wavelength_position_end+size(Data.wavelength_selection,1),plot_time_series),'r','LineWidth',2);
        title(['Ch' num2str(Data.channel) ' Long Channel']);xlabel('Wavelength(nm)');ylabel('Residual Difference (\DeltaOD)');
        xticks([1:10:90]);xticklabels({'700','750','800','850','900'});
        hold on;
        yyaxis right
        plot(Data.cytoxidase_molar_coefficient(wavelength_position_start:wavelength_position_end),'g','LineWidth',2);
        ylabel('molar absorption coefficient (1/M/cm)) ');
        legend('Residual Difference 2-3','oxCCO Molar Coefficient')
        
    end
    
    if plot_concentration == 1
        %short channel by time
        figure;
        plot(Data.delta_concentration_2(1,:),'LineWidth',2); %HbO
        hold on;
        plot(Data.delta_concentration_3(1,:),'LineWidth',2); %HbO
        hold on;
        plot(Data.delta_concentration_2(2,:),'LineWidth',2); %Hb
        hold on;
        plot(Data.delta_concentration_3(2,:),'LineWidth',2); %Hb
        hold on;
        title(['Ch' num2str(Data.channel) ' Short Channel']);ylabel('Concentration');xlabel('Time(sec)');      
        legend('fit 2-HbO','fit 3-HbO','fit 2-Hb','fit 3-Hb')
        
        %long channel by time
        figure;
        plot(Data.delta_concentration_2(3,:),'LineWidth',2); %HbO
        hold on;
        plot(Data.delta_concentration_3(3,:),'LineWidth',2); %HbO
        hold on;
        plot(Data.delta_concentration_2(4,:),'LineWidth',2); %Hb
        hold on;
        plot(Data.delta_concentration_3(4,:),'LineWidth',2); %Hb
        hold on;
        plot(Data.delta_concentration_3(5,:),'LineWidth',2); %oxCCO
        title(['Ch' num2str(Data.channel) ' Long Channel']);ylabel('Concentration');xlabel('Time(sec)');      
        legend('fit 2-HbO','fit 3-HbO','fit 2-Hb','fit 3-Hb','fit 3-oxCCO')
    end   
    
    if plot_residual_concentration == 1
        %short channel by time
        figure;
        plot(Data.residualConcentration_23(1,:),'LineWidth',2); %HbO
        hold on;
        plot(Data.residualConcentration_23(2,:),'LineWidth',2); %Hb
        title(['Ch' num2str(Data.channel) ' Short Channel']);ylabel('\Delta Concentration');xlabel('Time(sec)');      
        legend('fit 2-3 HbO','fit 2-3 Hb')
        
        %long channel by time
        figure;
        plot(Data.residualConcentration_23(3,:),'LineWidth',2); %HbO
        hold on;
        plot(Data.residualConcentration_23(4,:),'LineWidth',2); %Hb
        title(['Ch' num2str(Data.channel) ' Long Channel']);ylabel('\Delta Concentration');xlabel('Time(sec)');      
        legend('fit 2-3 HbO','fit 2-3 Hb')
    end
    
% end    
end

