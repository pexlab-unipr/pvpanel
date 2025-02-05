function [outp, outc] = sim_panel(par_sys, par_sim, par_cell)
    Ns = par_sys.Ns;
    Np = par_sys.Np;
    Nc = par_sys.Nc;
    Vmax = par_sim.Vmax;
    Nsim = par_sim.Nsim;
    opts = optimoptions("fsolve", 'Display', 'none');
    vp = linspace(0, Ns*Vmax, Nsim).';
    ip = zeros(Nsim, 1);
    vc = zeros(Ns, Np, Nsim);
    ic = zeros(Ns, Np, Nsim);
    for ii = 1:Nsim
        % Order: [ip_out; vc(:); ic(:)]
        x_out = ...
            fsolve(...
                @(x) fpanel(vp(ii), x(1), ...
                    reshape(x((1:Nc)+1), Ns, Np), ...
                    reshape(x((1:Nc)+1+Nc), Ns, Np), ...
                    par_cell, par_sys), ...
                zeros(2*Nc+1, 1), opts);
        ip(ii) = x_out(1);
        vc(:,:,ii) = reshape(x_out((1:Nc)+1), Ns, Np);
        ic(:,:,ii) = reshape(x_out((1:Nc)+1+Nc), Ns, Np);
    end
    outp.vp = vp;
    outp.ip = ip;
    outp.pp = vp.*ip;
    outc = compute_cell_res(vc, ic);
end
