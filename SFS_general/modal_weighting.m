function [win,Win,Phi] = modal_weighting(order,ndtft,conf)
%MODAL_WEIGHTING computes weighting window for modal coefficients
%
%   Usage: [win,Win,Phi] = modal_weighting(order,[ndtft],conf)
%
%   Input parameters:
%       order       - half width of weighting window / 1
%       ndtft       - number of bins for inverse discrete-time Fourier transform
%                     (DTFT) / 1 (optional, default: 2*order+1)
%       conf        - configuration struct (see SFS_config)
%
%   Output parameters:
%       win         - the window w_n in the discrete domain (length = 2*order+1)
%       Win         - the inverse DTFT of w_n (length = ndtft)
%       Phi         - corresponding angle the inverse DTFT of w_n
%
%   MODAL_WEIGHTING(order,ndtft,conf) calculates a weighting window for the
%   modal band limitation applied in NFC-HOA. The window type is configured in
%   conf.nfchoa.modal_window. Its default setting is a simple rectangular
%   window, for other options have a look into SFS_config.
%
%   References:
%   	Kaiser, J., & Schafer, R. (1980) - "On the use of the I0-sinh window
%           for spectrum analysis", IEEE Transactions on Acoustics, Speech, and
%           Signal Processing
%       Van Trees, H. L. (2004) - "Optimum Array Processing", John Wiley & Sons.
%
%   See also: driving_function_imp_nfchoa, driving_function_mono_nfchoa

%*****************************************************************************
% The MIT License (MIT)                                                      *
%                                                                            *
% Copyright (c) 2010-2016 SFS Toolbox Developers                             *
%                                                                            *
% Permission is hereby granted,  free of charge,  to any person  obtaining a *
% copy of this software and associated documentation files (the "Software"), *
% to deal in the Software without  restriction, including without limitation *
% the rights  to use, copy, modify, merge,  publish, distribute, sublicense, *
% and/or  sell copies of  the Software,  and to permit  persons to whom  the *
% Software is furnished to do so, subject to the following conditions:       *
%                                                                            *
% The above copyright notice and this permission notice shall be included in *
% all copies or substantial portions of the Software.                        *
%                                                                            *
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR *
% IMPLIED, INCLUDING BUT  NOT LIMITED TO THE  WARRANTIES OF MERCHANTABILITY, *
% FITNESS  FOR A PARTICULAR  PURPOSE AND  NONINFRINGEMENT. IN NO EVENT SHALL *
% THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER *
% LIABILITY, WHETHER  IN AN  ACTION OF CONTRACT, TORT  OR OTHERWISE, ARISING *
% FROM,  OUT OF  OR IN  CONNECTION  WITH THE  SOFTWARE OR  THE USE  OR OTHER *
% DEALINGS IN THE SOFTWARE.                                                  *
%                                                                            *
% The SFS Toolbox  allows to simulate and  investigate sound field synthesis *
% methods like wave field synthesis or higher order ambisonics.              *
%                                                                            *
% http://sfstoolbox.org                                 sfstoolbox@gmail.com *
%*****************************************************************************


%% ===== Checking input parameters =======================================
nargmin = 2;
nargmax = 3;
narginchk(nargmin,nargmax);
isargpositivescalar(order);
if nargin<nargmax
    conf = ndtft;
    ndtft = 2*order + 1;
end
isargpositivescalar(ndtft);
isargstruct(conf);


%% ===== Configuration ===================================================
wtype = conf.nfchoa.modal_window;


%% ===== Computation =====================================================
switch wtype
    case 'rect'
        % === Rectangular Window =========================================
        win = ones(1,2*order+1);
    case {'kaiser', 'kaiser-bessel'}
        % === Kaiser-Bessel window =======================================
        % Approximation of the slepian window using modified bessel
        % function of zeroth order
        beta = conf.nfchoa.modal_window_parameter * pi;
        win = besseli(0,beta*sqrt(1-((-order:order)./order).^2)) ./ ...
              besseli(0,beta);
    otherwise
        error('%s: unknown weighting type (%s)!',upper(mfilename),wtype);
end

% Inverse DTFT
if nargout>1
    Win = ifft([win(order+1:end),zeros(1,order)],ndtft,'symmetric');
end
% Axis corresponding to inverse DTFT
if nargout>2
    Nphi = length(Win);
    Phi = 0:2*pi / Nphi:2*pi*(1-1/Nphi);
end
