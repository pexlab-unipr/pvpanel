% Solar panel simulator

%% Cleaning
clear
clc
close all

%% Parameters

% System parameters
Ns = 12; % number of cells in series
Np = 3; % number of series in parallel
Nsim = 101; % number of measurements for contructing the characteristic
Vmax = 0.8;
init0 = zeros(Ns, Np);
init1 = ones(Ns, Np);
rng(68431, "twister")

% Cell photocurrent parameters
lambda = 1*init1; % normalized solar irradiation [sun]
lambda(1,1) = 0.2;
% lambda = 1 + 0.03*randn(Ns, Np);
Isc = 3.8*init1; % short circuit current [A]
Kth = -0.01*init1; % short circuit current temperature coefficient [A/K]
Tc = 25*init1; % cell temperature [°C]
Tr = 25*init1; % cell reference temperature [°C]
iph = init0; % photocurrent [A] UNKNOWN

% Cell diode parameters
Isdc = 3.15e-7*init1; % saturation current of cell internal diode [A]
EtaVtc = 1.4*26e-3*init1; % ideality factor * thermal voltage [V]
idc = init0; % cell diode current [A] UNKNOWN
vdc = init0; % cell diode voltage [A] UNKNOWN

% Cell resistance parameters
Rs = 4.2e-3*init1; % cell series resistance [ohm]
Rsh = 10.1*init1; % cell shunt resistance [ohm]
ic = init0; % cell current [A] UNKNOWN
vc = init0; % cell voltage [A] UNKNOWN

% TODO: for now, one bypass diode for each cell - modify
% Bypass diode parameters
Isdb = 1e-9*init1; % saturation current of bypass diode [A]
EtaVtb = 1.6*26e-3*init1; % ideality factor * thermal voltage [V]
idb = init0; % bypass diode current [A] UNKNOWN
% Bypass diode voltage is opposite to the cell voltage
% vdb = init0; % bypass diode voltage [A] UNKNOWN

% Series diode parameters
% Attention: only as many as the series in parallel (Np)
Isds = 1e-9*ones(1,Np); % saturation current of series diode [A]
EtaVts = 1.6*26e-3*ones(1,Np); % ideality factor * thermal voltage [V]
ids = zeros(1,Np); % series diode current [A] UNKNOWN
vds = zeros(1,Np); % series diode voltage [A] UNKNOWN

%% Simulation

% Baseline cell simulation (cell alone)
[vc_out, ic_out, pc_out, voc, isc, vmpp, impp, pmpp, ff, eta] = ...
    sim_cell(Nsim, Vmax, lambda, Tc, Isc, Kth, Tr, Isdc, EtaVtc, Rsh, Rs);

% Panel simulation, no diodes
[vp_out, ip_out, pp_out, vc, ic, pc, vocp, iscp, vmppp, imppp, pmppp, ffp, etap] = ...
    sim_panel(Nsim, Vmax, lambda, Tc, Isc, Kth, Tr, Isdc, EtaVtc, Rsh, Rs);

%% Results
figure
% hold on
for ii = 1:Np
    for jj = 1:Ns
        subplot(2,1,1)
        hold on
        plot(squeeze(vc_out(jj,ii,:)), squeeze(ic_out(jj,ii,:)), '-')
        subplot(2,1,2)
        hold on
        plot(squeeze(vc_out(jj,ii,:)), squeeze(pc_out(jj,ii,:)), '-')
        subplot(2,1,1)
        hold on
        plot(squeeze(vc(jj,ii,:)), squeeze(ic(jj,ii,:)), '--')
        subplot(2,1,2)
        hold on
        plot(squeeze(vc(jj,ii,:)), squeeze(pc(jj,ii,:)), '--')
        
    end
end
subplot(2,1,1)
xlabel('Cell voltage (V)')
ylabel('Cell current (A)')
ylim([0, max(ic_out, [], "all")])
box on
grid on
subplot(2,1,2)
xlabel('Cell voltage (V)')
ylabel('Cell power (W)')
ylim([0, max(pmpp, [], "all")])
box on
grid on

figure
subplot(2,1,1)
plot(vp_out, ip_out)
ylim([0, max(ip_out)])
xlabel('Panel voltage (V)')
ylabel('Panel current (A)')
subplot(2,1,2)
plot(vp_out, pp_out)
ylim([0, max(pp_out)])
xlabel('Panel voltage (V)')
ylabel('Panel power (W)')

%% ==== Functions ====
function id = fdiode(vd, Is, EtaVt)
    id = Is .* exp(vd./EtaVt - 1);
end

function iph = fphotocurr(lambda, Tc, Isc, Kth, Tr)
    iph = lambda .* (Isc + Kth.*(Tc - Tr));
end

function err = fcell(vc, ic, lambda, Tc, Isc, Kth, Tr, Is, EtaVt, Rsh, Rs)
    Gsh = 1./Rsh;
    err = ...
        fphotocurr(lambda, Tc, Isc, Kth, Tr) - ...
        fdiode(vc + Rs.*ic, Is, EtaVt) - ...
        Gsh.*(vc + Rs.*ic) - ...
        ic;
    err = err(:); % not necessary, provided for consistency with the following
end

function err = fpanel(vout, iout, vc, ic, lambda, Tc, Isc, Kth, Tr, Is, EtaVt, Rsh, Rs)
    [Ns, Np] = size(vc);
    Aser = ...
        [eye(Ns-1), zeros(Ns-1, 1)] + ...
        [zeros(Ns-1, 1), -eye(Ns-1)];
    err_cell = fcell(vc, ic, lambda, Tc, Isc, Kth, Tr, Is, EtaVt, Rsh, Rs);
    err_par = sum(vc, 1) - vout;
    err_ser = Aser * ic;
    err_itot = sum(ic(1,:)) - iout;
    err = [err_cell(:); err_par(:); err_ser(:); err_itot];
end

% Get cell metrics
function [pc, voc, isc, vmpp, impp, pmpp, ff, eta] = compute_cell_res(vc, ic)
    [Ns, Np] = size(ic, [1 2]);
    pc = vc.*ic;
    [~, ii_oc] = min(abs(ic), [], 3, "linear");
    voc = vc(ii_oc);
    isc = ic(:,:,1); % TODO: use param?
    [pmpp, ii_mpp] = max(pc, [], 3, "linear");
    vmpp = vc(ii_mpp);
    impp = ic(ii_mpp);
    ff = pmpp./(voc.*isc);
    eta = zeros(size(vc));
end

% Sim cell characteristic
function [vc, ic, pc, voc, isc, vmpp, impp, pmpp, ff, eta] = ...
    sim_cell(Nsim, Vmax, lambda, Tc, Isc, Kth, Tr, Is, EtaVt, Rsh, Rs)
    [Ns, Np] = size(lambda);
    opts = optimoptions("fsolve", 'Display', 'none');
    vc = linspace(0, Vmax, Nsim).';
    ic = zeros(Ns, Np, Nsim);
    for ii = 1:Nsim
        ic(:,:,ii) = fsolve(@(x) fcell(vc(ii), x, ...
            lambda, Tc, Isc, Kth, Tr, Is, EtaVt, Rsh, Rs), zeros(Ns, Np), opts);
    end
    vc = shiftdim(repmat(vc, [1, Ns, Np]), 1);
    [pc, voc, isc, vmpp, impp, pmpp, ff, eta] = compute_cell_res(vc, ic);
end

% Sim panel without diodes
function [vp, ip, pp, vc, ic, pc, voc, isc, vmpp, impp, pmpp, ff, eta] = ...
    sim_panel(Nsim, Vmax, lambda, Tc, Isc, Kth, Tr, Is, EtaVt, Rsh, Rs)
    [Ns, Np] = size(lambda);
    opts = optimoptions("fsolve", 'Display', 'none');
    vp = linspace(0, Ns*Vmax, Nsim).';
    ip = zeros(Nsim, 1);
    vc = zeros(Ns, Np, Nsim);
    ic = zeros(Ns, Np, Nsim);
    Nc = Ns*Np;
    for ii = 1:Nsim
        % Order: [ip_out; vc(:); ic(:)]
        x_out = ...
            fsolve(...
                @(x) fpanel(vp(ii), x(1), ...
                    reshape(x((1:Nc)+1), Ns, Np), ...
                    reshape(x((1:Nc)+1+Nc), Ns, Np), ...
                    lambda, Tc, Isc, Kth, Tr, Is, EtaVt, Rsh, Rs), ...
                zeros(2*Nc+1, 1), opts);
        ip(ii) = x_out(1);
        vc(:,:,ii) = reshape(x_out((1:Nc)+1), Ns, Np);
        ic(:,:,ii) = reshape(x_out((1:Nc)+1+Nc), Ns, Np);
    end
    pp = vp.*ip;
    [pc, voc, isc, vmpp, impp, pmpp, ff, eta] = compute_cell_res(vc, ic);
end