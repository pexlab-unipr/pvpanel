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

%% Test

%% Simulation
% Panel simulation, no diodes
[outp1, outc1] = sim_panel(par_sys, par_sim, par_cell);

% Panel simulation, with bypass and series diodes
[outp2, outc2, outdb2, outds2] = sim_panel_diodes(...
    par_sys, par_sim, par_cell, par_dbp, par_ds);

% Shade them!
par_cell.lambda(1,1) = 0.3;
[outp, outc, outo] = sim_panel_optimizers(...
    par_sys, par_sim, par_cell);

% Baseline cell simulation (cell alone)
outc0 = sim_cell(par_sys, par_sim, par_cell);

[outp3, outc3] = sim_panel(par_sys, par_sim, par_cell);
[outp4, outc4, outdb4, outds4] = sim_panel_diodes(...
    par_sys, par_sim, par_cell, par_dbp, par_ds);

%% Results
figure
subplot(2,1,1)
plot(...
    outp1.vp, outp1.ip, ...
    outp2.vp, outp2.ip, ...
    outp3.vp, outp3.ip, ...
    outp4.vp, outp4.ip, ...
    outp.v, outp.i)
ylim([0, Inf])
xlabel('Panel voltage (V)')
ylabel('Panel current (A)')
legend([...
    "no diodes, unshaded"; ...
    "diodes, unshaded"; ...
    "no diodes, shaded"; ...
    "diodes, shaded"; ...
    "micro-optimizers"])
subplot(2,1,2)
plot(...
    outp1.vp, outp1.pp, ...
    outp2.vp, outp2.pp, ...
    outp3.vp, outp3.pp, ...
    outp4.vp, outp4.pp, ...
    outp.v, outp.p)
ylim([0, Inf])
xlabel('Panel voltage (V)')
ylabel('Panel power (W)')

%%
figure
hold on
%
plot(outp3.vp, squeeze(outc3.pc(1,1,:)), 'b--')
plot(outp4.vp, squeeze(outc4.pc(1,1,:)), 'b-')
plot(outp4.vp, squeeze(outc0.pc(1,1,:)), 'b.')
%
plot(outp3.vp, squeeze(outc3.pc(2,1,:)), 'r--')
plot(outp4.vp, squeeze(outc4.pc(2,1,:)), 'r-')
plot(outp4.vp, squeeze(outc0.pc(2,1,:)), 'r.')
%
box on
grid on
