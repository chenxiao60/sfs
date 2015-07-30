function [P, x, y, z] = sound_field_mono_nfchoa_sht(X,Y,Z,Dnm,f,conf)
%SOUND_FIELD_MONO_NFCHOA_SHT simulates a sound field given with the 
%spherical harmonics transform of the nfchoa driving function
%
%   Usage: [P, x, y, z] = sound_field_mono_sht(X,Y,Z,Dnm,f,conf)
%
%   Input parameters:
%       X           - x-axis / m; single value or [xmin,xmax] or nD-array
%       Y           - y-axis / m; single value or [ymin,ymax] or nD-array
%       Z           - z-axis / m; single value or [zmin,zmax] or nD-array
%       Dnm         - spherical harmonics transform of nfchoa driving function
%       f           - frequency in Hz
%       conf        - optional configuration struct (see SFS_config)
%
%   Output parameters:
%       P           - resulting soundfield
%
%   SOUND_FIELD_MONO_NFCHOA_SHT(X,Y,Z,ABnm,mode,f,conf)
%
%   see also: sphbasis_mono_grid, sound_field_mono_sphexp

%*****************************************************************************
% Copyright (c) 2010-2014 Quality & Usability Lab, together with             *
%                         Assessment of IP-based Applications                *
%                         Telekom Innovation Laboratories, TU Berlin         *
%                         Ernst-Reuter-Platz 7, 10587 Berlin, Germany        *
%                                                                            *
% Copyright (c) 2013-2014 Institut fuer Nachrichtentechnik                   *
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
nargmin = 5;
nargmax = 6;
narginchk(nargmin,nargmax);
isargvector(Dnm);
isargsquaredinteger(length(Dnm));
isargnumeric(X,Y,Z);
% unique index encoding which dimension is an nd-array
customGrid = (numel(X) > 2) + 2*(numel(Y) > 2) + 4*(numel(Z) > 2);
switch customGrid
  case 1
    isargscalar(Y,Z);
  case 2
    isargscalar(X,Z);
  case 3
    isargequalsize(X,Y); isargscalar(Z);
  case 4
    isargscalar(X,Y);
  case 5
    isargequalsize(X,Z); isargscalar(Y);
  case 6
    isargequalsize(Y,Z); isargscalar(X);
  case 7
    isargequalsize(X,Y,Z);
  otherwise
    isargvector(X,Y,Z);
end
isargpositivescalar(f);
if nargin<nargmax
    conf = SFS_config;
else
    isargstruct(conf);
end

%% ===== Configuration ==================================================
Xc = conf.secondary_sources.center;
r0 = conf.secondary_sources.size / 2;

%% ===== Computation ====================================================
if customGrid
  switch customGrid
    case 1
      Y = repmat(Y, size(X));
      Z = repmat(Z, size(X));
    case 2
      X = repmat(X, size(Y));
      Z = repmat(Z, size(Y));
    case 3
      Z = repmat(Z, size(Y));
    case 4
      X = repmat(X, size(Z));
      Y = repmat(Y, size(Z));
    case 5
      Y = repmat(Y, size(Z));
    case 6
      X = repmat(X, size(Z));      
  end
  x = X;   y = Y;  z = Z;
else
  [X,Y,Z,x,y,z] = xyz_grid(X,Y,Z,conf);
end
% find coordinates, which are inside and outside the loudspeaker array
select = sqrt((X(:)-Xc(1)).^2 + (Y(:)-Xc(2)).^2 + (Z(:)-Xc(3)).^2) <= r0;

P = zeros(size(X));

if any(select(:))
  Pnm = sphexp_mono_nfchoa_sht(Dnm,'R',f,conf);
  P(select) = sound_field_mono_sphexp(X(select),Y(select),Z(select), Pnm, ...
    'R', f, Xc,conf);
end
if any(~select(:))
  Pnm = sphexp_mono_nfchoa_sht(Dnm,'S',f,conf);
  P(~select) = sound_field_mono_sphexp(X(~select),Y(~select),Z(~select), ...
    Pnm, 'S', f, Xc,conf);
end

end