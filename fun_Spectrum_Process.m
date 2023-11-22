function Data= fun_Spectrum_Process(rawdata,background,ReactionTime,Preprocess_Spectrum,which_steps,Settings)
    if strcmp(which_steps,'DMS Global Baseline')==1 || strcmp(which_steps,'DMS Stimulate')==1 
        sample_time=rawdata.game_result.Kinetic;
        if strcmp(which_steps,'DMS Global Baseline')==1
            rawdata = rawdata.baseline;
            real_time=sample_time*(1:size(rawdata,3));
            cross_BackGround=find(real_time>Settings.DMS.interval(1) & real_time<=sum(Settings.DMS.interval(1:2)));
        elseif strcmp(which_steps,'DMS Stimulate')==1 
            rawdata = rawdata.stimulate{Preprocess_Spectrum.DMS_trail};
            real_time=sample_time*(1:size(rawdata,3));
            cross_BackGround=find(real_time>Settings.DMS.interval(1) & real_time<=sum(Settings.DMS.interval(1:2)));
            single_pattern_BackGround=find(real_time<=Settings.DMS.interval(1));
            dual_pattern_BackGround=find(real_time>sum(Settings.DMS.interval(1:2)) & real_time<=sum(Settings.DMS.interval(1:3)));
            blank_BackGround=find(real_time>sum(Settings.DMS.interval(1:3)) & real_time<=sum(Settings.DMS.interval,'all'));
        end
    end               
  
    for track_index=1:length(Settings.analysis.channel)   %how many channel did you choose to analyze
            
        %% rawdata           
        channel_index = Settings.analysis.channel(track_index);
        short_channel_index = Settings.hardware.detector.channel_pairs(channel_index,2);
        long_channel_index = Settings.hardware.detector.channel_pairs(channel_index,1);
        process_index = 0;
        if find(strcmp(Preprocess_Spectrum.Options,'Remove Background'))~=0 
            %% BG process
            if strcmp(which_steps,'Laser')==1
                %short channel
                temp.data(short_channel_index,:,:)=rawdata(short_channel_index,:,:); %select channel
                Data.Rawdata(short_channel_index,:,:)=temp.data(short_channel_index,:,:);
                temp.Average_background(short_channel_index,:,:)=mean(background(short_channel_index,:,:),3);
                Data.Average_background(short_channel_index,:,:) = temp.Average_background(short_channel_index,:,:);
                temp.Remove_background(short_channel_index,:,:)=Data.Rawdata(short_channel_index,:,:)-Data.Average_background(short_channel_index,:,:);
                Data.Remove_background(short_channel_index,:,:) = temp.Remove_background(short_channel_index,:,:);           
                %long channel
                temp.data(long_channel_index,:,:)=rawdata(long_channel_index,:,:); %select channel
                Data.Rawdata(long_channel_index,:,:)=temp.data(long_channel_index,:,:);
                temp.Average_background(long_channel_index,:,:)=mean(background(long_channel_index,:,:),3);
                Data.Average_background(long_channel_index,:,:) = temp.Average_background(long_channel_index,:,:);
                temp.Remove_background(long_channel_index,:,:)=Data.Rawdata(long_channel_index,:,:)-Data.Average_background(long_channel_index,:,:);
                Data.Remove_background(long_channel_index,:,:) = temp.Remove_background(long_channel_index,:,:);        
            elseif strcmp(which_steps,'DMS Global Baseline')==1                          
                %short channel
                temp.data(short_channel_index,:,:)=rawdata(short_channel_index,:,:); %select channel
                Data.Rawdata(short_channel_index,:,:)=temp.data(short_channel_index,:,:);
                temp.Average_background(short_channel_index,:,:)=mean(background(short_channel_index,:,cross_BackGround),3);
                Data.Average_background(short_channel_index,:,:) = temp.Average_background(short_channel_index,:,:);
                temp.Remove_background(short_channel_index,:,:)=Data.Rawdata(short_channel_index,:,:)-Data.Average_background(short_channel_index,:,:);
                Data.Remove_background(short_channel_index,:,:) = temp.Remove_background(short_channel_index,:,:);
                %long channel
                temp.data(long_channel_index,:,:)=rawdata(long_channel_index,:,:); %select channel
                Data.Rawdata(long_channel_index,:,:)=temp.data(long_channel_index,:,:);
                temp.Average_background(long_channel_index,:,:)=mean(background(long_channel_index,:,cross_BackGround),3);
                Data.Average_background(long_channel_index,:,:) = temp.Average_background(long_channel_index,:,:);
                temp.Remove_background(long_channel_index,:,:)=Data.Rawdata(long_channel_index,:,:)-Data.Average_background(long_channel_index,:,:);
                Data.Remove_background(long_channel_index,:,:) = temp.Remove_background(long_channel_index,:,:);
            elseif strcmp(which_steps,'DMS Stimulate')==1  
                %Encoding
                %short channel
                temp.data(short_channel_index,:,:)=rawdata(short_channel_index,:,:); %select channel
                remove_background_temp{1,1}=temp.data(short_channel_index,:,single_pattern_BackGround)-mean(background(short_channel_index,:,single_pattern_BackGround),3);
                %long channel
                temp.data(long_channel_index,:,:)=rawdata(long_channel_index,:,:); %select channel
                remove_background_temp{1,2}=temp.data(long_channel_index,:,single_pattern_BackGround)-mean(background(long_channel_index,:,single_pattern_BackGround),3);
                
                %Maintenance
                cross=cross_BackGround;
                %short channel
                remove_background_temp{2,1}=temp.data(short_channel_index,:,cross)-mean(background(short_channel_index,:,cross_BackGround),3);
                %long channel
                remove_background_temp{2,2}=temp.data(long_channel_index,:,cross)-mean(background(long_channel_index,:,cross_BackGround),3);
                
                %Retrieval
                %reaction time
                if  ReactionTime<=Settings.DMS.interval(3) %No timeout
                    dual_pattern=find(real_time>sum(Settings.DMS.interval(1:2)) & real_time<=(sum(Settings.DMS.interval(1:2))+ReactionTime));
                    %short channel
                    remove_background_temp{3,1}=temp.data(short_channel_index,:,dual_pattern)-mean(background(short_channel_index,:,dual_pattern_BackGround),3);                    
                    cross=find(real_time>(sum(Settings.DMS.interval(1:2))+ReactionTime) & real_time<=sum(Settings.DMS.interval(1:3)));
                    remove_background_temp{4,1}=temp.data(short_channel_index,:,cross)-mean(background(short_channel_index,:,cross_BackGround),3);
                    %long channel
                    remove_background_temp{3,2}=temp.data(long_channel_index,:,dual_pattern)-mean(background(long_channel_index,:,dual_pattern_BackGround),3);                    
                    cross=find(real_time>(sum(Settings.DMS.interval(1:2))+ReactionTime) & real_time<=sum(Settings.DMS.interval(1:3)));
                    remove_background_temp{4,2}=temp.data(long_channel_index,:,cross)-mean(background(long_channel_index,:,cross_BackGround),3);
                else  %timeout
                    dual_pattern=find(real_time>sum(Settings.DMS.interval(1:2)) & real_time<=sum(Settings.DMS.interval(1:3)));
                    %short channel
                    remove_background_temp{3,1}=temp.data(short_channel_index,:,dual_pattern)-mean(background(short_channel_index,:,dual_pattern_BackGround),3);
                    remove_background_temp{4,1}=[];
                    %long channel
                    remove_background_temp{3,2}=temp.data(long_channel_index,:,dual_pattern)-mean(background(long_channel_index,:,dual_pattern_BackGround),3);
                    remove_background_temp{4,2}=[];
                end
                
                %ITI
                blank=blank_BackGround;
                %short channel
                remove_background_temp{5,1}=temp.data(short_channel_index,:,blank)-mean(background(short_channel_index,:,blank_BackGround),3);
                %long channel
                remove_background_temp{5,2}=temp.data(long_channel_index,:,blank)-mean(background(long_channel_index,:,blank_BackGround),3);
                % save the data in different track
                %short channel
                temp.Average_BackGround(short_channel_index,:,:)=mean(background(short_channel_index,:,:),3);
                Data.Average_BackGround(short_channel_index,:,:) = temp.Average_BackGround(short_channel_index,:,:);
                temp.Remove_background(short_channel_index,:,:)=cat(3,remove_background_temp{1,1},remove_background_temp{2,1},remove_background_temp{3,1},remove_background_temp{4,1},remove_background_temp{5,1});
                Data.Remove_background(short_channel_index,:,:) = temp.Remove_background(short_channel_index,:,:);
                %long channel
                temp.Average_BackGround(long_channel_index,:,:)=mean(background(long_channel_index,:,:),3);
                Data.Average_BackGround(long_channel_index,:,:) = temp.Average_BackGround(long_channel_index,:,:);
                temp.Remove_background(long_channel_index,:,:)=cat(3,remove_background_temp{1,2},remove_background_temp{2,2},remove_background_temp{3,2},remove_background_temp{4,2},remove_background_temp{5,2});
                Data.Remove_background(long_channel_index,:,:) = temp.Remove_background(long_channel_index,:,:);
            elseif strcmp(which_steps,'CST')==1
                %short
                temp.data(short_channel_index,:,:)=rawdata(short_channel_index,:,:); %select channel
                Data.Rawdata(short_channel_index,:,:)=temp.data(short_channel_index,:,:);
                temp.Average_background(short_channel_index,:,:)=mean(background(short_channel_index,:,:),3);
                Data.Average_background(short_channel_index,:,:) = temp.Average_background(short_channel_index,:,:);
                temp.Remove_background(short_channel_index,:,:)=Data.Rawdata(short_channel_index,:,:)-Data.Average_background(short_channel_index,:,:);
                Data.Remove_background(short_channel_index,:,:) = temp.Remove_background(short_channel_index,:,:);
                %long channel
                temp.data(long_channel_index,:,:)=rawdata(long_channel_index,:,:); %select channel
                Data.Rawdata(long_channel_index,:,:)=temp.data(long_channel_index,:,:);
                temp.Average_background(long_channel_index,:,:)=mean(background(long_channel_index,:,:),3);
                Data.Average_background(long_channel_index,:,:) = temp.Average_background(long_channel_index,:,:);
                temp.Remove_background(long_channel_index,:,:)=Data.Rawdata(long_channel_index,:,:)-Data.Average_background(long_channel_index,:,:);
                Data.Remove_background(long_channel_index,:,:) = temp.Remove_background(long_channel_index,:,:);
            end
            process_index = 1;
        else
            disp('You did not choose to remove background!!!')
       end   
        %% remove salt and pepper noise (median filt)
       if find(strcmp(Preprocess_Spectrum.Options,'Remove Salt And Papper Noise'))~=0
           %disp('check!!!');
           if Preprocess_Spectrum.median_filter_window_size>0           
               %short
               temp.data(short_channel_index,:,:)=movmedian(Data.Remove_background(short_channel_index,:,:),round(Preprocess_Spectrum.median_filter_window_size),2);
               Data.Remove_salt_papper(short_channel_index,:,:) = temp.data(short_channel_index,:,:);
               assert(sum(abs(Data.Remove_salt_papper(short_channel_index,:,:)-Data.Remove_background(short_channel_index,:,:)),'all')~=0, 'Remove Salt And Papper Noise does not work!!!');       
               %long
               temp.data(long_channel_index,:,:)=movmedian(Data.Remove_background(long_channel_index,:,:),round(Preprocess_Spectrum.median_filter_window_size),2);
               Data.Remove_salt_papper(long_channel_index,:,:) = temp.data(long_channel_index,:,:);
               assert(sum(abs(Data.Remove_salt_papper(long_channel_index,:,:)-Data.Remove_background(long_channel_index,:,:)),'all')~=0, 'Remove Salt And Papper Noise does not work!!!');
               process_index = 2;
           else
               error('analysis.median_filter_window_size  must > 0 !!!!!!!!!!! ');
           end
       end


        %% smooth spectrum (moving average)
       if find(strcmp(Preprocess_Spectrum.Options,'Smooth Spectrum'))~=0
          if Preprocess_Spectrum.smooth_filter_window_size>0
              %short
              temp.Remove_Noisy(short_channel_index,:,:)=movmean(Data.Remove_salt_papper(short_channel_index,:,:),round(Preprocess_Spectrum.smooth_filter_window_size),2);
              Data.Remove_Noisy(short_channel_index,:,:)=temp.Remove_Noisy(short_channel_index,:,:);
              assert(sum(abs(Data.Remove_Noisy(short_channel_index,:,:)-Data.Remove_salt_papper(short_channel_index,:,:)),'all')~=0, 'Smooth Spectrum does not work!!!');
              %long
              temp.Remove_Noisy(long_channel_index,:,:)=movmean(Data.Remove_salt_papper(long_channel_index,:,:),round(Preprocess_Spectrum.smooth_filter_window_size),2);
              Data.Remove_Noisy(long_channel_index,:,:)=temp.Remove_Noisy(long_channel_index,:,:);
              assert(sum(abs(Data.Remove_Noisy(long_channel_index,:,:)-Data.Remove_salt_papper(long_channel_index,:,:)),'all')~=0, 'Smooth Spectrum does not work!!!');
              process_index = 3;
          else
              error('analysis.smooth_filter_window_size  must > 0 !!!!!!!!!!! ');
          end
       end
       if process_index == 0
           disp('For spectrum process, You did nothing!!!');
       elseif process_index == 1
           disp('For spectrum process, Your last step is Remove Background.');
           Data.Final_Spectrum_Processed_Data(short_channel_index,:,:)=Data.Remove_background(short_channel_index,:,:);
           Data.Final_Spectrum_Processed_Data(long_channel_index,:,:)=Data.Remove_background(long_channel_index,:,:);
       elseif process_index == 2
           disp('For spectrum process, Your last step is Remove Salt And Papper Noise.');
           Data.Final_Spectrum_Processed_Data(short_channel_index,:,:)=Data.Remove_salt_papper(short_channel_index,:,:);
           Data.Final_Spectrum_Processed_Data(long_channel_index,:,:)=Data.Remove_salt_papper(long_channel_index,:,:);
       elseif process_index == 3
           disp('For spectrum process, Your last step is Smooth Spectrum.');
           Data.Final_Spectrum_Processed_Data(short_channel_index,:,:)=Data.Remove_Noisy(short_channel_index,:,:);
           Data.Final_Spectrum_Processed_Data(long_channel_index,:,:)=Data.Remove_Noisy(long_channel_index,:,:);
       end

       for wavelength_index=1:length(Settings.analysis.wavelength_selection_database)
           target_spectrum=ceil((Settings.analysis.wavelength_selection_database(wavelength_index)-Settings.hardware.camera.wavelength_boundary(1))/((Settings.hardware.camera.wavelength_boundary(2)-Settings.hardware.camera.wavelength_boundary(1))/length(Settings.hardware.camera.wavelength)));
           temp.Final_Spectrum_Processed_Data_with_selected_wavelength(short_channel_index,wavelength_index,:)=sum(Data.Final_Spectrum_Processed_Data(short_channel_index,target_spectrum,:),2);
           Data.Final_Spectrum_Processed_Data_with_selected_wavelength(short_channel_index,wavelength_index,:) = temp.Final_Spectrum_Processed_Data_with_selected_wavelength(short_channel_index,wavelength_index,:);
           temp.Final_Spectrum_Processed_Data_with_selected_wavelength(long_channel_index,wavelength_index,:)=sum(Data.Final_Spectrum_Processed_Data(long_channel_index,target_spectrum,:),2);
           Data.Final_Spectrum_Processed_Data_with_selected_wavelength(long_channel_index,wavelength_index,:) = temp.Final_Spectrum_Processed_Data_with_selected_wavelength(long_channel_index,wavelength_index,:);
       end
       if strcmp(which_steps,'Laser')==1 ||  strcmp(which_steps,'DMS Global Baseline')==1 ||  strcmp(which_steps,'CST')==1 
           if Settings.output.Is_Ploting_Figure==1
               %% plot DataProcess            
               fun_Plot_Spectrum_Process(Data,which_steps,Settings,track_index,Preprocess_Spectrum);
           end
       end
    end
end