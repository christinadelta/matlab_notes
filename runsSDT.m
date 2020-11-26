function [b, c, d] = runsSDT(hit, fa)

% a simple function that calculates the parametric indices of the Signal
% Detection Theory (SDT) 

% ChristinaDelta (christina.delta.k@gmail.com)

% Created: July 2020
% Last updated: Nov 2020

% --------

% INPUT PARAMETERS
% hit = the proportion of correct responses for one of two conditions
% (e.g. proportion of correct responses for the true presense of signal)

% fa = the proportion of incorrect responses for the second of two conditions
% (e.g. proportion of incorrect responses for the true absense of signal)

% the two inputs can either be: 
% 1. matrices (e.g. n by k matrices where n =
% proportion of correct or incorrect responses for each of the stimuli -if
% presented multiple times- and k = subjects)
% 2. n by 1 array (e.g. averaged across subjects)

% average 
pHit    = mean(hit);
pFA     = mean(fa);

% check whether the inputs are matrcices or nby1 arrays 
if size(pHit,2) == 1
    
    % calculate z scores 
    zHit    = -sqrt(2) * erfcinv(2 * pHit); % z score for hits
    zFA     = -sqrt(2) * erfcinv(2 * pFA);  % z score for false alarms
    b       = exp(zHit^2 - zFA^2/2);        % calculate subject's bias (β criterion)
    
else
    
    % convert to z scores
    zHit    = -sqrt(2).* erfcinv(2 * pHit); % z score for hits
    zFA     = -sqrt(2).* erfcinv(2 * pFA);  % z score for false alarms
    b       = exp(zHit.^2 - zFA.^2/2);      % calculate subject's bias (β criterion)
    
end

c = (zHit - zFA)/2; % calculate c criterion 
d = zHit - zFA;     % calculate d'

end