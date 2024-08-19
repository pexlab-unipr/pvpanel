function progress_bar(index, total, width, text)
    str = create_progress_string(index, total, width, text);
    canc = repmat('\b', 1, size(str, 2) + 1);
    fprintf(canc)
    fprintf('%s\n', str);
end

function str = create_progress_string(index, total, width, text)
    p = index/total; % normalized progress
    np = round(p*width);
    bar = [repmat('=', 1, np), repmat(' ', 1, width - np)];
    str = sprintf('%s: [%s] %5.1f %%', text, bar, p*100);
end    
    