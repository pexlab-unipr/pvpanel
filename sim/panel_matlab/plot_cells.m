function plot_cells(outc, par_sys)
    figure
    for ii = 1:par_sys.Np
        for jj = 1:par_sys.Ns
            subplot(2,1,1)
            hold on
            plot(squeeze(outc.vc(jj,ii,:)), squeeze(outc.ic(jj,ii,:)), '-')
            subplot(2,1,2)
            hold on
            plot(squeeze(outc.vc(jj,ii,:)), squeeze(outc.pc(jj,ii,:)), '-')
        end
    end
    subplot(2,1,1)
    xlabel('Cell voltage (V)')
    ylabel('Cell current (A)')
    ylim([0, Inf])
    box on
    grid on
    subplot(2,1,2)
    xlabel('Cell voltage (V)')
    ylabel('Cell power (W)')
    ylim([0, Inf])
    box on
    grid on
end