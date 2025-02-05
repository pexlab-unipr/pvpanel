function out = compute_cell_res(vc, ic)
    % If the input is a row or a column vector, reshape it to have the
    % variable elements along the third dimension, thus being consistent
    % with how cells array are managed
    if isvector(vc)
        vc = reshape(vc, [1, 1, numel(vc)]);
        ic = reshape(ic, [1, 1, numel(ic)]);
    end
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
