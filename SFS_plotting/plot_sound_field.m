function plot_sound_field(P,x,y,z,x0,conf)
%PLOT_SOUND_FIELD plot the given sound field
%
%   Usage: plot_sound_field(P,x,y,z,[x0],[conf])
%
%   Input parameters:
%       P           - matrix containing the sound field in the format P = P(y,x)
%       x,y,z       - vectors for the x-, y- and z-axis
%       x0          - matrix containing the secondary source positions to plot.
%                     Default: plot no secondary sources
%       conf        - optional configuration struct (see SFS_config)
%
%   PLOT_SOUND_FIELD(P,x,y,z,x0,conf) plots the sound field P in dependence
%   of the axes that are not singleton. To calculate what axes these are you
%   have to provide all three of them. For a given set x0 of secondary sources
%   the secondary sources are added as dots or loudspeaker symbols depending on
%   your setting of conf.plot.realloudspeakers.
%
%   See also: sound_field_mono, sound_field_imp

%*****************************************************************************
% Copyright (c) 2010-2015 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Telekom Innovation Laboratories, TU Berlin         *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013-2015 Institut fuer Nachrichtentechnik                   *
%                         Universitaet Rostock                               *
%                         Richard-Wagner-Strasse 31, 18119 Rostock           *
%                                                                            *
% This file is part of the Sound Field Synthesis-Toolbox (SFS).              *
%                                                                            *
% The SFS is free software:  you can redistribute it and/or modify it  under *
% the terms of the  GNU  General  Public  License  as published by the  Free *
% Software Foundation, either version 3 of the License,  or (at your option) *
% any later version.                                                         *
%                                                                            *
% The SFS is distributed in the hope that it will be useful, but WITHOUT ANY *
% WARRANTY;  without even the implied warranty of MERCHANTABILITY or FITNESS *
% FOR A PARTICULAR PURPOSE.                                                  *
% See the GNU General Public License for more details.                       *
%                                                                            *
% You should  have received a copy  of the GNU General Public License  along *
% with this program.  If not, see <http://www.gnu.org/licenses/>.            *
%                                                                            *
% The SFS is a toolbox for Matlab/Octave to  simulate and  investigate sound *
% field  synthesis  methods  like  wave  field  synthesis  or  higher  order *
% ambisonics.                                                                *
%                                                                            *
% http://github.com/sfstoolbox/sfs                      sfstoolbox@gmail.com *
%*****************************************************************************


%% ===== Checking of input  parameters ==================================
nargmin = 4;
nargmax = 6;
narginchk(nargmin,nargmax);
isargvector(x,y,z);
isargnumeric(P);
if nargin==nargmax-1
    if isstruct(x0)
        conf = x0;
        x0 = [];
    else
        conf = SFS_config;
    end
elseif nargin==nargmax-2
    conf = SFS_config;
    x0 = [];
end
if isempty(x0)
    conf.plot.loudspeakers = 0;
end
isargstruct(conf);


%% ===== Configuration ==================================================
% Tmp dir
tmpdir = conf.tmpdir;
usenormalisation = conf.usenormalisation;
% Plotting
p.cmd = conf.plot.cmd;
p.usedb = conf.plot.usedb;
p.mode = conf.plot.mode;
p.size = conf.plot.size;
p.size_unit = conf.plot.size_unit;
p.caxis = conf.plot.caxis;
p.colormap = conf.plot.colormap;
p.loudspeakers = conf.plot.loudspeakers;
p.realloudspeakers = conf.plot.realloudspeakers;
p.lssize = conf.plot.lssize;
p.usefile = conf.plot.usefile;
p.file = conf.plot.file;


%% ===== Calculation =====================================================
% Handle the given axis and check which should be plotted
[dimensions,x1,x2] = xyz_axes_selection(x,y,z);
if all(dimensions)
    error(['%s: at the moment no method is implemented to plot ', ...
        'a complete 3D cube of points. Your sound field has the ', ...
        'dimension [%i %i %i]. Discard one of the dimension for ', ...
        'plotting.'],upper(mfilename),size(P,1),size(P,2),size(P,3));
elseif ~any(dimensions)
    error(['%s: you have only one point in the sound field. ', ...
        'Omitting the plotting.'],upper(mfilename));
elseif ~dimensions(1)
    % FIXME: in order to work with gnuplot the label should be printed
    % with the extra function, which can handle if the output should be
    % LaTeX or something else
    %str_xlabel = print_label('y','m',conf);
    p.xlabel = 'y / m';
    p.ylabel = 'z / m';
elseif ~dimensions(2)
    p.xlabel = 'x / m';
    p.ylabel = 'z / m';
elseif ~dimensions(3)
    p.xlabel = 'x / m';
    p.ylabel = 'y / m';
else
    % FIXME: in this case every three axis should be plotted and we should
    % switch to use splot or some other alternativ to plot it in 3D.
    to_be_implemented(mfilename);
end

if(p.usedb)
    % Check if we have any activity in the sound field
    if max(abs(P(:)))~=0
        % For the dB case scale the signal maximum to 0 dB
        %P = P./max(abs(P(:)));
    else
        % If we have only zeros in the sound field set the field to eps to avoid
        % problems with log(0).
        P(:) = eps;
    end
    % Change default colormap to chromajs
    conf.plot.colormap = 'chromajs';
end

% Check if we should plot loudspeakers symbols
if p.realloudspeakers && size(x0,1)>1000
    warning(['%s: the given number of loudspeaker is >1000. ',...
            'Switching back to non loudspeaker symbols.'],upper(mfilename));
    p.realloudspeakers = 0;
end

% set the color bar axis to default values if not given otherwise
if p.caxis, else
    if p.usedb
        p.caxis = [-45,0];
    else
        p.caxis = [-1,1];
    end
end


%% ===== Plotting ========================================================

% Create a new figure
figure;
% Set size
figsize(p.size(1),p.size(2),p.size_unit);

% Scale dB value if needed
if p.usedb
    P_dB = 20*log10(abs(P));
    if usenormalisation
        P_dB = P_dB - max(P_dB(:));
    end
else
  if usenormalisation
    % === Scale signal (at xref) ===
    P = norm_sound_field_at_xref(P,x,y,z,conf);
  end
end

% Plotting
if sum(dimensions)==1 % singleton dimension
    if p.usedb
        plot(x1,P_dB);
        xlabel(p.xlabel);
        ylabel('Amplitude / dB');
    else
        plot(x1,real(P));
        xlabel(p.xlabel);
        ylabel('Amplitude');
    end
else

    if p.usedb
        % Plot the amplitude of the sound field in dB
        imagesc(x1,x2,P_dB,p.caxis);
    else
        % Plot the sound field
        imagesc(x1,x2,real(P),p.caxis);
    end

    % Add color bar
    set_colorbar(conf);

    % Set the y direction in normal mode (imagesc uses the reverse mode by
    % default)
    turn_imagesc;

    % Set the axis to use the same amount of space for the same length (m)
    axis image;
    % Labels etc. for the plot
    xlabel(p.xlabel);
    ylabel(p.ylabel);
    % Add loudspeaker to the plot
    %x0(:,1:2) = x0(:,2:3);
    if p.loudspeakers % && dimensions(1) && dimensions(2)
        hold on;
        draw_loudspeakers(x0,dimensions,conf);
        hold off;
    end
end

% Save as file
if ~isempty(p.file) && strcmp('png',p.file(end-2:end))
    print_png(p.file);
elseif ~isempty(p.file) && strcmp('eps',p.file(end-2:end))
    print_eps(p.file);
end
