function s = RandUnequalConditions(v,n,a)

% ChristinaDelta (christina.delta.k@gmail.com)
% Dec 2020

% INPUT ARGUMENTS:
% v = kby1 vector of values (e.g. ones and twos)
% n = size of batches of the v vector (n is a number)
% a = the value of the condition that we want to distribute in the batches

% OUTPUT ARGUMENTS:
% s = randomized vector 

% The function takes a vector of values (e.i. 1 & 2) that correspond to two
% conditions of unequal sizes. 

% EXAMPLE:
% Condition 1 may have 50 entries in the vector and Condition 2 20 entries.
% The function returns a randomized vector [s] of the  input vector (v) in which
% Condition 2 (a) appears in the vector at least once every (n) times. 

% if we run:
% s = RandUnequalConditions(trialvector,batchsize,cond2)

% trialvec = (70,1) vector
% batchsize = 10
% cond2 = 2

% the function rundomizes trialvec and it splits it in 10 batches of 7
% entries. Each batch of entries contains cond2 at least one time.

l = length(v);

randv_found = 0;
count = 0;

tic
while not(randv_found)
    
    randomize = randperm(l); % randomize 
    randvec = v(randomize);
    
    count = count + 1; % counter for printing
    
    % split randvec in (l/n) batches 
    for i = 1:ceil(l/n)
    
        batches{i} = randvec((i-1)*n+1 : min(l, i*n));
    
    end
    
    % test the above batches. test will return either 1 or zero for each
    % batch
    test = zeros(1,length(batches)); 
    
    for k = 1:length(batches)
        
        b = batches{k};
        test(k) = any(ismember(b, a)); % returns 1 when the batch contains a
        
    end
    
    t = not(any(ismember(test,0))); % if no batch contains a returns zero
    
    if t
        randv_found = 1;
        
        
    end
    
end

s = v(randomize);

toc

fprintf('needed %d attempts to find an optimal randomization for vector v\n', count);


end