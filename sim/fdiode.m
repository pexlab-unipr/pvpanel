function id = fdiode(vd, par)
    Isd = par.Isd;
    EtaVt = par.EtaVt;
    id = Isd .* exp(vd./EtaVt - 1);
end
