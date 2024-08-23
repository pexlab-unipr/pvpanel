function [outp, outc, outo] = sim_panel_optimizers(...
    par_sys, par_sim, par_cell)
    
    Nsim = par_sim.Nsim;
    Vmax = par_sim.Vmax;

    % Since micro-optimizers are assumed to replace bypass diodes, the
    % quantitative parameters of them are utilized to establish the
    % quantities
    Ns = par_sys.Ns;
    Np = par_sys.Np; % number of parallels (of optimizer strings)
    Nops = par_sys.Nbdps; % number of optimizers per string
    Ncpo = par_sys.Ncpbd; % number of cells per optimizer

    % Preallocate structure for cell working points: they are independent
    % of the output voltage, because substrings are always kept in MPP by
    % the optimizers
    outc.v = zeros(Ns, Np);
    outc.i = zeros(Ns, Np);
    % Optimizer working points are different at the output, but unique at
    % te input; on the output they do depend on overall panel voltage
    outo.vi = zeros(Nops, Np);
    outo.ii = zeros(Nops, Np);
    outo.vo = zeros(Nops, Np, Nsim);
    outo.io = zeros(Nops, Np, Nsim);
    
    % 1) Compute curve of each substring, comprising Ncpbd cells in series
    for iis = 1:Np % for each string in parallel
        for iio = 1:Nops % for each optimizer/substring in string
            this_par_cell = structfun(...
                @(x) x(((iio - 1)*Ncpo + 1):(iio*Ncpo),iis), ...
                par_cell, 'UniformOutput', false);
            this_par_sys.Ns = Ncpo;
            this_par_sys.Np = 1;
            this_par_sys.Nc = Ncpo;
            [outss] = sim_panel(this_par_sys, par_sim, this_par_cell);

            % 2) Find MPP of each substring
            this_res = compute_cell_res(outss.vp, outss.ip);
            outo.vi(iio,iis) = this_res.vmpp;
            outo.ii(iio,iis) = this_res.impp;
            % Equals for each optimizer input and all the cells connected
            % to it
            outc.v(((iio - 1)*Ncpo + 1):(iio*Ncpo),iis) = this_res.vmpp;
            outc.i(((iio - 1)*Ncpo + 1):(iio*Ncpo),iis) = this_res.impp;
        end
    end

    % 3) Fix each converter output working point
    vp = reshape(linspace(0, Ns*Vmax, Nsim), [1 1 Nsim]);
    pmpps = sum(outo.vi .* outo.ii, 1); % MPP power for each string
    outo.vo = outo.vi .* outo.ii .* vp ./ pmpps;
    outo.io = outo.vi .* outo.ii ./ outo.vo;
    % Remove NaN or Inf arising dividing by zero (limits value)
    flt = ...
        isnan(outo.vo) | isinf(outo.vo) | ...
        isnan(outo.io) | isinf(outo.io);
    outo.vo(flt) = 0;
    outo.io(flt) = 0;

    % 4) Compute the overall panel + optimizers characteristic curve
    outp.v = vp(:);
    outp.i = squeeze(sum(outo.io(1,:,:), 2));
    outp.p = outp.v .* outp.i;
end
