function [cstar, CF_actual, Isp_actual, T_chamber] = CEA_Database(fuel, oxid, OF, pChamber, AR, tFuel, tOxid, Pamb)
%%
%+
% Purpose: This function writes a matlab input file for the particular case you're
% interested in (Paraffin and any oxidizer). Then runs CEA.  Original code by Cyrus Foster,
% updated and adapted for a mac by Ashley Chandler 21 Oct 09.  Requires a
% file called matfile.out to write to.  Added ambient pressure effects on
% CF and Isp (21 Nov 2013).
%
% Inputs:   fuel: fuel name
%           oxid: oxidizer name
%           OF: oxidizer to fuel ratio
%           pChamber: chamber pressure, bar
%           AR: area ratio
%           tFuel: temperature of the fuel, K
%           tOxid: temperature of the oxidizer, K
%           Pamb: ambient pressure, bar
%
% Outputs:  rocket_perf.cstar = cstar; %cstar, m/s
%           rocket_perf.gamma_t = gamma_t; %gamma at the throat
%           rocket_perf.gamma_e = gamma_e; %gamma at the exit
%           rocket_perf.T_chamber = T_chamber; % chamber temperature, K
%           rocket_perf.T_throat = T_throat; %temperature at the throat, K
%           rocket_perf.T_exit = T_exit; % exit temp, K
%           rocket_perf.P_chamber = P_chamber*10^5; % chamber pressure, Pa
%           rocket_perf.P_throat = P_throat*10^5; %pressure at the throat, Pa
%           rocket_perf.P_exit = P_exit*10^5; % exit pressure, Pa
%           rocket_perf.rho_chamber = rho_chamber; % density in the chamber, kg/m^3
%           rocket_perf.rho_throat = rho_throat; %density at the throat, kg/m^3
%           rocket_perf.rho_exit = rho_exit; % exit density, kg/m^3
%           rocket_perf.M_w_chamber = M_w_chamber; % molecular weight
%           rocket_perf.M_w_throat = M_w_throat; % molecular weight
%           rocket_perf.M_w_exit = M_w_exit; % molecular weight
%           rocket_perf.M_e = M_e; %Exit Mach
%           %rocket_perf.u_e = u_e; %Exit velocity
%           rocket_perf.CF_perfect = CF_perfect; %CF for perfectly expanded flow
%           rocket_perf.CF_actual = CF_actual; %CF for actual ambient Pamb
%           rocket_perf.CFvac = CFvac; %CF for vacuum operation
%           rocket_perf.Isp_perfect = Isp_perfect; %Isp for perfectly expanded flow, s
%           rocket_perf.Isp_actual = Isp_actual; %Isp, s
%           rocket_perf.Ivac = Ivac; %Vacuum Isp, s
%
%
% Example: rocket_perf = CEA_Win('PAraffin', 'N2O', 2.4, 30, 70, 293, 293, 1)
%-

if length(OF) > 52
    error('Maximum length of O/F Array is 52')
elseif length(pChamber) > 26
    error('Maximum length of Chamber Pressure Array is 26')
end

%% Write input file for CEA

filepath = '\\STUDENTSERVER\Ordnerumleitung\Ali.Akbey\Desktop\CEA_deltaV';

fp = fopen([filepath 'matfile.inp'],'w');

fprintf(fp, 'problem   \r\n');
fprintf(fp, '    rocket  frozen\r\n');
% fprintf(fp, '    rocket  equilibrium\r\n');
% fprintf(fp, ['  p,bar=' strjoin(cellstr(num2str(pChamber)),',') ',\r\n']);

fprintf(fp, '  p,bar=');
for i = 1:10:length(pChamber)
    if i+10>length(pChamber)
        fprintf(fp,[strjoin(cellstr(num2str(pChamber(i:end))),',') ',\r\n']);
    else
       fprintf(fp,[strjoin(cellstr(num2str(pChamber(i:i+9))),',') ',\r\n']);
    end
end

fprintf(fp, ['  sup,ae/at=' strjoin(cellstr(num2str(AR)),',') ',\r\n']);
% fprintf(fp, ['  o/f=' strjoin(cellstr(num2str(OF)),',') ',\r\n']);
fprintf(fp, '  o/f=');
for i = 1:10:length(OF)
    if i+10>length(OF)
        fprintf(fp,[strjoin(cellstr(num2str(OF(i:end))),',') ',\r\n']);
    else
       fprintf(fp,[strjoin(cellstr(num2str(OF(i:i+9))),',') ',\r\n']);
    end
end
fprintf(fp, 'react  \r\n');
fprintf(fp, ['  oxid=' oxid ' wt=' num2str(1) '  t,k=' num2str(tOxid) '  \r\n']);
if strcmp(oxid,'N2O(L)')
    fprintf(fp, '    h,kJ/mol=65.1 N 2 O 1  \r\n');
end
fprintf(fp, ['  fuel=' fuel ' wt=' num2str(1) '  t,k=' num2str(tFuel) '  \r\n']);
if strcmp(fuel,'Paraffin')
%     fprintf(fp, '    h,kcal/mol=-224.193  C 32 H 66  \r\n');
    fprintf(fp, '    h,kJ/mol=-933 C 32 H 66  \r\n');
elseif strcmp(fuel,'ABS')
%     fprintf(fp, ['    h,kJ/mol= 62.6  C 15 H 17 N 1  \r\n']);
    fprintf(fp, '    h,kJ/mol= 62.6  C 3.85 H 4.85 N 0.43  \r\n');
elseif strcmp(fuel,'Nylon')
    fprintf(fp, '    h,cal/g= 143  C 6 H 11 N 1 O 1  \r\n');
elseif strcmp(fuel, 'PA66')
    fprintf(fp, '    h,kJ/g=965.58 C 12 H 22 O 2 N 2  \r\n');
end

fprintf(fp, 'output massf\r\n');
% fprintf(fp, 'output\r\n');
fprintf(fp, 'short\r\n');
fprintf(fp, 'end\r\n');
fclose(fp);

g_0 = 9.81;
%% Execute CEA
[~, ~] = system(['cd ' filepath ' & echo matfile | FCEA2.exe']);

%% Read output file from CEA
out = textread(fullfile(filepath, 'matfile.out'), '%s');

%% Pressure
idx_P = find(contains(lower(out), 'p,'));
if ~isempty(idx_P)
    P_chamber = str2double(out(idx_P+2)); %chamber pressure, bar
    P_throat = str2double(out(idx_P+3)); %throat pressure, bar
    P_exit = str2double(out(idx_P+4)); %exit pressure, bar
else
    idx_err = find(ismember(out, 'end'));
    strOut = string(out);
    error(strjoin(strOut(idx_err+1:end),' '));
    P_chamber = NaN;
    P_throat = NaN;
    P_exit = NaN;
end

%% Temperature
idx_T = find(ismember(out, 'T,'));
if ~isempty(idx_T)
    T_chamber = str2double(out(idx_T+2)); %chamber temp, K
    T_throat = str2double(out(idx_T+3)); %throat temp, K
    T_exit = str2double(out(idx_T+4)); %exit temp, K
else
    T_chamber = NaN;
    T_throat = NaN;
    T_exit = NaN;
end

%% Density
idx_rho = find(ismember(out, 'RHO,'));
if ~isempty(idx_rho)
    rho_chamber = (out(idx_rho+3)); %chamber density, kg/m^3
    rho_throat = (out(idx_rho+5)); %throat density, kg/m^3
    rho_exit = (out(idx_rho+6)); %exit density, kg/m^3
    
else
    rho_chamber = NaN;
    rho_throat = NaN;
    rho_exit = NaN;
end

%% Molecular Weight
idx_M_w = find(ismember(out, 'MW,'));
if ~isempty(idx_M_w)
    M_w_chamber = str2double(out(idx_M_w+3)); %molecular weight in the chamber
    M_w_throat = str2double(out(idx_M_w+4)); %molecular weight at the throat
    M_w_exit = str2double(out(idx_M_w+5)); %molecular weight at the exit
else
    M_w_chamber = NaN;
    M_w_throat = NaN;
    M_w_exit = NaN;
end


%% C*
idx_cstar = find(ismember(out, 'CSTAR,')==1);
if ~isempty(idx_cstar)
    cstar = str2double(out(idx_cstar+3));
else
    cstar = NaN;
end

%% CF_perfect
idx_CF_perfect = find(ismember(out, 'CF')==1);
if ~isempty(idx_CF_perfect)
    CF_perfect = str2double(out(idx_CF_perfect+2));
else
    CF_perfect = NaN;
end
%% CF
CF_actual = zeros(length(P_exit),1);
CFvac = zeros(length(P_exit),1);
for i = 1:length(P_exit)
    Pmotor_temp = pChamber(rem(i,length(pChamber))+1);
    CF_actual(i,1) = CF_perfect(i) + (P_exit(i)./Pmotor_temp - Pamb./Pmotor_temp).*AR;
    CFvac(i,1) = CF_perfect(i) + (P_exit(i)./Pmotor_temp - 0./Pmotor_temp).*AR;
end

%% Isp
idx_Ivac = find(ismember(out, 'Ivac,')==1);
if ~isempty(idx_Ivac)
    u_e = str2double(out(idx_Ivac+3)); %exit velocity
    Ivac = u_e/g_0; %Actually the exit velocity, called Isp in CEA
else
    Ivac = NaN;
end

idx_Isp_perfect = find(ismember(out, 'Isp,')==1);
if ~isempty(idx_Isp_perfect)
    u_e = str2double(out(idx_Isp_perfect+3)); % exit velocity
    Isp_perfect = u_e/g_0; %Actually the exit velocity divided by g_0
else
    Isp_perfect = NaN;
end

if ~isempty(idx_Isp_perfect)
    Isp_actual = Isp_perfect.*CF_actual./CF_perfect; %Actually the exit velocity divided by g_0
else
    Isp_actual = NaN;
end

%% Gamma
idx_gamma = find(ismember(out, 'GAMMAs'));
if ~isempty(idx_gamma)
    gamma_t = str2double(out(idx_gamma+2)); %gamma at the throat
    gamma_e = str2double(out(idx_gamma+3)); %gamma at the exit
else
    gamma_t = NaN;
    gamma_e = NaN;
end

%% Mach
idx_mach = find(ismember(out, 'MACH'));
if ~isempty(idx_mach)
    M_e = str2double(out(idx_mach+4));% exit mach
else
    M_e = NaN;
end


% % Nicely package output data
% 
% rocket_perf.cstar = cstar; %cstar
% rocket_perf.gamma_t = gamma_t; %gamma at the throat
% rocket_perf.gamma_e = gamma_e; %gamma at the exit
% rocket_perf.T_chamber = T_chamber; % chamber temperature, K
% rocket_perf.T_throat = T_throat; %temperature at the throat, K
% rocket_perf.T_exit = T_exit; % exit temp, K
% rocket_perf.P_chamber = P_chamber*10^5; % chamber pressure, Pa
% rocket_perf.P_throat = P_throat*10^5; %pressure at the throat, Pa
% rocket_perf.P_exit = P_exit*10^5; % exit pressure, Pa
% rocket_perf.rho_chamber = rho_chamber; % density in the chamber, kg/m^3
% rocket_perf.rho_throat = rho_throat; %density at the throat, kg/m^3
% rocket_perf.rho_exit = rho_exit; % exit density, kg/m^3
% rocket_perf.M_w_chamber = M_w_chamber; % molecular weight
% rocket_perf.M_w_throat = M_w_throat; % molecular weight
% rocket_perf.M_w_exit = M_w_exit; % molecular weight
% rocket_perf.M_e = M_e; %Exit Mach
% %rocket_perf.u_e = u_e; %Exit velocity
% rocket_perf.CF_perfect = CF_perfect; %CF for perfectly expanded flow
% rocket_perf.CF_actual = CF_actual; %CF for actual Pamb
% rocket_perf.CFvac = CFvac; %CF for vacuumm operation
% rocket_perf.Isp_perfect = Isp_perfect; %Isp for perfectly expanded flow, s
% rocket_perf.Isp_actual = Isp_actual; %Isp for actual Pamb, s
% rocket_perf.Ivac = Ivac; %Vacuum Isp, s

return


