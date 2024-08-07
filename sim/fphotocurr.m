function iph = fphotocurr(par)
    lambda = par.lambda;
    Tc0 = par.Tc0;
    Isc = par.Isc;
    Kth = par.Kth;
    Tref = par.Tref;
    iph = lambda .* (Isc + Kth.*(Tc0 - Tref));
end
