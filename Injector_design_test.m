clc
clear 
close all

% % Read input from Excel file
% filename = 'input_inj.xlsx';
% 
% % Read GOX parameters
% GOX_data = xlsread(filename, 'GOX');
% P_c_GOX = GOX_data(1); % bar
% m_o_min_GOX = GOX_data(2); % kg/s
% deltaP_GOX = GOX_data(3); % bar
% 
% % Read LOX parameters
% LOX_data = xlsread(filename, 'LOX');
% P_c_LOX = LOX_data(1); % bar
% m_o_min_LOX = LOX_data(2); % kg/s
% deltaP_LOX = LOX_data(3); % bar
% 
% % Read N2O parameters
% N2O_data = xlsread(filename, 'N2O');
% P_c_N2O = N2O_data(1); % bar
% m_o_min_N2O = N2O_data(2); % kg/s
% deltaP_N2O = N2O_data(3); % bar
% 
% % Rest of the code remains the same


%%
c_d_end = 1;
c_d_st = 0.2;
d_c_d = 0.01;
c_d = c_d_st:d_c_d:c_d_end;

n_inj_hole = 5;

% Input parameters
%% GOX AR=5: 
P_c_GOX = 30; % bar
m_o_min_GOX = 0.27643454; % kg/s
deltaP_GOX = 20; % ? bar pressure difference of inlet and outlet of the injector holes
P_manifold_GOX = P_c_GOX + deltaP_GOX; % [bar]

gamma_GOX = 1.303; % ?

% c_d = 0.84; % Wert Max

%% LOX AR=5: 
P_c_LOX = 35; % bar
m_o_min_LOX = 0.27915; % kg/s
deltaP_LOX = 15; % ? bar pressure difference of inlet and outlet of the injector holes
P_manifold_LOX = P_c_LOX + deltaP_LOX; % [bar]

% c_d = 0.; % ?


%% N2O AR=5: 
P_c_N2O = 31; % bar
m_o_min_N2O = 0.39481; % kg/s
deltaP_N2O = 8; % bar pressure difference of inlet and outlet of the injector holes
P_manifold_N2O = P_c_N2O + deltaP_N2O; % [bar]

%c_d = 0.8; % EUCASS2017 


%Injector Design: 1)Single Phase:Liquid, 2)Single Phase: Gas, 3)Homogenous Equilibrium
%% Single Phase:Liquid LOX injector
rho_o_LOX = py.CoolProp.CoolProp.PropsSI('D','P',P_c_LOX*1e5,'Q',0,'N2O');
% A_inj_tot_LOX = m_o_min_LOX/(c_d(1,:)*(2*rho_o_LOX*deltaP_LOX*1e5)^0.5); % C_d*A equation for A_2<<A_1
A_inj_tot_LOX = m_o_min_LOX ./ (c_d(1,:) .* (2 * rho_o_LOX * deltaP_LOX * 1e5).^0.5);

A_inj_i_LOX = A_inj_tot_LOX/n_inj_hole;
% D_inj_LOX = ((4/pi)*A_inj_i_LOX)^0.5;
D_inj_LOX = sqrt((4/pi)*A_inj_i_LOX)*1000; % mm
disp("injector hole diameter for LOX should be: " + D_inj_LOX*1000 + "mm")


%% 2)Single Phase: Gas GOX
% elseif text_injector_design == 2
    % Injector Design: single phase(gas), ideal gas, compressible, isentropic
%     deltaP = 15; % [bar] pressure difference of inlet and outlet of the injector holes
%     P_manifold = P_c + deltaP;

crit_p_fraction = (2/(gamma_GOX+1))^(gamma_GOX/(gamma_GOX-1)); % p_2 / p_1crit, p_c / p_man_crit
p_fraction = P_c_GOX/P_manifold_GOX;
% check if the flow is choked
if p_fraction < crit_p_fraction % choked flow
    % upstream conditions: Assumption: at the entrance the gas is saturated (gesättigt)
    rho_1 = py.CoolProp.CoolProp.PropsSI('D','P',P_manifold_GOX*1e5,'Q',1,'O2');
    exponent = (gamma_GOX+1)/(gamma_GOX-1);
    in_sqrt = gamma_GOX*rho_1*P_manifold_GOX*1e5*(2/(gamma_GOX+1))^exponent;
    A_inj_SPG_tot = m_o_min_GOX ./(c_d .* sqrt(in_sqrt));
%     D_inj_tot = 4/pi*sqrt(A_inj_SPG_tot);

    A_inj_i_GOX = A_inj_SPG_tot/n_inj_hole;
    D_inj_GOX_choked = sqrt(((4/pi)*A_inj_i_GOX))*1000;
    disp("injector hole diameter should be: " + D_inj_GOX_choked + "mm")

else % flow is unchoked. Use the general formula
    paranth = ((P_c_GOX/P_manifold_GOX)^(2/gamma_GOX)-(P_c_GOX/P_manifold_GOX)^(gamma_GOX+1)/(gamma_GOX));
    T_manifold = py.CoolProp.CoolProp.PropsSI('T','P',P_manifold_GOX*1e5,'Q',1,'N2O');
    rho_manifold = py.CoolProp.CoolProp.PropsSI('D','P',P_manifold_GOX*1e5,'Q',1,'N2O');
    c_p = py.CoolProp.CoolProp.PropsSI('C','P',P_manifold_GOX,'T',T_manifold,'N2O');        
    root = sqrt(2*c_p*T_manifold*paranth);
    A_inj_tot_SPG_unchoked = m_o_min_GOX ./ (c_d .* rho_manifold * root);       
    D_inj_tot_SPG_unchoked = 4/pi*sqrt(A_inj_tot_SPG_unchoked);

    A_inj_i = A_inj_tot_SPG_unchoked/n_inj_hole;
    D_inj_GOX_unchoked = sqrt(((4/pi)*A_inj_i))*1000;
    disp("injector hole diameter should be: " + D_inj_GOX_unchoked + "mm")

end

%% Homogenous Equilibrium: N2O
% Injector Design: Homogenous Equilibrium Model two phase isentropic

% Input variable: Manifold temperature
% T_manifold = 280; % [K]

% Assumption: x=0 at entry no T_manifold needed
S_1 = py.CoolProp.CoolProp.PropsSI('S','P',P_manifold_N2O*1e5,'Q',0,'N2O');
h_1 = py.CoolProp.CoolProp.PropsSI('H','P',P_manifold_N2O*1e5,'S',S_1,'N2O');
% Isentropic flow
S_2 = S_1;
rho_2 = py.CoolProp.CoolProp.PropsSI('D','P',P_c_N2O*1e5,'S',S_1,'N2O'); % [kg/m^3]
h_2 = py.CoolProp.CoolProp.PropsSI('H','P',P_c_N2O*1e5,'D',rho_2,'N2O'); % from chamber pressure
A_inj_tot_HEM = m_o_min_N2O ./(c_d .* rho_2*sqrt(2*(h_1-h_2))); % [m^2]

    % ask the user if they want to specify injector hole diameter or the number of injector holes
%     prompt1 = "Injector design with the number of injector holes(1) or injector hole diameter(2)? ";
%     text1 = input(prompt1,"s");

A_inj_i_HEM = A_inj_tot_HEM/n_inj_hole;
D_inj_N2O = sqrt(((4/pi)*A_inj_i_HEM))*1000;
disp("injector hole diameter should be: " + D_inj_N2O + "mm")

%% Plot
% Plotting c_d vs. D_inj for different propellants
plot(c_d, D_inj_LOX, 'r', 'DisplayName', 'LOX');
hold on;
if p_fraction < crit_p_fraction
    plot(c_d, D_inj_GOX_choked, 'g', 'DisplayName', 'GOX choked');
else
    plot(c_d, D_inj_GOX_unchoked, 'g', 'DisplayName', 'GOX Unchoked');
end
plot(c_d, D_inj_N2O, 'b', 'DisplayName', 'N2O');
hold off;

% Add labels and title
xlabel('Coefficient of Discharge (c_d)');
ylabel('Injector Hole Diameter (mm)');
title('Injector Hole Diameter vs. Coefficient of Discharge');
legend('Location', 'best');

savefig('injector_plot.fig');
