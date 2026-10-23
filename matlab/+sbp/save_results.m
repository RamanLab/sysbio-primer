function save_results(scriptFile, results)
%SAVE_RESULTS  Write the key numbers of an example to out/matlab/results.json.
%   sbp.save_results(mfilename('fullpath'), results)
%
%   results is a struct. NaN values are written as JSON null, which is how
%   the Python side writes them too.

fid = fopen(fullfile(sbp.out_dir(scriptFile), 'results.json'), 'w');
fprintf(fid, '%s\n', jsonencode(results, 'PrettyPrint', true));
fclose(fid);
end
