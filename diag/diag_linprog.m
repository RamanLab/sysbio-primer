function diag_linprog()
% Temporary: which linprog algorithms work on this CI MATLAB?
algs = {'default', 'dual-simplex-highs', 'interior-point', ...
        'dual-simplex-legacy', 'interior-point-legacy'};
res = {sprintf('MATLAB %s', version)};
for k = 1:numel(algs)
    try
        if strcmp(algs{k}, 'default')
            o = optimoptions('linprog', 'Display', 'none');
        else
            o = optimoptions('linprog', 'Display', 'none', 'Algorithm', algs{k});
        end
        [x, f, ef] = linprog(-1, [], [], [], [], 0, 1, o);
        res{end+1} = sprintf('%s: ok (x=%g, exitflag=%d)', algs{k}, x, ef); %#ok<AGROW>
    catch e
        res{end+1} = sprintf('%s: %s', algs{k}, e.message); %#ok<AGROW>
    end
end
try
    s = ver('optim'); res{end+1} = sprintf('optim %s %s', s.Version, s.Release);
catch
end
msg = strrep(strjoin(res, newline), newline, '%0A');
fprintf('::warning title=linprog %s::%s\n', version('-release'), msg);
end
