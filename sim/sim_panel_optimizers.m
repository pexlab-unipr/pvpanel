function [outp, outc, outdb, outds] = sim_panel_optimizers(...
    par_sys, par_sim, par_cell)
    
    % Since micro-optimizers are assumed to replace bypass diodes, the
    % quantitative parameters of them are utilized to establish the
    % quantities
    Np = par_sys.Np; % number of parallels (of optimizer strings)
    Nops = par_sys.Nbdps; % number of optimizers per string
    Ncpo = par_sys.Ncpbd; % number of cells per optimizer

    % 1) Compute curve of each substring, comprising Ncpbd cells in series
    % 2) Fix each substring working point to the MPP
    for iis = 1:Np % for each string in parallel
        for iio = 1:Nops % for each optimizer/substring in string
            this_par_cell = structfun(...
                @(x) x(((iio - 1)*Ncpo + 1):(iio*Ncpo),iis), ...
                par_cell, 'UniformOutput', false);
            % [outp1, outc1] = sim_panel(par_sys, par_sim, this_par_cell);
        end
    end

    % 3) Fix each converter output working point
    
    % 4) Compute the overall panel + optimizers characteristic curve
    
    % Dummy output, for now
    outp = 0;
    outc = 0;
    outdb = 0;
    outds = 0;
end
