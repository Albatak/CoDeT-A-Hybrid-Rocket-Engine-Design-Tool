clc
clear 
close all
%%
c_d_end = 1;
c_d_st = 0.2;
c_d = c_d_st:dt:c_d_end;

% Input parameters
%% GOX AR=5: 
P_c = 30; % bar
m_o_min = 0.27643454; % kg/s
deltaP = ; % bar pressure difference of inlet and outlet of the injector holes
P_manifold = P_c + deltaP; % [bar]
text_injector_design = 2;
text1 = "2";

% c_d = 0.84; % Wert Max

%% LOX AR=5: 
P_c = 35; % bar
m_o_min = 0.27915; % kg/s
deltaP = ; % bar pressure difference of inlet and outlet of the injector holes
P_manifold = P_c + deltaP; % [bar]
text_injector_design = 1;
text1 = "2";

% c_d = 0.; % ?
gamma = 1.303; % ?

%% N2O AR=5: 
P_c = 31; % bar
m_o_min = 0.39481; % kg/s
deltaP = 8; % bar pressure difference of inlet and outlet of the injector holes
P_manifold = P_c + deltaP; % [bar]
text_injector_design = 3;
text1 = "2";

% c_d = 0.8; % EUCASS2017 


%% Injector Design: 1)Single Phase:Liquid, 2)Single Phase: Gas, 3)Homogenous Equilibrium
% prompt_injector_design = "Please choose the model for the injector design: (1)single phase:liquid, (2)single phase:gas, (3)HEM : ";
% text_injector_design = input(prompt_injector_design);

if text_injector_design == 1
    % Injector Design: single phase(liquid), incompressible, isentropic
    prompt1 = "Injector design with the number of injector holes(1) or injector hole diameter(2)? ";
    text1 = input(prompt1,"s");

    % Liquid oxidizer density at chamber pressure
    rho_o = py.CoolProp.CoolProp.PropsSI('D','P',P_c*1e5,'Q',0,'N2O');
    A_inj_tot = m_o_min/(c_d*(2*rho_o*deltaP*1e5)^0.5); % C_d*A equation for A_2<<A_1

    % ask the user if they want to specify injector hole diameter or the number of injector holes
    if text1 == "1"
        prompt2 = "Please enter the number of injector holes: ";
        text2 = input(prompt2);
        n_inj_hole = text2;
        A_inj_i = A_inj_tot/n_inj_hole;
        D_inj = ((4/pi)*A_inj_i)^0.5;
        disp("injector hole diameter should be: " + D_inj*1000 + "mm")
    elseif text1 == "2"
        prompt3 = "Please enter the injector hole diameter in millimeters: ";
        text3 = input(prompt3);
        D_inj = text3*1e-3;
        A_inj_i = pi/4*D_inj^2;
        n_inj_hole = A_inj_tot/A_inj_i;
        disp("number of injector holes should be: " + n_inj_hole)
    else ;disp("Wrong entry")
    end

elseif text_injector_design == 2
    % Injector Design: single phase(gas), ideal gas, compressible, isentropic
%     deltaP = 15; % [bar] pressure difference of inlet and outlet of the injector holes
%     P_manifold = P_c + deltaP;

    crit_p_fraction = (2/(gamma+1))^(gamma/(gamma-1)); % p_2 / p_1crit, p_c / p_man_crit
    p_fraction = P_c/P_manifold;
    % check if the flow is choked
    if p_fraction < crit_p_fraction % choked flow
        % upstream conditions: Assumption: at the entrance the gas is saturated (gesättigt)
        rho_1 = py.CoolProp.CoolProp.PropsSI('D','P',P_manifold*1e5,'Q',1,'O2');
        exponent = (gamma+1)/(gamma-1);
        in_sqrt = gamma*rho_1*P_manifold*1e5*(2/(gamma+1))^exponent;
        A_inj_SPG_tot = m_o_min/(c_d*sqrt(in_sqrt));
        D_inj_SPG_tot = 4/pi*sqrt(A_inj_SPG_tot);

        prompt1 = "Injector design with the number of injector holes(1) or injector hole diameter(2)? ";
        text1 = input(prompt1,"s");

        % ask the user if they want to specify injector hole diameter or the number of injector holes
        if text1 == "1"
            prompt2 = "Please enter the number of injector holes: ";
            text2 = input(prompt2);
            n_inj_hole = text2;
            A_inj_i = A_inj_SPG_tot/n_inj_hole;
            D_inj = ((4/pi)*A_inj_i)^0.5;
            disp("injector hole diameter should be: " + D_inj*1000 + "mm")
        elseif text1 == "2"
            prompt3 = "Please enter the injector hole diameter in millimeters: ";
            text3 = input(prompt3);
            D_inj = text3*1e-3;
            A_inj_i = pi/4*D_inj^2;
            n_inj_hole = A_inj_SPG_tot/A_inj_i;
            disp("Number of injector holes should be: " + n_inj_hole)
        else ;disp("Wrong entry")
        end
    else % flow is not choked. Use the general formula
        paranth = ((P_c/P_manifold)^(2/gamma)-(P_c/P_manifold)^(gamma+1)/(gamma));
        T_manifold = py.CoolProp.CoolProp.PropsSI('T','P',P_manifold*1e5,'Q',1,'N2O');
        rho_manifold = py.CoolProp.CoolProp.PropsSI('D','P',P_manifold*1e5,'Q',1,'N2O');
        c_p = py.CoolProp.CoolProp.PropsSI('C','P',P_manifold,'T',T_manifold,'N2O');        
        root = sqrt(2*c_p*T_manifold*paranth);
        A_inj_tot_SPG_unchoked = m_o_min/(c_d*rho_manifold*root);       
        D_inj_tot_SPG_unchoked = 4/pi*sqrt(A_inj_tot_SPG_unchoked);

%         prompt1 = "Injector design with the number of injector holes(1) or injector hole diameter(2)? ";
%         text1 = input(prompt1,"s");

        % ask the user if they want to specify injector hole diameter or the number of injector holes
        if text1 == "1"
            prompt2 = "Please enter the number of injector holes: ";
            text2 = input(prompt2);
            n_inj_hole = text2;
            A_inj_i = A_inj_tot_SPG_unchoked/n_inj_hole;
            D_inj = ((4/pi)*A_inj_i)^0.5;
            disp("injector hole diameter should be: " + D_inj*1000 + "mm")
        elseif text1 == "2"
            prompt3 = "Please enter the injector hole diameter in millimeters: ";
            text3 = input(prompt3);
            D_inj = text3*1e-3;
            A_inj_i = pi/4*D_inj^2;
            n_inj_hole = A_inj_tot_SPG_unchoked/A_inj_i;
            disp("Number of injector holes should be: " + n_inj_hole)
        else ;disp("Wrong entry")
        end
    end

elseif text_injector_design == 3
    % Injector Design: Homogenous Equilibrium Model two phase isentropic
    % 1 = Manifold, 2 = Chamber
%     c_d = 0.65;
%     deltaP = 15; % [bar] pressure difference of inlet and outlet of the injector holes

    % Input variable: Manifold temperature
    %T_manifold = 280; % [K]

    % Assumption: x=0 at entry no T_manifold needed
    S_1 = py.CoolProp.CoolProp.PropsSI('S','P',P_manifold*1e5,'Q',0,'N2O');
    h_1 = py.CoolProp.CoolProp.PropsSI('H','P',P_manifold*1e5,'S',S_1,'N2O');
    % Isentropic flow
    S_2 = S_1;
    rho_2 = py.CoolProp.CoolProp.PropsSI('D','P',P_c*1e5,'S',S_1,'N2O'); % [kg/m^3]
    h_2 = py.CoolProp.CoolProp.PropsSI('H','P',P_c*1e5,'D',rho_2,'N2O'); % from chamber pressure
    A_inj_tot_HEM = m_o_min/(c_d*rho_2*sqrt(2*(h_1-h_2))); % [m^2]

    % ask the user if they want to specify injector hole diameter or the number of injector holes
%     prompt1 = "Injector design with the number of injector holes(1) or injector hole diameter(2)? ";
%     text1 = input(prompt1,"s");
    if text1 == "1"
        prompt2 = "Please enter the number of injector holes: ";
        text2 = input(prompt2);
        n_inj_hole = text2;
        A_inj_i_HEM = A_inj_tot_HEM/n_inj_hole;
        D_inj_HEM = ((4/pi)*A_inj_i_HEM)^0.5;
        disp("injector hole diameter should be: " + D_inj_HEM*1000 + "mm")
    elseif text1 == "2"
        prompt3 = "Please enter the injector hole diameter in millimeters: ";
        D_inj = input(prompt3);
%         text3 = D_inj; 
        D_inj_HEM = D_inj*1e-3; % Input of the user when calling the function
        A_inj_i_HEM = pi/4*D_inj_HEM^2;
        n_inj_hole = A_inj_tot_HEM/A_inj_i_HEM;
        disp("Number of injector holes should be: " + n_inj_hole)
    else ;disp("Wrong entry")
    end
end
