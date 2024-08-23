function [par_sys, par_sim, par_cell, par_dbp, par_ds, par_opt] = ...
    update_parameters(par_sys, par_sim, par_cell, par_dbp, par_ds, par_opt)
    % The number of cells in series to which each bypass diode is connected
    % must be an even submultiple of the number of cells in series in the
    % panel/plant
    assert(rem(par_sys.Ns, par_sys.Ncpbd) == 0, ...
        ['The number of cells in series (%d) must be a whole multiple ', ...
         'of the number of cell in series per each bypass diode (%d).'], ...
        par_sys.Ns, par_sys.Ncpbd)

    % Compute dependent quantities
    par_sys.Nc = par_sys.Ns*par_sys.Np; % Total number of cells
    par_sys.Nbdps = floor(par_sys.Ns/par_sys.Ncpbd); % Number of bypass diodes per string
    par_sys.Nbd = par_sys.Nbdps*par_sys.Np; % Total number of bypass diodes

    % Expand scalar parameters to obtain a matrix representing the array
    par_cell = structfun(@(x) repeat_pv_value(x, par_sys.Ns, par_sys.Np), ...
        par_cell, 'UniformOutput', false);
    par_dbp = structfun(@(x) repeat_pv_value(x, par_sys.Nbdps, par_sys.Np), ...
        par_dbp, 'UniformOutput', false);
    par_ds = structfun(@(x) repeat_pv_value(x, 1, par_sys.Np), ...
        par_ds, 'UniformOutput', false);

    % Compute matrix quantities for convenience
    par_cell.Gsh = 1./par_cell.Rsh;
end