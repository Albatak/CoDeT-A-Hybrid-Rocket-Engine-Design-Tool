n_row=length(t)+1;
output_Table = cell(n_row,13);

t_cell=num2cell(t);
m_tot_cell=num2cell(m_tot);
m_o_cell=num2cell(m_o);
m_f_cell=num2cell(m_f);
G_o_cell=num2cell(G_o);
r_cell=num2cell(r);
D_p_cell=num2cell(D_p);
OF_cell=num2cell(OF);
cstar_cell=num2cell(cstar);
CF_perfect_cell=num2cell(CF_perfect);
Isp_perfect_cell=num2cell(Isp_perfect);
T_chamber_cell=num2cell(T_chamber);
l_grain_cell=num2cell(l_grain);

output_Table(2:n_row,1) = t_cell(1,:);
output_Table(2:n_row,2) = m_tot_cell(1,:);
output_Table(2:n_row,3) = m_o_cell(1,:);
output_Table(2:n_row,4) = m_f_cell(1,:);
output_Table(2:n_row,5) = G_o_cell(1,:);
output_Table(2:n_row,6) = r_cell(1,:);
output_Table(2:n_row,7) = D_p_cell(1,:);
output_Table(2:n_row,8) = OF_cell(1,:);
output_Table(2:n_row,9) = cstar_cell(1,:);
output_Table(2:n_row,10) = CF_perfect_cell(1,:);
output_Table(2:n_row,11) = Isp_perfect_cell(1,:);
output_Table(2:n_row,12) = T_chamber_cell(1,:);
output_Table(2,13) = l_grain_cell;

output_Table(1,:) = {'t [s]', 'm_tot [kg/s]', 'm_o [kg/s]', 'm_f [kg/s]', 'G_o [kg/(s*m^2)]', 'r [mm/s]', 'D_p [mm]','OF []','cstar [m/s]','CF_perfect []','Isp_perfect [s]','T_chamber [K]','l_grain [mm]'};

xlswrite('Comb_data_GOX.xlsx',output_Table);