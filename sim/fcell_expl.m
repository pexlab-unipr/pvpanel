function ic = fcell_expl(vc, par)
    a = par(1);
    b = par(2);
    c = par(3);
    d = par(4);
    ic = a - b*vc - c*exp(d*vc);
end
