function cmd = gp_print_epslatex(p)

% convert unit to centimeters
if strcmp('px',p.size_unit)
    p.size = px2cm(p.size);
elseif strcmp('inches',p.size_unit)
    p.size = in2cm(p.size);
end

% get plotting command, including loudspeaker symbols and sound field
cmd_plot = gp_get_plot_command(p);

%% === set common Gnuplot commands
cmd = sprintf([...
'#!/usr/bin/gnuplot\n', ...
'# generated by SFS-Toolbox, see: http://github.com/sfstoolbox/sfs\n', ...
'set t epslatex size %fcm,%fcm color colortext\n', ...
'set output ''%s'';\n', ...
'set style line 1 lc rgb ''#000000'' pt 2 ps 2 lw 2\n\n', ...
'set format ''$%%g$''\n\n', ...
'unset key\n', ...
'set size ratio -1\n\n', ...
'# border\n', ...
'set style line 101 lc rgb ''#808080'' lt 1 lw 1\n', ...
'set border front ls 101\n\n', ...
'set colorbox\n', ...
'set palette gray negative\n', ...
'set xrange [%f:%f]\n', ...
'set yrange [%f:%f]\n', ...
'set cbrange [%f:%f]\n', ...
'set tics scale 0.75\n', ...
'set cbtics scale 0\n', ...
'set xtics 1\n', ...
'set ytics 1\n', ...
'set cbtics %f\n', ...
'set xlabel ''%s''\n', ...
'set ylabel ''%s''\n', ...
'set label ''%s'' at screen 0.84,0.14\n', ...
'%s\n', ...
'%s\n'], ...
p.size(1),p.size(2), ...
p.file, ...
p.xmin,p.xmax, ...
p.ymin,p.ymax, ...
p.caxis(1),p.caxis(2), ...
p.cbtics, ...
p.xlabel, ...
p.ylabel, ...
gp_get_label(p.dim,p.unit,'epslatex'), ...
p.cmd, ...
cmd_plot ...
);
