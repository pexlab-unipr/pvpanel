function out = repeat_pv_value(value, Ns, Np)
    assert(all(size(value) == [Ns, Np]) || all(size(value) == 1), ...
        'Inconsistent parameter shape (must be 1 or %d x %d).', ...
        Ns, Np)
    if size(value) == 1
        init1 = ones(Ns, Np);
        out = value * init1;
    else
        out = value;
    end
end