% Solar panel simulator

%% Cleaning
clear
clc
close all

%% Parameters
% rng(par_sim.rand_seed, "twister")
% iph = init0; % photocurrent [A] UNKNOWN
% idc = init0; % cell diode current [A] UNKNOWN
% vdc = init0; % cell diode voltage [A] UNKNOWN
% ic = init0; % cell current [A] UNKNOWN
% vc = init0; % cell voltage [A] UNKNOWN
% idb = init0; % bypass diode current [A] UNKNOWN
% Bypass diode voltage is opposite to the cell voltage
% vdb = init0; % bypass diode voltage [A] UNKNOWN
% ids = zeros(1,Np); % series diode current [A] UNKNOWN
% vds = zeros(1,Np); % series diode voltage [A] UNKNOWN

[par_sys, par_sim, par_cell, par_dbp, par_ds] = ...
    panel_param_default();
[par_sys, par_sim, par_cell, par_dbp, par_ds] = ...
    update_parameters(par_sys, par_sim, par_cell, par_dbp, par_ds);
par_cell.lambda(1,1) = 0.2;

%% Simulation

% Baseline cell simulation (cell alone)
out_cell_ref = sim_cell(par_sys, par_sim, par_cell);

% Panel simulation, no diodes
[out_panel, out_cell_panel] = sim_panel(par_sys, par_sim, par_cell);

%% Results
figure
% hold on
for ii = 1:par_sys.Np
    for jj = 1:par_sys.Ns
        subplot(2,1,1)
        hold on
        plot(squeeze(out_cell_ref.vc(jj,ii,:)), squeeze(out_cell_ref.ic(jj,ii,:)), '-')
        subplot(2,1,2)
        hold on
        plot(squeeze(out_cell_ref.vc(jj,ii,:)), squeeze(out_cell_ref.pc(jj,ii,:)), '-')
        subplot(2,1,1)
        hold on
        plot(squeeze(out_cell_panel.vc(jj,ii,:)), squeeze(out_cell_panel.ic(jj,ii,:)), '--')
        subplot(2,1,2)
        hold on
        plot(squeeze(out_cell_panel.vc(jj,ii,:)), squeeze(out_cell_panel.pc(jj,ii,:)), '--')
        
    end
end
subplot(2,1,1)
xlabel('Cell voltage (V)')
ylabel('Cell current (A)')
ylim([0, max(out_cell_ref.ic, [], "all")])
box on
grid on
subplot(2,1,2)
xlabel('Cell voltage (V)')
ylabel('Cell power (W)')
ylim([0, max(out_cell_ref.pmpp, [], "all")])
box on
grid on

figure
subplot(2,1,1)
plot(out_panel.vp, out_panel.ip)
ylim([0, max(out_panel.ip)])
xlabel('Panel voltage (V)')
ylabel('Panel current (A)')
subplot(2,1,2)
plot(out_panel.vp, out_panel.pp)
ylim([0, max(out_panel.pp)])
xlabel('Panel voltage (V)')
ylabel('Panel power (W)')
