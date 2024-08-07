function out = compute_cell_res(vc, ic)
    out.vc = vc;
    out.ic = ic;
    out.pc = vc.*ic;
    [~, ii_oc] = min(abs(ic), [], 3, "linear");
    out.voc = vc(ii_oc);
    out.isc = ic(:,:,1); % TODO: use param?
    [out.pmpp, ii_mpp] = max(out.pc, [], 3, "linear");
    out.vmpp = vc(ii_mpp);
    out.impp = ic(ii_mpp);
    out.ff = out.pmpp./(out.voc.*out.isc);
    out.eta = zeros(size(vc));
end
