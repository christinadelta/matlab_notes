% Simple script to run signal detection on reaction times data of animate
% and animate-like (inanimate data)

% Nov 2019 
% Updated: Oct 2020
% Last update : Nov 2020
% Author: ChristinaDelta (christina.delta.k@gmail.com)

% -----------

% In 2AFC psychophysics experiments, data can be interpreted according to
% signal detection theory (SDT). Participants' responses are coded as hits,
% false alarms, misses and correct rejections.
% The indices of Signal detection are:
% 1. Sensitivity index (d-prime or d')
% 2. Subject bias (β)
% 3. Criterion (c)

% We can also calculate A' and B", the non-parametric indices of d' and c 

% ------------

% Load and pre- process the practice reaction-times data

% 48 stimuli (24 animate and 24 inanimate) 
% this set consists of 24 animate objects (e.g. humans and animals) and 24
% corresponding objects that look like animates (e.g. a rope that looks
% like a snake).
% Every stimulus was presented 20 times in a total of 10 runs.
% Number of subjects: 12

% Hits                  = animates correct responses
% Misses                = animates incorrect responses
% Correct Rejections    = inanimates correct responses
% False alarms          = inanimates incorrect responses

%%%% ------ Define a few parameters 

% a few paths and variables
startpath   = pwd; % home dir
task        = 'rts';
taskpath    = 'github_personal_repos'; 
taskname    = 'rts_practice_data';
session     = 1;
trials      = 96;
runs        = 10;

% find subjects dir
subs        = dir(fullfile(startpath,taskpath,taskname, '*sub*'));
nbsubjects  = length(subs); % number of subjects 
subjects    = 1:nbsubjects;

% Loop over subjects to load raw data
for sub = 1:nbsubjects
    
    subject = subs(sub).name;

    subdir  = fullfile(startpath, taskpath, taskname, subject);

    fprintf('\t reading data from subject %d\n',sub); 
    
    
    for run = 1:runs
        
        subFile = fullfile(subdir, sprintf('%s_task-%s_sess-%02d_block-%02d_data.mat',subject, task, session, run));
        load(subFile)
        
        % loop over trials
        for trial = 1:trials
            
            trial_index         = ((run - 1)*trials) + trial;
            
            % find trials with more than 1 rt and keep the 2nd 
            [m,n]               = size(params.trials(trial).rt);
            
            if n > 1
                
                rt(trial_index) = params.trials(trial).rt(2);
                
            else 
                rt(trial_index) = params.trials(trial).rt;
                
            end
            
            trialno(trial_index)    = params.trials(trial).trialnumber;
            animacy(trial_index)    = params.trials(trial).condition;
            item(trial_index)       = params.trials(trial).imshown;
            correct(trial_index)    = params.trials(trial).correct;
            answer(trial_index)     = params.trials(trial).answer;
            
            
        end % end of trials loop
        
    end % end of run loop
    
    rtdata = [trialno' item' animacy' rt' answer' correct'];
    
    % % remove rows with nan rts
    rtdata(any(isnan(rtdata), 2), :)  = [];
    
    % how many images?
    items = length(unique(rtdata(:,2)));
    
    
    %%% ------ find hits, misses, correct rejections and false alarms
    hits    = zeros(1, items/2);
    misses  = zeros(1, items/2);
    cr      = zeros(1, items/2);
    fa      = zeros(1, items/2);
    
    % FIRST CALCULATE HITS AND MISSES
    
    for i = 1: items/2
        
       
        thisindex           = i + items/2;                          % find trials of the currect item
        thisitem            = rtdata(:,2) == thisindex;
        
        % 1. HITS 
        trials_correct      = rtdata(:,6) == 1;                     % find all the correct trials
        animate_trials      = rtdata(:,3) == 1;                     % find animate trials 
        hit_trials          = animate_trials & trials_correct;      % find animate correct trials (all hit trials)
        thisitem_hits       = thisitem & hit_trials;                % find hit trials of the current item 
        hits(i)             = sum(thisitem_hits) / sum(thisitem);   % sum hits
        
        % 2. MISSES
        trials_incorrect    = rtdata(:,6) == 0;                     % find all the incorrect trials 
        miss_trials         = animate_trials & trials_incorrect;    % find animate incorrect trials (misses)
        thisitem_miss       = thisitem & miss_trials;               % find miss trials of the current item
        misses(i)           = sum(thisitem_miss) / sum(thisitem);   % sum up miss trials
        
    end % end of hits & misses loop
    
    clear thisitem i
    
    % CALCULATE FALSE ALARMS (FAs) & CORRECT REJECTIONS (CRs)
    for i = 1: items/2
        
        
        thisitem            = rtdata(:,2) == i; % find trials of the current item
        
        % 3. CORRECT REJECTIONS  
        trials_correct      = rtdata(:,6) == 1;                     % find all the correct trials
        inanimate_trials    = rtdata(:,3) == 2;                     % find inanimate trials 
        cr_trials           = inanimate_trials & trials_correct;    % find inanimate correct trials (all cr trials)
        thisitem_cr         = thisitem & cr_trials;                 % find cr trials of the current item 
        cr(i)               = sum(thisitem_cr) / sum(thisitem);     % sum correct rejections (crs)
        
         % 4. FALSE ALARMS
        trials_incorrect    = rtdata(:,6) == 0;                     % find all the incorrect trials 
        fa_trials           = inanimate_trials & trials_incorrect;  % find inanimate incorrect trials (all fa trials)
        thisitem_fa         = thisitem & fa_trials;                 % find fa trials of the current item 
        fa(i)               = sum(thisitem_fa) / sum(thisitem); 	% sum false alarms (fas)
        
  
    end % end of hits & misses loop
    
    % gather the data 
    allhits(:, sub)         = hits;
    allmisses(:, sub)       = misses;
    allcr(:,sub)            = cr;
    allfa(:, sub)           = fa;
    
end % end of subjects loop


% average hits, misses, crs and fas across items at the subject level (this
% will give means for each subject)
pHit        = mean(allhits);
pMiss       = mean(allmisses);
pFA         = mean(allfa);
pCR         = mean(allcr);

% convert to z scores
zHit        = -sqrt(2).* erfcinv(2 * pHit);
zMiss       = -sqrt(2).* erfcinv(2 * pMiss);
zFA         = -sqrt(2).* erfcinv(2 * pFA);
zCR         = -sqrt(2).* erfcinv(2 * pCR);

% calculate d'
dprime      = zHit - zFA;

% calculate subject's bias (β craterion)
bcriterion  = exp(zHit.^2 - zFA.^2/2);

% bcriterion = exp((norminv(pHit).^2 - norminv(pFA).^2/2)); this is another
% way of calculating bias

% calculate c criterion 
ccriterion  = (zHit - zFA)/2;

