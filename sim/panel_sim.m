% Solar panel simulator

%% Cleaning
clear
clc
close all

%% Parameters
% rng(par_sim.rand_seed, "twister")
[par_sys, par_sim, par_cell, par_dbp, par_ds] = ...
    panel_param_default();
[par_sys, par_sim, par_cell, par_dbp, par_ds] = ...
    update_parameters(par_sys, par_sim, par_cell, par_dbp, par_ds);

%% Simulation
% Baseline cell simulation (cell alone)
% out_cell_ref = sim_cell(par_sys, par_sim, par_cell);

% Panel simulation, no diodes
[outp1, out_cell_panel] = sim_panel(par_sys, par_sim, par_cell);

% Panel simulation, with bypass and series diodes
[outp2, outc, outdb, outds] = sim_panel_diodes(...
    par_sys, par_sim, par_cell, par_dbp, par_ds);

% Shade them!
par_cell.lambda(1:2,1) = 0.1;

[outp3] = sim_panel(par_sys, par_sim, par_cell);
[outp4] = sim_panel_diodes(...
    par_sys, par_sim, par_cell, par_dbp, par_ds);

%% Results
figure
subplot(2,1,1)
plot(...
    outp1.vp, outp1.ip, ...
    outp2.vp, outp2.ip, ...
    outp3.vp, outp3.ip, ...
    outp4.vp, outp4.ip)
ylim([0, Inf])
xlabel('Panel voltage (V)')
ylabel('Panel current (A)')
legend([...
    "no diodes, unshaded"; ...
    "diodes, unshaded"; ...
    "no diodes, shaded"; ...
    "diodes, shaded"])
subplot(2,1,2)
plot(...
    outp1.vp, outp1.pp, ...
    outp2.vp, outp2.pp, ...
    outp3.vp, outp3.pp, ...
    outp4.vp, outp4.pp)
ylim([0, Inf])
xlabel('Panel voltage (V)')
ylabel('Panel power (W)')
