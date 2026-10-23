function save_figure(fig, scriptFile, name)
%SAVE_FIGURE  Save a figure as out/matlab/<name>.png.
%   sbp.save_figure(gcf, mfilename('fullpath'), 'fig-name')

file = fullfile(sbp.out_dir(scriptFile), [name '.png']);
if exist('exportgraphics', 'file')
    exportgraphics(fig, file, 'Resolution', 150);
else  % older MATLAB, or GNU Octave
    print(fig, file, '-dpng', '-r150');
end
end
