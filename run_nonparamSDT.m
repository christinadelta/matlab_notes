function [A, B] = run_nonparamSDT(hit, fa)

% Non-parametric measures of Signal Detection Theory

% Implementation of the formula to calculate non-parametric indices A' & B"
% as suggested by Snodgrass & Corwin (1988).

% Created: Nov 2020
% ChristinaDelta (christina.delta.k@gmail.com)

% ----

% Input:
% hit = proportion of hits
% fa = proportion of false alarms

% Output:
% Non-parametric measures A' & B"

% average 
pHit    = mean(hit);
pFA     = mean(fa);


if size(pHit,2) == 1 % if the inputs are n by 1 arrays
    
    if pHit >= pFA
    
        A = 0.5 + ((pHit - pFA) * (1 + pHit - pFA)) / (4 * pHit * (1 - pFA));
    
    else
    
        A = 0.5 - ((pFA - pHit) * (1 + pFA - pHit)) / (4 * pFA * (1 - pHit));
    
    end
    
    B = (pHit * (1 - pHit) - pFA * (1 - pFA)) / (pHit * (1 - pHit) + pFA * (1 - pFA));
    
else % if the imput are n by k matrices 
    
    if pHit >= pFA
    
        A = 0.5 + ((pHit - pFA).* (1 + pHit - pFA)) / (4.* pHit.* (1 - pFA));
    
    else
    
        A = 0.5 - ((pFA - pHit).* (1 + pFA - pHit)) / (4.* pFA.* (1 - pHit));
    
    end
    
    B = (pHit.* (1 - pHit) - pFA.* (1 - pFA)) / (pHit.* (1 - pHit) + pFA.* (1 - pFA));
    
    
end % end of outer if statement
    
end