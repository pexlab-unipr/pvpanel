function err = fpanel(vout, iout, vc, ic, par_cell, par_sys)
    Ns = par_sys.Ns;
    err_cell = fcell(vc, ic, par_cell);
    err_par = sum(vc, 1) - vout;
    A = eye(Ns-1, Ns) - circshift(eye(Ns-1, Ns), 1, 2);
    err_ser = A*ic;
    err_itot = sum(ic(1,:)) - iout;
    err = [err_cell(:); err_par(:); err_ser(:); err_itot];
end
