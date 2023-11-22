function Selected_Data = fun_Select_analysis_wavelength(wavelength_selection,Input_Data,Settings)
   for track_index=1:size(Settings.hardware.detector.channel_pairs,2)
        for wavelength_index=1:length(wavelength_selection)
            target_spectrum=ceil((wavelength_selection(wavelength_index)-Settings.hardware.camera.wavelength_boundary(1))/((Settings.hardware.camera.wavelength_boundary(2)-Settings.hardware.camera.wavelength_boundary(1))/length(Settings.hardware.camera.wavelength)));
            Selected_Data(track_index,wavelength_index,:)=sum(Input_Data(track_index,target_spectrum,:),2);
        end
    end
end