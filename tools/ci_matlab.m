function ci_matlab()
%CI_MATLAB  What the GitHub Actions MATLAB job runs.
%   Runs the examples that do not need the COBRA Toolbox first, and only
%   then sets up the COBRA Toolbox (if it was downloaded to ~/cobratoolbox)
%   and runs the examples that do. Once the COBRA Toolbox is on the path,
%   MATLAB's own linprog fails ("Unrecognized field name optimstatus"),
%   so the two groups must not share a session in that order.

primer = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(primer, 'tools'));
fprintf('MATLAB %s\n', version);
diagnose_linprog();  % TEMPORARY: investigating a linprog failure in CI
failed = run_examples([], 'nocobra');

cobra = fullfile(getenv('HOME'), 'cobratoolbox');
if exist(cobra, 'dir')
    here = pwd;
    try
        cd(cobra);
        initCobraToolbox(false);
        if ~changeCobraSolver('glpk', 'LP', 0)
            changeCobraSolver('matlab', 'LP');
        end
        fprintf('::notice title=COBRA Toolbox::ready\n');
    catch err
        msg = strrep(getReport(err, 'extended', 'hyperlinks', 'off'), ...
            newline, '%0A');
        fprintf('::error title=COBRA Toolbox setup::%s\n', msg);
    end
    cd(here);
    failed = [failed, run_examples([], 'cobra')];
end

if ~isempty(failed)
    error('ci_matlab:failed', '%d example(s) failed', numel(failed));
end
end

function diagnose_linprog()
% TEMPORARY diagnostics, reported as annotations.
out = evalc('which -all linprog');
src = readlines(which('linprog'));
seg = strjoin(compose('%d: %s', (360:390)', src(360:390)), newline);
try
    linprog(-1, [], [], [], [], 0, 1);
    r1 = 'plain call ok';
catch e
    r1 = ['plain call: ' e.message];
end
try
    linprog(-1, [], [], [], [], 0, 1, optimoptions('linprog', 'Display', 'none'));
    r2 = 'with optimoptions ok';
catch e
    r2 = ['with optimoptions: ' e.message];
end
msg = strjoin({out, r1, r2, seg, evalc('path')}, newline);
msg = strrep(strrep(msg, '%', '%25'), newline, '%0A');
fprintf('::warning title=linprog diagnostics::%s\n', msg(1:min(end, 60000)));
end
