function out = sim_cell(par_sys, par_sim, par_cell)
    Ns = par_sys.Ns;
    Np = par_sys.Np;
    Vmax = par_sim.Vmax;
    Nsim = par_sim.Nsim;
    opts = optimoptions("fsolve", 'Display', 'none');
    vc = linspace(0, Vmax, Nsim).';
    ic = zeros(Ns, Np, Nsim);
    for ii = 1:Nsim
        ic(:,:,ii) = fsolve(@(x) fcell(vc(ii), x, par_cell), ...
            ic(:,:,ii), opts);
    end
    vc = shiftdim(repmat(vc, [1, Ns, Np]), 1);
    out = compute_cell_res(vc, ic);
end
