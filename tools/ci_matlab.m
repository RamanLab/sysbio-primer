function ci_matlab()
%CI_MATLAB  What the GitHub Actions MATLAB job runs: set up the COBRA
%   Toolbox (if it was downloaded to ~/cobratoolbox), then run all examples.
%   A COBRA Toolbox problem is reported but does not stop the other examples.

primer = fileparts(fileparts(mfilename('fullpath')));
cobra = fullfile(getenv('HOME'), 'cobratoolbox');
fprintf('MATLAB %s\n', version);
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
        msg = strrep(getReport(err, 'extended', 'hyperlinks', 'off'), newline, '%0A');
        fprintf('::error title=COBRA Toolbox setup::%s\n', msg);
    end
    cd(here);
end
addpath(fullfile(primer, 'tools'));
run_examples();
end
