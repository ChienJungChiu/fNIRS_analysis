%{
Wisconsin Card Sorting Test (WCST) Answer analysis

colorList = {'Red','Green','Blue','Yellow'};
shapeList = {'Circle','Triangle','Cross','Star'};
numberList = {'1','2','3','4'};

Chien-Jung Chiu
Last Update:2024/12/10
%}

clc; clear all; close all;
Root_path='/Users/amandachiu/Documents/NTU/fNIRS_analyze'; %please copy the path that your all matlab script putting in.
input_folder = 'CST_Record';
day = 'Day2'; %Day1 for pre-test, Day2 for Post-test
folder_name = 'subject';
%subject_num = [1 2 3 4 5 6 7 8 9 10 11 12 13 16 17];  %Day1
subject_num = [1 2 3 4 5 6 9 10 11 12 16];  %Day2
input_dir = fullfile(Root_path,input_folder,day);

for i = 1:length(subject_num)
    %% initialize
    input = [];
    output = [];
    output_table = [];
    errortype = [];
    rule = [];
    card = [];
    response = [];
    average_time = [];
    correct = [];



    subject = [folder_name num2str(subject_num(i))];
    input = readmatrix(fullfile(input_dir,[subject '.csv']));

    %% check if the .csv file include title
    if isnan(input(1,2)) == 1
        input = input(2:end,:);
        % the first column of Subject 1 in Day 1 record trail number
        if strcmp(day,'Day1') == 1  && subject_num(i) == 1
            input = input(:,2:end);
        end
    end
    %% check .csv file type
    if size(input, 2) < 7
        error('The input file does not contain enough columns.');
    end
    trail_num = size(input,1);
    assert(trail_num ~= 3 ,'Error .csv file! You might load the background file.');
    rule = input(:,1);  %1 = color, 2 = shape, 3 = number;
    card = input(:,2:4);
    response = input(:,5);
    average_time = mean(input(:,6));
    correct = input(:,7);
    for trail = 1:trail_num
        %% mark the current following rule
        if trail == 1
            rule_fwd = rule(1,:);
            rule_curr = rule(1,:);
        else
            rule_fwd = rule_curr;
            rule_curr = rule(trail,:);
        end
        output(trail,1) = rule_curr;

        %% classify the rule that the subject chose

        if response(trail) == card(trail,1)  %color
            output(trail,2) = 1; 

        elseif response(trail) == card(trail,2) %shape
            output(trail,2) = 2; 

        elseif response(trail) == card(trail,3)  %number
            output(trail,2) = 3; 
        else
            output(trail,2) = 0; 

        end

        %% classify which kind of error
        if correct(trail)== 0 && rule_fwd ~= rule_curr
            %if correct(trail) ~= 0
                if output(trail,2) == output(trail-1,2)
                    errortype(trail) = 1; %Perseverative error
                else
                    errortype(trail) = 2; %Non Perseverative error
                end
            %end
        elseif correct(trail)== 0 && rule_fwd == rule_curr
            %if correct(trail) ~= 0
                errortype(trail) = 2; %Non perseverative error
            %end
        else 
            errortype(trail) = 0;
        end
   
    end
    PE_num = length(find(errortype==1));
    NPE_num = length(find(errortype==2));
    TotalError = length(find(errortype~=0));
    assert(TotalError==(PE_num+NPE_num),'The error count has a bug!!!');
    %errortype = errortype';
    output = [output errortype'];
    output(1,end+1) = trail_num;
    output(1,end+1) = average_time;
    output(1,end+1) = PE_num;
    output(1,end+1) = NPE_num;
    output(1,end+1) = TotalError;
    % title = {'TestRule' 'ChoseRule' 'ErrorType'};
    % output = [cell2table(title); array2table(output)];
    % output = [0 0 0; output];
    % output(1,1) = str2double('TestRule');
    % output(1,2) = 'ChoseRule';
    % output(1,3) = 'ErrorType';
    %output = cat(1,output,errortype);
    cd(fullfile(Root_path,input_folder));
    % rowDescriptions = {'TestRule'; 'ChoseRule'; 'ErrorType'};
    %output = addvars(output, rowDescriptions, 'Before', 'Col1', 'NewVariableNames', 'Description');
    output_table = array2table(output, 'VariableNames', {'TestRule','ChoseRule','ErrorType', 'TrailNum', 'AverageResponseTime', 'PerseverativeErrorNum', 'NonPerseverativeErrorNum', 'TotalErrorNum'});
    writetable(output_table, [day '_' subject '.csv']);
    %csvwrite([day '_' subject '.csv'],output);
    cd ..

  



end