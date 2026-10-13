clc
clear
close all

% Define O/F array
OF_st = 0.5;
OF_end = 7;
OF_inc = 0.1;
OF = OF_st:OF_inc:OF_end;

% Define p_chamber array 
p_st = 1; %[bar]
p_end = 50; %[bar]
p_inc = 0.5; %[bar]
p = p_st:p_inc:p_end; %[bar]

%% Initialize empty cell arrays for each parameter
cstar_table = cell(length(OF)+1, length(p)+1);
CF_perfect_table = cell(length(OF)+1, length(p)+1);
Isp_perfect_table = cell(length(OF)+1, length(p)+1);

% Fill the first column with pressure values
cstar_table(2:end, 1) = num2cell(OF);
CF_perfect_table(2:end, 1) = num2cell(OF);
Isp_perfect_table(2:end, 1) = num2cell(OF);

% Fill the first row with O/F values
cstar_table(1, 2:end) = num2cell(p);
CF_perfect_table(1, 2:end) = num2cell(p);
Isp_perfect_table(1, 2:end) = num2cell(p);

% Name the first cell as OF/Pressure
% Don't assign str! Assign NaN 
cstar_table{1, 1} = 'OF/Pressure';
CF_perfect_table{1, 1} = 'OF/Pressure';
Isp_perfect_table{1, 1} = 'OF/Pressure';

%% Loop through O/F and p_chamber and calculate performance parameters with CEA_Win 
for i = 1:length(OF)
    OF_i = OF(i);
    
    for j = 1:length(p)
        p_i = p(j);
        
        % Call the function "CEA_Win" with appropriate arguments
        % CEA_Win('name additive AL(cr)(not used)', 'Name Ox1', 'Name Ox2(not used)', Paraffin rel. weight (1), ox1 rel. weight (OF), add. rel .weight (0), p_chamber, AR, T_paraffin, T_oxid, T_add, p_ambient)
        result_table = CEA_Win('AL(cr)', 'O2 (L)', 'N2O', 1, OF_i, 0, p_i, 1, 293, 293, 293, 14.7);
        
        % Extract the values from the returned table
        cstar = result_table.cstar;
        CF_perfect = result_table.CF_perfect;
        Isp_perfect = result_table.Isp_perfect;
%         Ivac = result_table.Ivac;
        
        % Store the results in the cell arrays
        cstar_table{i+1, j+1} = cstar;
        CF_perfect_table{i+1, j+1} = CF_perfect;
        Isp_perfect_table{i+1, j+1} = Isp_perfect;
    end
end

% Display the tables
disp(cstar_table);
disp(CF_perfect_table);
disp(Isp_perfect_table);

%% Write the output excel file
% filename = 'output_NO2table.xlsx';
filename = 'output_LO2table.xlsx';

% Write c_star table in excel 
xlswrite(filename, cstar_table, 'cstar_table');

% Write CF_perfect_table table in excel 
xlswrite(filename, CF_perfect_table, 'CF_perfect_table');

% Write Isp_perfect_table table in excel 
xlswrite(filename, Isp_perfect_table, 'Isp_perfect_table');