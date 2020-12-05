function batches = makebatches(v,n)

% ChristinaDelta (christina.delta.k@gmail.com)
% Dec 2020

% returns a v/n cell of batches

%%% INPUTS
% v = kby1 vector of data
% n = number (i.e. size of each batch)

%%% OUTPUTS:
% cell of batches of the v vector

% NOTE: last batches will probably have smaller batch sizes unless the
% division of v/n returns an integer

l = length(v);

for i = 1:ceil(l/n)
    
    batches{i} = v((i-1)*n+1 : min(l, i*n));
    
end


end