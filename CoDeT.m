clc
clear 
close all
%% CEA_Win('name additive AL(cr)(not used)', 'Name Ox1', 'Name Ox2(not used)', Paraffin rel. weight (1), ox1 rel. weight (OF), 
% add. rel .weight (0), p_chamber, AR, T_paraffin, T_oxid, T_add, p_ambient)

% CEA_Win('AL(cr)', 'N2O', 'O2', .9, 2.4, .10, 1000, 20, 293, 293, 293, 14.7)

%%% User inputs
%% Read input parameters from Excel file
filename = 'input_table.xlsx';
[num, txt, raw] = xlsread(filename);
%% CEA_win inputs 
Addt = raw{2, 2};
Ox_1 = raw{3, 2}; % oxidizer
% Ox_1 = 'N2O(L)'; % oxidizer
Ox_2 = raw{4, 2}; % not used
m_par = num(1); % 1 for pure paraffin without additives
% m_ox1 =  2.4; % If m_parr = 1, m_ox1 = OF
m_addt = num(3); % for pure paraffin = 0
P_c = num(4); % [bar]
AR = num(5);
T_par = num(6); % [Kelvin]
T_oxid = num(7); % [Kelvin]
T_add = num(8); % [Kelvin]
p_amb = num(9); % [PSIA]

%% Combustion Inputs
F_des = num(10); % N
comb_eff = num(11);
G_o_initial = num(12); % [kg/(s*m^2)]
D_p_max = num(13);  % mm
t_burn = num(14); % s
dt = num(15); 
% Burn time array
t = 0:dt:t_burn; % time list ends at the desired burn time
% D_inj = num(16); % mm


%% Define O/F array 
OF_st = num(17);
OF_end = num(18);
OF_inc = num(19);
OF_list = OF_st:OF_inc:OF_end; % double

%% Constants 
% Fuel: Paraffin, Oxidizer: N2O
a = num(20); 
n = num(21); 

rho_f = num(22); % [kg/m^3] fuel density 
%Input end
%% Burn area 
D_p_max = D_p_max*1e-3; % mm --> m 
A_p_max = pi*D_p_max^2*0.25; % [m^2] grain cross sectional area

%% Initialize empty cell arrays for each parameter
cstar_table = zeros(length(OF_list), 2);
CF_perfect_table = zeros(length(OF_list), 2);
Isp_perfect_table = zeros(length(OF_list), 2);
T_chamber_table = zeros(length(OF_list), 2);
m_tot_table = zeros(length(OF_list), 2);

%% Loop through O/F and p_chamber and calculate performance parameters with CEA_Win 
for i = 1:length(OF_list)
    
    % Call the function "CEA_Win" with appropriate arguments
%     CEA_Win('name additive AL(cr)(not used)', 'Name Ox1', 'Name Ox2(not used)', Paraffin rel. weight (1), ox1 rel. weight (OF), add. rel .weight (0), p_chamber, AR, T_paraffin, T_oxid, T_add, p_ambient)
    result_table = CEA_Win(Addt, Ox_1, Ox_2, m_par, OF_list(i), m_addt, P_c, AR, T_par, T_oxid, T_add, p_amb);

    % Store respective O/F in the cell arrays
    cstar_table(i, 1) = OF_list(i);
    CF_perfect_table(i, 1) = OF_list(i);
    Isp_perfect_table(i, 1) = OF_list(i); % can also be changed to I_vac
    T_chamber_table(i, 1) = OF_list(i);
    m_tot_table(i, 1) = OF_list(i);
    % Store the results in the cell arrays
    cstar_table(i, 2) = result_table.cstar;
    CF_perfect_table(i, 2) = result_table.CF_perfect;
    Isp_perfect_table(i, 2) = result_table.Isp_perfect; % can also be changed to I_vac
    T_chamber_table(i, 2) = result_table.T_chamber;
    m_tot_table(i,2) = F_des/(result_table.CF_perfect*result_table.cstar*comb_eff); % [kg/s]
end
%% Save OF vs. performance parameter tables PCA
% Specify the directory to save the .mat file
% Get the current working directory
currentDir = pwd;

% Specify the directory to save the .mat file
saveDir = fullfile(currentDir);
% Change names according to ox
cstar_table_PCA_Z_LOX = cstar_table;
CF_perfect_table_PCA_Z_LOX = CF_perfect_table;
Isp_table_PCA_Z_LOX = Isp_perfect_table;
T_chamber_table_PCA_Z_LOX = T_chamber_table;
m_tot_table_PCA_Z_LOX = m_tot_table;

% Save the performance parameters as a .mat file
save(fullfile(saveDir, 'performance_parameters.mat'), 'cstar_table_PCA_Z_LOX', 'CF_perfect_table_PCA_Z_LOX', 'Isp_table_PCA_Z_LOX', 'T_chamber_table_PCA_Z_LOX', 'm_tot_table_PCA_Z_LOX');

%% Plot
% Plot cstar versus O/F
figure;
plot(cstar_table(:,1), cstar_table(:,2), 'b.');
xlabel('O/F');
ylabel('cstar [m/s]');
title('Characteristic Velocity vs O/F Ratio');
% saveas(gcf, 'cstar_vs_OF.png');

% Plot CF_perfect versus O/F
figure;
plot(CF_perfect_table(:,1), CF_perfect_table(:,2), 'r.');
xlabel('O/F');
ylabel('C_{F}_{perfect} [-]');
title('Thrust Coefficient vs O/F Ratio');
% saveas(gcf, 'CF_perfect_vs_OF.png');

% Plot T_chamber versus O/F
figure;
plot(T_chamber_table(:,1), T_chamber_table(:,2), '.');
xlabel('O/F');
ylabel('T_{chamber}[K]');
title('Combustion Chamber Temperature vs O/F Ratio');
% saveas(gcf, 'T_chamber_vs_OF.png');

% Plot Isp_perfect versus O/F
figure;
plot(Isp_perfect_table(:,1), Isp_perfect_table(:,2), 'm.');
xlabel('O/F');
ylabel('I{sp}_{perfect} [s]');
title('Isp_{perfect} vs O/F Ratio');
% saveas(gcf, 'Isp_perfect_vs_OF.png');

% Plot m_tot versus O/F
figure;
plot(m_tot_table(:,1), m_tot_table(:,2), '.');
xlabel('O/F Ratio');
ylabel('m_{tot}');
title('m_{tot} vs O/F');
% saveas(gcf, 'm_tot_vs_OF.png');


%% Choose the initial O/F ratio for the min total mass flow and max Isp
% Initialize burn time arrays
m_tot = zeros(1, length(t));
m_f = zeros(1, length(t));
m_o = zeros(1, length(t));

r = zeros(1, length(t));
G_o = zeros(1, length(t));

F = zeros(1, length(t));

A_p = zeros(1, length(t));
A_b = zeros(1, length(t));
D_p = zeros(1, length(t));

OF = zeros(1, length(t));
CF_perfect = zeros(1, length(t));
Isp_perfect = zeros(1, length(t));
cstar = zeros(1, length(t));
T_chamber = zeros(1, length(t));

% Find the index of maximum Isp_perfect
[max_Isp, max_Isp_index] = max(Isp_perfect_table(:, 2));

% Print the O/F ratio at the index of maximum Isp_perfect
OF(1) = Isp_perfect_table(max_Isp_index, 1);
m_tot(1) = m_tot_table(max_Isp_index, 2);
CF_perfect(1) = CF_perfect_table(max_Isp_index, 2);
Isp_perfect(1) = Isp_perfect_table(max_Isp_index, 2);
cstar(1) = cstar_table(max_Isp_index, 2);
T_chamber(1) = T_chamber_table(max_Isp_index, 2); 
m_f(1) = m_tot(1)/(OF(1)+1);
m_o(1) = m_tot(1)-m_f(1);

G_o(1) = G_o_initial;
F(1) = F_des;

r(1) = a*G_o(1)^n; % [mm/s]     % calculate the regression rate

A_p(1) = m_o(1)/G_o(1); % [m^2]
D_p(1) = (4*A_p(1)/pi)^0.5; % [m]
%D_p_0 = D_p(1)*1e3; % [mm]    % output: initial port diameter 
% A_n = F_des/(c_f_m_tot_min*P_c*1e5);


%% Find the grain length
% The length of the grain must be able to deliver enough m_f to
% support the initial O/F ratio
tol = 0.05;
for z = 2:1e6 % z is the grain length in mm. Find the min z for OF_initial
    A_b(z) = pi * D_p(1) * z * 1e-3; % [m^2] % calculate burn area 
    m_f_z(z) = A_b(z) * rho_f * r(1) * 1e-3; % [kg/s] fuel mass flow
    OF_z(z) = m_o(1)/m_f_z(z); 
    res = abs(OF_z(z)-OF(1)); % residuum
    if res < tol
        l = z*1e-3; 
        break
    end
end
l_grain = l*1e3; % m --> mm output grain length 
A_b(1) = pi*D_p(1)*l; % [m^2]

%% Combustion Chamber
for j = 2 : length(t)
    D_p(j) = D_p(j-1) + (2*r(j-1)*1e-3)*dt; % [m] % calculate D_p from the previous r (*dt increases the frequency of r)
    if D_p(j) > D_p_max % break when the fuel has ran out
        error("Fuel has ran out at " + t(j) +" seconds. Increase D_p_max or G_o or decrease t_burn")
    end
    A_p(j) = (pi*D_p(j)^2)*0.25; % [m^2] port opens up 
    A_b(j) = pi*D_p(j)*l; % [m^2] 
    m_o(j) = m_o(1); % [kg/s] fuel mass flow with time 
    % Careful: G_o and r are not continuous and have values that are valid in between the seconds
    G_o(j) = m_o(j)/(A_p(j)); % [kg/(s*m^2)]
    r(j) = a*G_o(j)^n; % [mm/s] % calculate the regression rate to be used in the next step
    m_f(j) = A_b(j) * rho_f * r(j)*1e-3; % [kg/s] fuel mass flow over time 
    m_tot(j) = m_f(j) + m_o(j); % [kg/s] 
    OF(j) = m_o(j)/m_f(j);
    
    % Call CEA_win again to calculate parameters for every OF ratio during
    % the combustion
%     result_table_comb = CEA_Win(Addt, Ox_1, Ox_2, m_par, OF(j), m_addt, P_c, AR, T_par, T_oxid, T_add, p_amb);
%     cstar(j) = result_table_comb.cstar;
%     CF_perfect(j) = result_table_comb.CF_perfect;
%     Isp_perfect(j) = result_table_comb.Isp_perfect; % can also be changed to I_vac
%     T_chamber(j) = result_table_comb.T_chamber;
%     F(j) = CF_perfect(j)*m_tot(j)*cstar(j)*comb_eff; % [N] thrust --- f = dt seconds

  % Interpolate the parameters from the previously created tables
    cstar(j) = interp1(OF_list,cstar_table(:,2),OF(j));
    CF_perfect(j) = interp1(OF_list,CF_perfect_table(:,2),OF(j));
    Isp_perfect(j) = interp1(OF_list,Isp_perfect_table(:,2),OF(j));
    T_chamber(j) = interp1(OF_list,T_chamber_table(:,2),OF(j));
    F(j) = CF_perfect(j)*m_tot(j)*cstar(j)*comb_eff; % [N] thrust
end

%% POST COMBUSTION ANALYSIS

% % Initial values of combustion
% currentDir = pwd;
% 
% % Specify the directory to save the .mat file
% saveDir = fullfile(currentDir);
% 
% % Copy matfile.inp and matfile.out to the output directory
% copyfile('matfile.inp', saveDir);
% copyfile('matfile.out', saveDir);
% copyfile('input_table.xlsx', saveDir);

% Save the combustion analysis data as a .mat file
save(fullfile(saveDir, 'CA_LOX.mat'),'t', 'm_tot', 'm_o', 'm_f', 'G_o', 'r', 'D_p','A_p','A_b','OF','cstar','CF_perfect','Isp_perfect','T_chamber','l_grain','F');

%% Save output data in .xlsx file
n_row=length(t)+1;
output_Table = cell(n_row,13);

t_cell=num2cell(t);
m_tot_cell=num2cell(m_tot);
m_o_cell=num2cell(m_o);
m_f_cell=num2cell(m_f);
G_o_cell=num2cell(G_o);
r_cell=num2cell(r);
D_p_cell=num2cell(D_p);
A_p_cell=num2cell(A_p);
A_b_cell=num2cell(A_b);
OF_cell=num2cell(OF);
cstar_cell=num2cell(cstar);
CF_perfect_cell=num2cell(CF_perfect);
Isp_perfect_cell=num2cell(Isp_perfect);
T_chamber_cell=num2cell(T_chamber);
l_grain_cell=num2cell(l_grain);
F_cell=num2cell(F);

output_Table(2:n_row,1) = t_cell(1,:);
output_Table(2:n_row,2) = m_tot_cell(1,:);
output_Table(2:n_row,3) = m_o_cell(1,:);
output_Table(2:n_row,4) = m_f_cell(1,:);
output_Table(2:n_row,5) = G_o_cell(1,:);
output_Table(2:n_row,6) = r_cell(1,:);
output_Table(2:n_row,7) = D_p_cell(1,:);
output_Table(2:n_row,8) = A_p_cell(1,:);
output_Table(2:n_row,9) = A_b_cell(1,:);
output_Table(2:n_row,10) = OF_cell(1,:);
output_Table(2:n_row,11) = cstar_cell(1,:);
output_Table(2:n_row,12) = CF_perfect_cell(1,:);
output_Table(2:n_row,13) = Isp_perfect_cell(1,:);
output_Table(2:n_row,14) = T_chamber_cell(1,:);
output_Table(2,15) = l_grain_cell;
output_Table(2:n_row,16) = F_cell(1,:);

output_Table(1,:) = {'t [s]', 'm_tot [kg/s]', 'm_o [kg/s]', 'm_f [kg/s]', 'G_o [kg/(s*m^2)]', 'r [mm/s]', 'D_p [mm]','A_p [mm^2]','A_b [mm^2]', 'OF []','cstar [m/s]','CF_perfect []','Isp_perfect [s]','T_chamber [K]','l_grain [mm]', 'F [N]'};

xlswrite('output_table.xlsx',output_Table);

filename_output = 'output_table.xlsx';

% Construct the full file path
fullPath = fullfile(saveDir, filename_output);

% Write the table to the Excel file
xlswrite(fullPath, output_Table);

%
%% Plot combustion 
% Plot 
figure('Name','Paraffin/NO2 Hybrid Rocket Motor: Properties with time');

% Plot 1: Thrust vs. Time
subplot(2,2,1)
plot(t,F,'.','LineWidth',1.5)
title('Thrust vs. Time')
ylim([0 F_des*1.2])
xlabel('Time [s]') 
ylabel('Thrust [N]') 

% Plot 2: OF vs. Time
subplot(2,2,2)
plot(t,OF,'r.','LineWidth',1.5)
title('OF vs. Time')
xlabel('Time [s]') 
ylabel('OF') 
ylim([0 9])

% Plot 3: Fuel Mass Flow vs. Time
subplot(2,2,3)
plot(t,m_f,'b.','LineWidth',1.5)
title('Fuel Mass Flow vs. Time')
ylim([0 m_f(1)*1.2])
xlabel('Time [s]') 
ylabel('m_{fuel} [kg/s]')

% Plot 4: Regression Rate vs. Time
subplot(2,2,4)
plot(t,r,'b.','LineWidth',1.5)
title('Regression Rate vs. Time')
xlabel('Time [s]') 
ylabel('r [mm/s]')
