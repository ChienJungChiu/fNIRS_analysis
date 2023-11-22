function Data = fun_Time_Process(spectrum_processed_data,rawdata,Preprocess_Time,which_steps,Settings)

%% assign data
wavelength_selection=Settings.analysis.wavelength_selection_database;
if strcmp(which_steps,'Laser')==1
    rawdata.laser.Time = size(spectrum_processed_data,3);
    Data.time_series=rawdata.laser.real_time;
    Data.EachTrail_TimeLength=rawdata.laser.Time_Length;
    sample_time=rawdata.laser.settings.results.Kinetic;
    Baseline_Time_Length=Settings.analysis.baseline_time_length.laser;
    SmoothFactor_Time_Noise=Preprocess_Time.smooth_factor.Time_Noise.laser;
    DeltaOD_Smooth_Factor=Preprocess_Time.smooth_factor.DeltaOD.laser;
elseif strcmp(which_steps,'DMS')==1
    Data.time_series=rawdata.DMS.real_time;
    Data.EachTrail_TimeLength=rawdata.DMS.all_time_length;
    sample_time=rawdata.DMS.game_result.Kinetic;
    Baseline_Time_Length=Settings.analysis.baseline_time_length.DMS;
    SmoothFactor_Time_Noise = Preprocess_Time.smooth_factor.Time_Noise.DMS;
    DeltaOD_Smooth_Factor=Preprocess_Time.smooth_factor.DeltaOD.DMS;
elseif strcmp(which_steps,'CST')==1
    Data.time_series=rawdata.CST.real_time.all;
    Data.EachTrail_TimeLength=[length(rawdata.CST.real_time.baseline); length(rawdata.CST.real_time.stimulate)];
    sample_time=rawdata.CST.game_result.Kinetic;
    Baseline_Time_Length=Settings.analysis.baseline_time_length.CST;
    SmoothFactor_Time_Noise = Preprocess_Time.smooth_factor.Time_Noise.CST;
    DeltaOD_Smooth_Factor=Preprocess_Time.smooth_factor.DeltaOD.CST;   
end

Data.filter_windowsize=round(length(Data.time_series)*SmoothFactor_Time_Noise);

%% filter type design
if find(strcmp(Preprocess_Time.Options,'Remove Breath'))~=0 
    PhysologyFilter.breath_filter=designfilt('bandstopiir','FilterOrder',2,'HalfPowerFrequency1',0.28,'HalfPowerFrequency2',0.32,'DesignMethod','butter','SampleRate',1/sample_time);
    Is_Filtering=1;
else
    PhysologyFilter=''
end
if find(strcmp(Preprocess_Time.Options,'Remove Mayer'))~=0 
    PhysologyFilter.mayer_filter=designfilt('bandstopiir','FilterOrder',2,'HalfPowerFrequency1',0.09,'HalfPowerFrequency2',0.11,'DesignMethod','butter','SampleRate',1/sample_time); 
    Is_Filtering=1;
end

for track_index=1:length(Settings.analysis.channel)  %how many SDS did you choose to analyze
    process_index = 0;
    channel_index = Settings.analysis.channel(track_index);
    for SDS_index=1:size(Settings.hardware.detector.channel_pairs,2)
        
        if SDS_index == 1
            signal_index = Settings.hardware.detector.channel_pairs(channel_index,1);   %long
        elseif SDS_index == 2
            signal_index = Settings.hardware.detector.channel_pairs(channel_index,2);   %short
        end
        
        for wavelength_index=1:length(wavelength_selection)

            %store raw intensity
            temp.spectrum_processed_data=spectrum_processed_data;        
            Data.spectrum_processed_data= temp.spectrum_processed_data;

            %% remove shotnoise by raw data
            if  find(strcmp(Preprocess_Time.Options,'Remove ShotNoise'))~=0 
               if SmoothFactor_Time_Noise>0
                   %short channel 
                   temp.Remove_ShotNoise_signal(signal_index,wavelength_index,:)=movmedian(Data.spectrum_processed_data(signal_index,wavelength_index,:),Data.filter_windowsize,3);  
                   assert(sum(abs(Data.spectrum_processed_data(signal_index,wavelength_index,:)-temp.Remove_ShotNoise_signal(signal_index,wavelength_index,:)),'all')~=0,'You did not remove shotnoise successfully!!!')
                   Data.Remove_ShotNoise_signal(signal_index,wavelength_index,:) = temp.Remove_ShotNoise_signal(signal_index,wavelength_index,:);
                   process_index = 1;
               else
                   error('Smooth ShotNoise factor must > 0 !!!!!!!!');
               end
            end

            %% remove physology signal
            if find(strcmp(Preprocess_Time.Options,'Remove Breath'))~=0 
               %short channel
               temp.Remove_PhysologicalSignal_Breath=filtfilt(PhysologyFilter.breath_filter,reshape(Data.Remove_ShotNoise_signal(signal_index,wavelength_index,:),[],size(Data.Remove_ShotNoise_signal(signal_index,wavelength_index,:),3)));
               assert(sum(abs(reshape(Data.Remove_ShotNoise_signal(signal_index,wavelength_index,:),[],size(Data.Remove_ShotNoise_signal(signal_index,wavelength_index,:),3))-temp.Remove_PhysologicalSignal_Breath),'all')~=0,'You did not remove breath successfully!!!')
               Data.Remove_Breath(signal_index,wavelength_index,:)= temp.Remove_PhysologicalSignal_Breath;
               process_index = 2;
            end

            if find(strcmp(Preprocess_Time.Options,'Remove Mayer'))~=0 
                 %filt mayer
                temp.Remove_PhysologicalSignal_mayer=filtfilt(PhysologyFilter.mayer_filter,temp.Remove_PhysologicalSignal_Breath);
                assert(sum(abs(reshape(Data.Remove_Breath(signal_index,wavelength_index,:),[],size(Data.Remove_Breath(signal_index,wavelength_index,:),3))-temp.Remove_PhysologicalSignal_mayer),'all')~=0,'You did not remove shotnoise successfully!!!')
                Data.Remove_MayerWave(signal_index,wavelength_index,:)= temp.Remove_PhysologicalSignal_mayer; 
                process_index = 3;
            end
        end

        if process_index == 0
           disp('For time process, You did nothing!!!');
        elseif process_index == 1
           disp('For time process, Your last step is Remove ShotNoise.');
           Data.Final_Processed_Spectrum(signal_index,:,:)=Data.Remove_ShotNoise_signal(signal_index,:,:);
        elseif process_index == 2
           disp('For time process, Your last step is Remove Breath.');
           Data.Final_Processed_Spectrum(signal_index,:,:)=Data.Remove_Breath(signal_index,:,:);
        elseif process_index == 3
           disp('For time process, Your last step is Remove Mayer.');
           Data.Final_Processed_Spectrum(signal_index,:,:)=Data.Remove_MayerWave(signal_index,:,:);
        end

        %% generate deltaOD
        baseline_time_start=Data.EachTrail_TimeLength(1)-round(Baseline_Time_Length/sample_time)+1;
        baseline_time_end=Data.EachTrail_TimeLength(1); 

        if baseline_time_start<1
           baseline_time_start=1;
        end

        %baselins avg
        temp.Intensity_Baseline_Avg=mean(Data.Final_Processed_Spectrum(:,:,baseline_time_start:baseline_time_end),3);
        temp.Intensity_all_Avg=mean(Data.Final_Processed_Spectrum,3);
        Data.Intensity_Baseline_Avg = temp.Intensity_Baseline_Avg;
        Data.Intensity_all_Avg = temp.Intensity_all_Avg;
        %calculate precentage error
        Data.Error(signal_index,:,:)=(reshape(Data.Final_Processed_Spectrum(signal_index,:,:),size(Data.Final_Processed_Spectrum(signal_index,:,:),2),size(Data.Final_Processed_Spectrum(signal_index,:,:),3))-Data.Intensity_Baseline_Avg(signal_index,:)')./Data.Intensity_Baseline_Avg(signal_index,:)'.*100;
        
        
        %deltaOD generated
        Data.deltaOD(signal_index,:,:)= fun_generate_deltaOD(reshape(Data.Final_Processed_Spectrum(signal_index,:,:),size(Data.Final_Processed_Spectrum(signal_index,:,:),2),size(Data.Final_Processed_Spectrum(signal_index,:,:),3)),Data.Intensity_Baseline_Avg(signal_index,:)',DeltaOD_Smooth_Factor);
        Data.deltaOD_homor(signal_index,:,:)= fun_generate_deltaOD(reshape(Data.Final_Processed_Spectrum(signal_index,:,:),size(Data.Final_Processed_Spectrum(signal_index,:,:),2),size(Data.Final_Processed_Spectrum(signal_index,:,:),3)),Data.Intensity_all_Avg(signal_index,:)',DeltaOD_Smooth_Factor);
        
        Data.Intensity_Ratio(signal_index,:,:) =exp(Data.deltaOD(signal_index,:,:));
        Data.deltaOD_Baseline_STD(signal_index,:)=std(Data.deltaOD(signal_index,:,baseline_time_start:baseline_time_end),0,3);
    end
    
    if find(strcmp(Preprocess_Time.Options,'Remove Motion Artifact'))~=0
        [Settings] = fun_Creat_Homer3_NIRS_Format(channel_index,Data.Final_Processed_Spectrum,wavelength_selection,Data.time_series,which_steps,Settings);
    end
    
    Data.mean_time_Processed_Spectrum=mean(Data.Final_Processed_Spectrum,3);
    
    %% Plot the processed 
    if Settings.output.Is_Ploting_Figure==1
        fun_Plot_Final_Preprocess(Data,which_steps,Settings,track_index,Preprocess_Time)
    end
end  
end