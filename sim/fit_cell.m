function par_fit = fit_cell(vc, ic, varargin)
    % Columnify variables
    vc = vc(:);
    ic = ic(:);
    % Keep only positive current and voltage points
    flt = (vc > 0) & (ic > 0);
    vc = vc(flt);
    ic = ic(flt);
    % Configure explicit model fitting
    model = @(a, b, c, d, x) fcell_expl(x, [a, b, c, d]);
    ft = fittype(model);
    fo = fitoptions(ft);
    Icc0 = ic(1); % all data must be ordered!
    Voc0 = vc(end);
    Gp0 = (ic(1) - ic(2))/(vc(2) - vc(1));
    fo.StartPoint = [Icc0, Gp0, Icc0/exp(10), 10/Voc0];
    fo.Lower = [0, 0, 0, 0];
    % Fit model!
    [res, gof, out] = fit(vc, ic, ft, fo);
    assert(gof.rmse/Icc0 < 1e-2, 'Fitting relative error too big')
    assert(out.exitflag > 0, 'Fitting did not converge')
    par_fit = coeffvalues(res);
    A = par_fit(1);
    B = par_fit(2);
    C = par_fit(3);
    D = par_fit(4);
    
    Icc = par_fit(1)
    Voc = log(Icc/par_fit(3))/par_fit(4)
    Gp = par_fit(2)
    Voc_real = fzero(@(x) fcell_expl(x, par_fit), Voc)
    Vmpp = fzero(@(x) C*exp(D*x) - A/(1+D*x), 0.75*Voc)
    % Verify
    if nargin > 2 && varargin{1} == true
        figure
        plot(...
            vc, ic, '.b', ...
            vc, res(vc), '-r', ...
            vc, fcell_expl(vc, fo.StartPoint), '-g')
        xlim([0 Inf])
        ylim([0 Inf])
        xlabel('Voltage (V)')
        ylabel('Current (A)')
        legend(["data", "best fit", "start point"], ...
            'Location', 'southwest')
        box on
        grid on
    end
    if nargin > 3 && varargin{2} == true
        figure
        plot(...
            vc, vc.*ic, '.b', ...
            vc, vc.*res(vc), '-r', ...
            Vmpp, Vmpp.*fcell_expl(Vmpp, par_fit), 'xg')
        xlim([0 Inf])
        ylim([0 Inf])
        xlabel('Voltage (V)')
        ylabel('Power (W)')
        legend(["data", "best fit", "MPP"], ...
            'Location', 'southwest')
        box on
        grid on
    end
end