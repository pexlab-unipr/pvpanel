function err = fpanel_diodes(vout, iout, vc, ic, vdb, idb, vds, ids, ...
    par_cell, par_sys, par_dbp, par_ds)
    % Local parameters
    Ns = par_sys.Ns;
    Nbdps = par_sys.Nbdps;
    Ncpbd = par_sys.Ncpbd;
    
    % Satisfy cell model
    err_cell = fcell(vc, ic, par_cell);
    % Satisfy diodes models
    err_dbp = idb - fdiode(vdb, par_dbp);
    err_ds = ids - fdiode(vds, par_ds);
    % Each bypass diode in parallel with cells
    A = repelem(eye(Nbdps), 1, Ncpbd); %repcol(eye(Nbd), Ncpbd);
    err_par_cell_dbp = A*vc + vdb;
    % Diode strings in parallel
    err_par = sum([vds; vdb], 1) + vout;
    % Cells in series inside bypass diode
    A = -eye(Ns-1, Ns) + circshift(eye(Ns-1, Ns), 1, 2);
    B = zeros(Ns-1, Nbdps);
    C = -eye(Nbdps-1, Nbdps) + circshift(eye(Nbdps-1, Nbdps), 1, 2);
    B(Ncpbd:Ncpbd:end,:) = C;
    err_ser_cell = A*ic + B*idb;
    % Cells and bypass diodes in series with series diode
    err_ser = ic(1,:) + idb(1,:) - ids;
    % Total current on output (sum of series diode currents)
    err_itot = sum(ids) - iout;
    err = [...
        err_cell(:);
        err_dbp(:);
        err_ds(:);
        err_par_cell_dbp(:);
        err_par(:);
        err_ser_cell(:);
        err_ser(:);
        err_itot];
end
