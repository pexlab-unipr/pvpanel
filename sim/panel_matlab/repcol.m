function y = repcol(x, n)
    % For now, support only matrices
    assert(numel(size(x)) == 2, 'Can be applied matrices only.')
    [Nr, Nc] = size(x);
    y = repmat(x, n, 1);
    y = reshape(y, [Nr, Nc*n]);
end