function [par_sys, par_sim, par_cell, par_dbp, par_ds] = ...
    panel_param_default()
    % System parameters
    par_sys.Ns = 12; % number of cells in series
    par_sys.Np = 1; % number of series in parallel
    par_sys.Ncpbd = 1; % number of cell in series per each bypass diode
    
    % Simulation parameters
    par_sim.Nsim = 101; % number of measurements for contructing the characteristic
    par_sim.Vmax = 0.8;
    par_sim.rand_seed = 68431;
    
    % Cell photocurrent parameters
    par_cell.lambda = 1; % normalized solar irradiation [sun]
    par_cell.Isc = 3.8; % short circuit current [A]
    par_cell.Kth = -0.01; % short circuit current temperature coefficient [A/K]
    par_cell.Tc0 = 25; % cell starting temperature [°C]
    par_cell.Tref = 25; % cell reference temperature [°C]
    
    % Cell diode parameters
    par_cell.Isd = 3.15e-7; % saturation current of cell internal diode [A]
    par_cell.EtaVt = 1.4*26e-3; % ideality factor * thermal voltage [V]
    
    % Cell resistance parameters
    par_cell.Rs = 4.2e-3; % cell series resistance [ohm]
    par_cell.Rsh = 10.1; % cell shunt resistance [ohm]
    
    % Bypass diode parameters
    par_dbp.Isd = 1e-9; % saturation current of bypass diode [A]
    par_dbp.EtaVt = 1.6*26e-3; % ideality factor * thermal voltage [V]
    
    % Series diode parameters
    par_ds.Isd = 1e-9; % saturation current of series diode [A]
    par_ds.EtaVt = 1.6*26e-3; % ideality factor * thermal voltage [V]
end