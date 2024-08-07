function err = fpanel(vout, iout, vc, ic, par_cell, par_sys)
    Ns = par_sys.Ns;
    Aser = ...
        [eye(Ns-1), zeros(Ns-1, 1)] + ...
        [zeros(Ns-1, 1), -eye(Ns-1)];
    err_cell = fcell(vc, ic, par_cell);
    err_par = sum(vc, 1) - vout;
    err_ser = Aser * ic;
    err_itot = sum(ic(1,:)) - iout;
    err = [err_cell(:); err_par(:); err_ser(:); err_itot];
end
