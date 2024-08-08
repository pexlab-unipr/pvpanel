function [outp, outc, outdb, outds] = sim_panel_diodes(...
    par_sys, par_sim, par_cell, par_dbp, par_ds)
    % Local parameters
    Ns = par_sys.Ns;
    Np = par_sys.Np;
    Nc = par_sys.Nc;
    % Ncpbd = par_sys.Ncpbd;
    Nbdps = par_sys.Nbdps;
    Nbd = par_sys.Nbd;
    Vmax = par_sim.Vmax;
    Nsim = par_sim.Nsim;

    % Preallocation of output variables
    vp = linspace(0, Ns*Vmax, Nsim).';
    ip = zeros(Nsim, 1);
    vc = zeros(Ns, Np, Nsim);
    ic = zeros(Ns, Np, Nsim);
    vdb = zeros(Nbdps, Np, Nsim);
    idb = zeros(Nbdps, Np, Nsim);
    vds = zeros(1, Np, Nsim);
    ids = zeros(1, Np, Nsim);

    % Limits of columnified tables
    nvar = [1, Nc, Nc, Nbd, Nbd, Np, Np];
    iib = cumsum(nvar);
    iib(1) = [];
    iia = 1 + cumsum(nvar(1:end-1));
    x = zeros(sum(nvar), 1);
    opts = optimoptions("fsolve", 'Display', 'none');
    for ii = 1:Nsim
        % Order [quantity]: [ip_out [1]; vc(:) [Nc]; ic(:) [Nc]; 
        %   vdb(:) [Nbd], idb(:) [Nbd], vds(:) [Np], ids(:) [Np]]
        x = ...
            fsolve(...
                @(x) fpanel_diodes(...
                    vp(ii), x(1), ...
                    reshape(x(iia(1):iib(1)), Ns, Np), ...
                    reshape(x(iia(2):iib(2)), Ns, Np), ...
                    reshape(x(iia(3):iib(3)), Nbdps, Np), ...
                    reshape(x(iia(4):iib(4)), Nbdps, Np), ...
                    reshape(x(iia(5):iib(5)), 1, Np), ...
                    reshape(x(iia(6):iib(6)), 1, Np), ...
                    par_cell, par_sys, par_dbp, par_ds), ...
                x, opts);
        ip(ii) = x(1);
        vc(:,:,ii)  = reshape(x(iia(1):iib(1)), Ns, Np);
        ic(:,:,ii)  = reshape(x(iia(2):iib(2)), Ns, Np);
        vdb(:,:,ii) = reshape(x(iia(3):iib(3)), Nbdps, Np);
        idb(:,:,ii) = reshape(x(iia(4):iib(4)), Nbdps, Np);
        vds(:,:,ii) = reshape(x(iia(5):iib(5)), 1, Np);
        ids(:,:,ii) = reshape(x(iia(6):iib(6)), 1, Np);
        disp(ii)
    end
    outp.vp = vp;
    outp.ip = ip;
    outp.pp = vp.*ip;
    outc = compute_cell_res(vc, ic);
    outdb.vd = vdb;
    outdb.id = idb;
    outds.vd = vds;
    outds.id = ids;
end
