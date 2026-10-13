function rocket_perf = CEA_Win_HDPE_AR(add, oxid, oxid2, relweightoxid, OF, addratio, psia, AR, tpara, tadd, toxid, Pamb)


%%
%+
% Purpose: This function writes a matlab input file for the particular case you're
% interested in (Paraffin and any oxidizer). Then runs CEA.  Original code by Cyrus Foster,
% updated and adapted for a mac by Ashley Chandler 21 Oct 09.  Requires a
% file called matfile.out to write to.  Added ambient pressure effects on
% CF and Isp (21 Nov 2013).
%
% Inputs:   add: fuel additive, generally aluminum
%           oxid: name of the oxidizer in quotes
%           oxid2: name of the oxidizer in quotes
%           relweightoxid: percent oxid in mixture in decimal form
%           OF: oxidizer to fuel ratio
%           addratio: percent of additive in decimal form
%           psia: chamber pressure, bar
%           AR: area ratio
%           tpara: temperature of the paraffin, K
%           toxid: temperature of the oxidizer, K
%           tadd: temperature of additive, K
%           Pamb: ambient pressure, psi
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
% Example: rocket_perf = CEA_Win('AL(cr)', 'N2O', 'O2', .9, 2.4, .10, 1000, 20, 293, 293, 293, 14.7)
%-

% Write input file for CEA
%addpath('CEA')
location = which('CEA_Win');
endpath = strfind(location,'CEA_Win.m');
filepath = location(1:endpath-1);

fid = fopen([filepath 'target.txt'], 'wt' );
fprintf( fid, 'matfile\n');
fclose(fid);

% fp = fopen('matfile.inp','w');
fp = fopen([filepath 'matfile.inp'],'w');

fprintf(fp, 'problem   \r\n');
fprintf(fp, ' rocket frozen\r\n');
fprintf(fp, ['  p,bar=' num2str(psia) ',\r\n']);
fprintf(fp, ['  sup,ae/at=' num2str(AR) ',\r\n']);
% fprintf(fp, ['  pi/p=' num2str(PR) ',\r\n']);
fprintf(fp, ['react  \r\n']);
fprintf(fp, ['  oxid=' oxid ' wt=' num2str(OF*relweightoxid) '  t,k=' num2str(toxid) '  \r\n']);
if strcmp(oxid,'N2O(L)')
    fprintf(fp, ['    h,kJ/mol=65.1 N 2 O 1  \r\n']);
end
fprintf(fp, ['  oxid=' oxid2 ' wt=' num2str(OF*(1-relweightoxid)) '  t,k=' num2str(toxid) '  \r\n']);
if strcmp(oxid2,'N2O(L)')
    fprintf(fp, ['    h,kJ/mol=65.1 N 2 O 1  \r\n']);
end
if strcmp(oxid2,'CO2(L)')
    fprintf(fp, ['    h,kJ/mol=-410.5 C 1 O 2  \r\n']);
end
fprintf(fp, ['  fuel=' add ' wt=' num2str(addratio) '  t,k=' num2str(tadd) '  \r\n']);
if strcmp(add,'BH3NH3')
    fprintf(fp, ['    h,kJ/mol=-83.0 B 1 H 6 N 1  \r\n']);
end
if strcmp(add,'LiALH4')
    fprintf(fp, ['    h,kJ/mol=-112.5 Li 1 AL 1 H 4  \r\n']);
end
if strcmp(add,'ALB12')
    fprintf(fp, ['    h,kJ/mol=-148.2 AL 1 B 12  \r\n']);
end
if strcmp(add,'MgB2')
    fprintf(fp, ['    h,kJ/mol=-245.11 Mg 1 B 2  \r\n']);
end
% fprintf(fp, ['  fuel=Paraffin  wt=' num2str(1-addratio) '  t,k=' num2str(tpara) '  \r\n']);
% %fprintf(fp, ['    h,kcal/mol=-224.193  C 32 H 66  \r\n']);
% fprintf(fp, ['    h,kJ/mol=-933 C 32 H 66  \r\n']);
% %fprintf(fp, ['    h,kJ/mol=-697 C 32 H 66  \r\n']);

fprintf(fp, ['  fuel=HDPE  wt=' num2str(1-addratio) '  t,k=' num2str(tpara) '  \r\n']);
% fprintf(fp, ['    h,kJ/mol=-420.21 C 12 H 22 N 2 O 2  \r\n']);
fprintf(fp, ['    h,kJ/g=965.58 C 12 H 22 O 2 N 2  \r\n']);

fprintf(fp, ['output massf\r\n']);
fprintf(fp, ['end\r\n']);
fclose(fp);

g_0 = 9.81;
% Execute CEA
% system('FCEA2.exe < target.txt');
[status, cmdout] = system(['CD ' filepath ' & FCEA2.exe < target.txt']);

% pause(.0001);

% Read output file from CEA
A = textread([filepath 'matfile.out'], '%s');

%Pressure
idx_P = find(ismember(A, 'P,'));
if ~isempty(idx_P)
    P_chamber = str2double(A(idx_P+2)); %chamber pressure, bar
    P_throat = str2double(A(idx_P+3)); %throat pressure, bar
    P_exit = str2double(A(idx_P+4)); %exit pressure, bar
else
    P_chamber = NaN;
    P_throat = NaN;
    P_exit = NaN;
end

%Temperature
idx_T = find(ismember(A, 'T,'));
if ~isempty(idx_T)
    T_chamber = str2double(A(idx_T+2)); %chamber temp, K
    T_throat = str2double(A(idx_T+3)); %throat temp, K
    T_exit = str2double(A(idx_T+4)); %exit temp, K
else
    T_chamber = NaN;
    T_throat = NaN;
    T_exit = NaN;
end

%Density
idx_rho = find(ismember(A, 'RHO,'));
if ~isempty(idx_rho)
    rho_chamber = (A(idx_rho+3)); %chamber density, kg/m^3
    rho_throat = (A(idx_rho+5)); %throat density, kg/m^3
    rho_exit = (A(idx_rho+6)); %exit density, kg/m^3
    
else
    rho_chamber = NaN;
    rho_throat = NaN;
    rho_exit = NaN;
end

%Molecular Weight
idx_M_w = find(ismember(A, 'MW,'));
if ~isempty(idx_M_w)
    M_w_chamber = str2double(A(idx_M_w+3)); %molecular weight in the chamber
    M_w_throat = str2double(A(idx_M_w+4)); %molecular weight at the throat
    M_w_exit = str2double(A(idx_M_w+5)); %molecular weight at the exit
else
    M_w_chamber = NaN;
    M_w_throat = NaN;
    M_w_exit = NaN;
end


%C*
idx_cstar = find(ismember(A, 'CSTAR,')==1);
if ~isempty(idx_cstar)
    cstar = str2double(A{idx_cstar+3});
else
    cstar = NaN;
end

%CF_perfect
idx_CF_perfect = find(ismember(A, 'CF')==1);
if ~isempty(idx_CF_perfect)
    CF_perfect = str2double(A{idx_CF_perfect+2});
else
    CF_perfect = NaN;
end

% %CF
% 
% CF_actual = CF_perfect + (P_exit/psia - Pamb/psia)*AR;
% 
% % CFvac
% 
% CFvac = CF_perfect + (P_exit/psia - 0/psia)*AR;

%Isp

idx_Ivac = find(ismember(A, 'Ivac,')==1);
if ~isempty(idx_Ivac)
    u_e = str2double(A{idx_Ivac+3}); %exit velocity
    Ivac = str2double(A{idx_Ivac+3})/g_0; %Actually the exit velocity, called Isp in CEA
else
    Ivac = NaN;
end

idx_Isp_perfect = find(ismember(A, 'Isp,')==1);
if ~isempty(idx_Isp_perfect)
    u_e = str2double(A{idx_Isp_perfect+3}); % exit velocity
    Isp_perfect = str2double(A{idx_Isp_perfect+3})/g_0; %Actually the exit velocity divided by g_0
else
    Isp_perfect = NaN;
end

% idx_Isp = find(ismember(A, 'Isp,')==1);
% if ~isempty(idx_Isp)
%     u_e = str2double(A{idx_Isp+3}); % exit velocity
%     Isp_actual = str2double(A{idx_Isp+3})/g_0*CF_actual/CF_perfect; %Actually the exit velocity divided by g_0
% else
%     Isp_actual = NaN;
% end

%gamma
idx_gamma = find(ismember(A, 'GAMMAs'));
if ~isempty(idx_gamma)
    gamma_t = str2double(A(idx_gamma+2)); %gamma at the throat
    gamma_e = str2double(A(idx_gamma+3)); %gamma at the exit
else
    gamma_t = NaN;
    gamma_e = NaN;
end

%mach
idx_mach = find(ismember(A, 'MACH'));
if ~isempty(idx_mach)
    M_e = str2double(A(idx_mach+4));% exit mach
else
    M_e = NaN;
end

idx_son_vel = find(ismember(A, 'VEL,M/SEC'));
if ~isempty(idx_son_vel)
    son_vel = str2double(A(idx_son_vel+2));% exit mach
else
    son_vel = NaN;
end

idx_cp_exit = find(ismember(A, 'Cp,'));
if ~isempty(idx_cp_exit)
    cp_exit = str2double(A(idx_cp_exit+4));% exit mach
else
    cp_exit = NaN;
end

if ~isnan(P_chamber)
    
    %CO(gr)
    idx_CO = find(ismember(A, '*CO'));
    if ~isempty(idx_CO)
        mass_CO = str2double(A(idx_CO(end)+1));
    else
        mass_CO = NaN;
    end
    if isnan(mass_CO)
        mass_CO = 0;
    end
    
    %CO2(gr)
    idx_CO2 = find(ismember(A, '*CO2'));
    if ~isempty(idx_CO2)
        mass_CO2 = str2double(A(idx_CO2(end)+1)); %gamma at the chamber
    else
        mass_CO2 = NaN;
    end
    if isnan(mass_CO2)
        mass_CO2 = 0;
    end
    
    %H2O
    idx_H2O = find(ismember(A, 'H2O'));
    if ~isempty(idx_H2O)
        mass_H2O = str2double(A(idx_H2O(end)+1)); %gamma at the chamber
    else
        mass_H2O = NaN;
    end
    if isnan(mass_H2O)
        mass_H2O = 0;
    end
    
    
        %O2
    idx_O2 = find(ismember(A, '*O2'));
    if ~isempty(idx_O2)
        mass_O2 = str2double(A(idx_O2(end)+1)); %gamma at the chamber
    else
        mass_O2 = NaN;
    end
    if isnan(mass_O2)
        mass_O2 = 0;
    end
    
    
            %N2
    idx_N2 = find(ismember(A, '*N2'));
    if ~isempty(idx_N2)
        mass_N2 = str2double(A(idx_N2(end)+1)); %gamma at the chamber
    else
        mass_N2 = NaN;
    end
    if isnan(mass_N2)
        mass_N2 = 0;
    end
    
    
    
            %OH
    idx_OH = find(ismember(A, '*OH'));
    if ~isempty(idx_OH)
        mass_OH = str2double(A(idx_OH(end)+1)); %gamma at the chamber
    else
        mass_OH = NaN;
    end
    if isnan(mass_OH)
        mass_OH = 0;
    end

            %Ae/At
    idx_AeAt = find(ismember(A, 'Ae/At'));
    if ~isempty(idx_AeAt)
        AeAt = str2double(A(idx_AeAt(end)+2)); %gamma at the chamber
    else
        AeAt = NaN;
    end
    if isnan(AeAt)
        AeAt = 0;
    end
end

%% Nicely package output data

rocket_perf.cstar = cstar; %cstar
rocket_perf.gamma_t = gamma_t; %gamma at the throat
rocket_perf.gamma_e = gamma_e; %gamma at the exit
rocket_perf.T_chamber = T_chamber; % chamber temperature, K
rocket_perf.T_throat = T_throat; %temperature at the throat, K
rocket_perf.T_exit = T_exit; % exit temp, K
rocket_perf.P_chamber = P_chamber*10^5; % chamber pressure, Pa
rocket_perf.P_throat = P_throat*10^5; %pressure at the throat, Pa
rocket_perf.P_exit = P_exit*10^5; % exit pressure, Pa
rocket_perf.rho_chamber = rho_chamber; % density in the chamber, kg/m^3
rocket_perf.rho_throat = rho_throat; %density at the throat, kg/m^3
rocket_perf.rho_exit = rho_exit; % exit density, kg/m^3
rocket_perf.M_w_chamber = M_w_chamber; % molecular weight
rocket_perf.M_w_throat = M_w_throat; % molecular weight
rocket_perf.M_w_exit = M_w_exit; % molecular weight
rocket_perf.M_e = M_e; %Exit Mach
%rocket_perf.u_e = u_e; %Exit velocity
% rocket_perf.CF_perfect = CF_perfect; %CF for perfectly expanded flow
% rocket_perf.CF_actual = CF_actual; %CF for actual Pamb
% rocket_perf.CFvac = CFvac; %CF for vacuumm operation
% rocket_perf.Isp_perfect = Isp_perfect; %Isp for perfectly expanded flow, s
% rocket_perf.Isp_actual = Isp_actual; %Isp for actual Pamb, s
% rocket_perf.Ivac = Ivac; %Vacuum Isp, s
rocket_perf.mass_CO = mass_CO; 
rocket_perf.mass_CO2 = mass_CO2;
rocket_perf.son_vel = son_vel;
rocket_perf.mass_H2O = mass_H2O;
rocket_perf.mass_O2 = mass_O2;
rocket_perf.mass_OH = mass_OH;
rocket_perf.cp_exit = cp_exit;
rocket_perf.mass_N2 = mass_N2;
rocket_perf.AeAt = AeAt;
return


