function H = simple_shaded_error_bars(x, y, errBar, lineProps, transparent, plotAxes)
% SIMPLE_SHADED_ERROR_BARS Plots a line with shaded error bars.
%
%   Christina Delta - May 2025
%
%   H = simple_shaded_error_bars(x, y, errBar, lineProps, transparent, plotAxes)
%
% Inputs:
%   x - x data (row vector)
%   y - y data (row vector)
%   errBar - error bar values (row vector for symmetric errors, or 2xN for asymmetric)
%   lineProps - line properties for the main line (string or cell array, default '-k')
%   transparent - use transparency for the patch (logical, default true)
%   plotAxes - axes to plot on (default gca)
%
% Outputs:
%   H - structure with handles to mainLine, patch, and edge lines

% Example code to call the function:
%
% x = 1:10;
% y = sin(x);
% err = 0.1 * ones(size(x));
% simple_shaded_error_bars(x, y, err, '-b', true);

%% 

% Default values
if nargin < 4, lineProps    = '-k'; end
if nargin < 5, transparent  = true; end
if nargin < 6, plotAxes     = gca; end

% Ensure x and y are row vectors
x       = x(:).';
y       = y(:).';

% If lineProps is not a cell, make it a cell
if ~iscell(lineProps), lineProps = {lineProps}; end

% If errBar is a single row, duplicate for upper and lower
if size(errBar,1) == 1
    errBar = [errBar; errBar];
end

% Check lengths
if length(x) ~= length(y) || length(x) ~= size(errBar,2)
    error('x, y, and errBar must have the same number of elements')
end

% Calculate upper and lower error lines
uE = y + errBar(1,:);
lE = y - errBar(2,:);

% Prepare patch coordinates
yP = [lE, fliplr(uE)];
xP = [x, fliplr(x)];

% Remove NaNs
valid = ~isnan(yP);
xP = xP(valid);
yP = yP(valid);

% Check if axes is held
initialHold = ishold(plotAxes);
if ~initialHold
    cla(plotAxes, 'reset')
end
hold(plotAxes, 'on')

% Plot the main line
H.mainLine      = plot(plotAxes, x, y, lineProps{:});

% Get main line color
mainColor       = get(H.mainLine, 'Color');

% Determine patch color and alpha
if transparent
    patchColor  = mainColor;
    faceAlpha   = 0.2;
else
    patchColor = mainColor * 0.5 + 0.5;
    faceAlpha   = 1;
end

% Determine edge color
edgeColor       = mainColor * 0.55 + 0.45;

% Plot the patch
H.patch         = patch(xP, yP, patchColor, 'EdgeColor', 'none', 'FaceAlpha', faceAlpha, 'Parent', plotAxes);

% Plot the edges
H.edge(1)       = plot(plotAxes, x, lE, '-', 'Color', edgeColor);
H.edge(2)       = plot(plotAxes, x, uE, '-', 'Color', edgeColor);

% Set handle visibility off for patch and edges
set(H.patch, 'HandleVisibility', 'off')
set(H.edge, 'HandleVisibility', 'off')

% Bring main line to front
uistack(H.mainLine, 'top')

% Restore hold status
if ~initialHold
    hold(plotAxes, 'off')
end
end
