function run_examples(root)
%RUN_EXAMPLES  Run every MATLAB example under ROOT (default: examples/).
%   Each example folder holds an example.yml and one <name>.m script.
%   Examples that need the COBRA Toolbox assume initCobraToolbox has been run.
%   Errors are collected and reported at the end (non-zero exit in batch mode).

primer = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(primer, 'matlab'));
if nargin < 1
    root = fullfile(primer, 'examples');
end

ymls = dir(fullfile(root, '**', 'example.yml'));
failed = {};
for k = 1:numel(ymls)
    scripts = dir(fullfile(ymls(k).folder, '*.m'));
    if numel(scripts) ~= 1
        failed{end+1} = sprintf('%s: expected exactly one .m file', ymls(k).folder); %#ok<AGROW>
        continue
    end
    file = fullfile(scripts(1).folder, scripts(1).name);
    t0 = tic;
    try
        run_one(file);
        fprintf('[ok] %s (%.1f s)\n', file, toc(t0));
        annotate('notice', scripts(1).name, sprintf('ran in %.1f s', toc(t0)));
    catch err
        report = getReport(err, 'extended', 'hyperlinks', 'off');
        fprintf(2, '[FAILED] %s\n%s\n', file, report);
        annotate('error', scripts(1).name, report);
        failed{end+1} = file; %#ok<AGROW>
    end
    close all
end

if ~isempty(failed)
    error('run_examples:failed', '%d example(s) failed', numel(failed));
end
end

function annotate(level, title, message)
% On GitHub Actions, also report as an annotation, visible on the run page
% and through the API without opening the logs.
if isempty(getenv('GITHUB_ACTIONS'))
    return
end
message = strrep(message, '%', '%25');
message = strrep(message, sprintf('\r'), '%0D');
message = strrep(message, newline, '%0A');
fprintf('::%s title=%s::%s\n', level, title, message);
end

function run_one(file)
% Run a script in its own workspace so examples cannot affect each other.
run(file);
end
