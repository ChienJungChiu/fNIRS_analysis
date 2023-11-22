function deltaOD = fun_generate_deltaOD(Process_SelectedData,Baseline_SelectedData_Average,DeltaOD_Smooth_Factor)
%%  generate delta OD                                          
    % generate delta OD
    deltaOD=real(-log(Process_SelectedData./Baseline_SelectedData_Average));

         %% smooth deltaOD over time
    if  DeltaOD_Smooth_Factor~=0
       deltaOD=medfilt2(deltaOD,[0 (round(size(deltaOD,2)*DeltaOD_Smooth_Factor))]);
    end
end