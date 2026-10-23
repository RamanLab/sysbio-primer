function d = out_dir(scriptFile)
%OUT_DIR  Folder where an example writes its outputs (created if needed).
%   d = sbp.out_dir(mfilename('fullpath'))

d = fullfile(fileparts(scriptFile), 'out', 'matlab');
if ~exist(d, 'dir')
    mkdir(d);
end
end
