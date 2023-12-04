function [Settings] = fun_Creat_Homer3_NIRS_Format(channel_index,rawdata,wavelength_selection,time_series,which_steps,Settings)
short_channel_index = Settings.hardware.detector.channel_pairs(channel_index,2);
long_channel_index = Settings.hardware.detector.channel_pairs(channel_index,1);
channel_data = [rawdata(long_channel_index,:,:);rawdata(short_channel_index,:,:)]; %[long; short]
%% define
d=[];
SD.MeasList=[];

%% change array format
    for wavelength_index=1:length(wavelength_selection)
        rawdata_temp1(:,:)=channel_data(:,wavelength_index,:);
        data=rawdata_temp1';   %data(time_point,wavelength)
        %assign intensity to d
        d=cat(2,d,data); %odd_column:long channel; even_column:short channel
        
        for SDS_index=1:length(Settings.hardware.detector.SDS)
           MeasList_temp= [1 SDS_index 1 wavelength_index];
           SD.MeasList= cat(1,SD.MeasList,MeasList_temp);
        end
    end
        
    %% Format data
    
    SD.SrcPos=[0 0 0];
    SD.DetPos=[Settings.hardware.detector.SDS(1) 0 0;
               Settings.hardware.detector.SDS(2) 0 0];
    SD.nSrcs=length(Settings.hardware.source);
    SD.nDets=length(Settings.hardware.detector.SDS);
    SD.PosLasers=[1,2;3,4;5,6;7,8];
    SD.Lambda=wavelength_selection;
    SD.colors=[1 0 0;
                0 1 0];
%     SD.SrcMap=[1];
    SD.xmin=0;
    SD.xmax=0;
    SD.ymin=0;
    SD.ymax=0;    
    SD.MeasListAct=ones(size(SD.MeasList,1),1);
    SD.MeasListVis=ones(size(SD.MeasList,1),1);
    SD.SpatialUnit='cm';
    
    aux=zeros(length(time_series),size(Settings.hardware.detector.channel_pairs,2));
    s=[zeros(length(time_series),1) zeros(length(time_series),1)];
    t=time_series';
  
%     [folder_name,path5] = Generate_InputOuput_Path(tag,index_struct,Settings,1);
    %creat folder
    if strcmp(which_steps,'DMS') == 1 %[DMS Laser CST]
        MA_index = Settings.analysis.MA_round(1);
        %Settings.analysis.MA_round(1) = Settings.analysis.MA_round(1)+1;
    elseif strcmp(which_steps,'Laser') == 1
        MA_index = Settings.analysis.MA_round(2);
        %Settings.analysis.MA_round(2) = Settings.analysis.MA_round(2)+1;
    elseif strcmp(which_steps,'CST') == 1
        MA_index = Settings.analysis.MA_round(3);
        %Settings.analysis.MA_round(3) = Settings.analysis.MA_round(3)+1;
    end
    %settings.analysis.MA_round()
    input_Homor_path = fullfile(Settings.Root_path,Settings.input_folder,Settings.Laser.wavelength); %,Settings.Subject.folder_name,Settings.Subject.day);
    input_Homor_folder_name = ['Homer3_Input_MA' num2str(MA_index) '_Intensity'];
    cd(input_Homor_path{1})
    mkdir(input_Homor_folder_name,[Settings.Subject.folder_name{1} '_' Settings.Subject.day '_' which_steps]);
%     cd(Settings.Root_path)
    %% Save .nirs file .snirs
    %mkdir(which_steps)
    cd(fullfile(input_Homor_folder_name,[Settings.Subject.folder_name{1} '_' Settings.Subject.day '_' which_steps]));
    mkdir(['Ch' num2str(channel_index)])
    save(fullfile(['Ch' num2str(channel_index)],[Settings.Subject.folder_name{1} '_' Settings.Subject.day '_' which_steps '_Homer3InputSignal.nirs']),'SD','aux','d','s','t');
    cd(Settings.Root_path)
end