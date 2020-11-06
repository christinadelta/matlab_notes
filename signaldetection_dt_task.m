 % signal detection ---- Same/ Different judgements task (discriminability task) ------
 % August 2019
 % Matlab version 2019a
 
 
 % trial conditions: 
 % - same objects trials (false alarms & correct rejections)
 % - different objects trials (hits & misses)
 
 % HITS: diffrent objects trial -- correct response
 % FALSE ALARMS: same objects trial -- incorrect response (subject pressed "diffrent")
 % CORRECT REJECTIONS: same object trials -- correct response
 % MISSES: different objects trials -- incorrect response (subject pressed
 % "same")
 
 % number of different trials and number of same trials can be used to
 % correct for perfect ones and zeros
 % by using the "1/2n rule" (Stanislaw & Todorov, 1999)
 % - nTargets = number of different objects trials
 % - nDistractors = number of same objects trials

 % ---------------------------------------------------------------------------
 
 % get paths etc
 
startpath               = pwd; % home dir
taskpath                = 'github_personal_repos'; 
taskname                = 'dt_practice_data';
task                    = 'discriminability_task';
session                 = 1; 
ntrials                 = 154;
nruns                   = 54;

% subject dir
subjects                = dir(fullfile(startpath,taskpath,taskname, '*sub*'));
nsubjects               = length(subjects);

% only keep the sub name 
subname                 = {subjects.name};

for subI = 1:nsubjects
    
    fprintf('loading dt data\n');
    
    subj        = subjects(subI).name;
    
    subdir      = fullfile(dt_data_path, subj);
    
    fprintf('\t reading data from subject %d\n', subI);
    
    ses_files   = dir(fullfile(subdir,'*ses-*.mat'));
    
    n_runs      = length(ses_files);
    
    for runI = 1:n_runs
        
        fprintf('\t\t loading run %d\n\n', runI);
        
        subjectfile = fullfile(subdir, ses_files(runI).name);
        load(subjectfile);
        
        for trial = 1:ntrials
            
            idx                 = ((runI -1) * ntrials) + trial;
            
            runNo(idx)          = params.trials(trial).runNo;
            trialNo(idx)        = params.trials(trial).trialnumber;
            imageleft(idx)      = params.trials(trial).image1;
            imageright(idx)     = params.trials(trial).image2;
            categoryleft(idx)   = params.trials(trial).category1;
            categoryright(idx)  = params.trials(trial).category2;
            animateleft(idx)    = params.trials(trial).animate1;
            animateright(idx)   = params.trials(trial).animate2;
            trialtype(idx)      = params.trials(trial).trialtype;
            paircondition(idx)  = params.trials(trial).paircondition;
            answer(idx)         = params.trials(trial).answer;
            
            % find trials with more than one rt values
            [m,n]= size(params.trials(trial).rt);
            if n > 1
                continue
            end
            
            rt(idx)             = params.trials(trial).rt;
            correct(idx)        = params.trials(trial).correct;
            
        end % end of trial loop
        
        
    end % end of run loop
    
    % keep the information that we need for the analysis
    datamatrix              = [trialNo' imageleft' imageright' categoryleft' categoryright' animateleft' animateright' trialtype' paircondition' answer' rt' correct'];
    
    data_len                = length(datamatrix);
    % sum across rows
    rowsum                  = sum(datamatrix,2);
    
    % find rows of NaNs and remove them
    emptyrows               = rowsum == 0;
    
    datamatrix(emptyrows,:) = [];
    
    % extract image pairs
    images                  = unique(datamatrix(:,2));
    combinations            = nchoosek(images,2);
    sameobjectpairs         = cat(2, images, images);
    all_combinations        = [combinations; sameobjectpairs];
    ndifferent_combs        = length(combinations);
    nsame_combs             = length(sameobjectpairs);
    all_combs               = length(all_combinations);
    
    
    pairs                   = datamatrix(:,[2 3]);
    total_ntrials           = size(datamatrix,1);
    ntargets                = ndifferent_combs * 10; % total number of differnt objects trials
    ndistractors            = ntargets * 0.32; % total number of same objects trials
    
    % From now on the correct responses will be called "hits" and "correct
    % rejections". The incorrect responses will be called "false alarms" and
    % "misses".
    
    hits                    = zeros(1,ndifferent_combs);
    misses                  = zeros(1,ndifferent_combs);
    falsealarms             = zeros(1,nsame_combs);
    correctrejections       = zeros(1,nsame_combs);
    
    
    % --------------------------------------------------------------------------
    
    % first start with different objects trials
    % find trials that presented that image combination
    for combI = 1: ndifferent_combs
        
        
        
        currentPair                        = combinations(combI,:);
        
        % find the indices in pairs
        % case 1: this below is when item 1 was on left and item 2 on right
        pair1itemsL                        = pairs(:,1) == currentPair(1);
        pair2itemsR                        = pairs(:,2) == currentPair(2);
        
        % case 2: item 1 was on the right and item 2 on the left
        pair1itemsR                        = pairs(:,1) == currentPair(2);
        pair2itemsL                        = pairs(:,2) == currentPair(1);
        
        % let's find case 1 and case 2 trials
        case1                              = pair1itemsL & pair2itemsR;
        case2                              = pair1itemsR & pair2itemsL;
        
        % find trials that presented this pair
        this_pair_trials                   = case1 | case2;
        
        % ----------------------------------------------------------------------
        
        % 1. HITS
        
        % filter out incorrect trials (misses and FAs)
        all_correct                        = datamatrix(:,12) == 1;
        
        % keep only different object trials to find hits and misses
        different_trials                   = datamatrix(:,9) == 2;
        
        hit_trials                         = different_trials & all_correct;
        
        % find correct trials of this "diffrent objects" pair
        thispair_hits                      = this_pair_trials & hit_trials;
        
        % sum up hits
        hits(combI)                        = sum(thispair_hits) / sum(this_pair_trials);
        
        % 2. MISSES
        
        % filter out the correct trials (hits & correct rejections)
        all_incorrect                      = datamatrix(:,12) == 0;
        
        % keep only incorrect different object trials
        miss_trials                        = different_trials & all_incorrect;
        
        % find incorrect trials of this "diffrent objects" pair
        thispair_misses                    = this_pair_trials & miss_trials;
        
        % sum up misses
        misses(combI)                      = sum(thispair_misses) / sum(this_pair_trials);
        
        
    end % end of ndifferent_combs loop
    
    % --------------------------------------------------------------------------------------
    
    % now deal with the same object trials 
    % find trials that presented that image combination
    for comb = 1: nsame_combs
        
        currentPair                        = sameobjectpairs(comb,:);
        
        % find the indices in pairs
        pair1itemsL                        = pairs(:,1) == currentPair(1);
        pair2itemsR                        = pairs(:,2) == currentPair(2);
        
        % find trials that presented this pair
        this_samepair                      = pair1itemsL & pair2itemsR;
        
        % ------------------------------------------------------------------------
        
        % 3. FALSE ALARMS 
        
        % keep only same object trials to find correct rejections and false
        % alarms
        same_trials                   = datamatrix(:,9) == 1;
        
        fa_trials                     = same_trials & all_incorrect;
        
        % find false alram trials of this "same objects" pair
        thispair_fa                   = this_samepair & fa_trials;
        
        % sum up false alarms
        falsealarms(comb)             = sum(thispair_fa) / sum(this_samepair);
        
        %  ---------------------------------------------------------------------
        
        % 4. CORRECT REJECTIONS 
        
        % find only correct rejections (same objects trial and subject
        % pressed 1)
        cr_trials                     = same_trials & all_correct;
        
        % find correct rejection trials of this "same objects" pair
        thispair_cr                   = this_samepair & cr_trials;
        
        % sum up false alarms
        correctrejections(comb)       = sum(thispair_cr) / sum(this_samepair);
        
        
    end % end of nsame_combs loop
    
    % ------------------------------------------------------------------------
    
    allhits(:, subI)                       = hits;
    
    allmisses(:, subI)                     = misses;
    
    allfalsealarms(:, subI)                = falsealarms;
    
    allcorrectrejections(:, subI)          = correctrejections;
    
end % end of subject loop

% -----------------------------------------------------------------------------

% Calculate d-prime and c criterion

% correct hits and false alarms for perfect 1 or perfect 0 if needed using
% nTargets and nDistractors


% mean value of hits, misses, FAs, and CRs
pHit        = mean(allhits);

pMiss       = mean(allmisses);

pFA         = mean(allfalsealarms);

pCR         = mean(allcorrectrejections);

% % convert to z scores
zHit        = -sqrt(2).* erfcinv(2 * pHit);

zMiss       = -sqrt(2).* erfcinv(2 * pMiss);

zFA         = -sqrt(2).* erfcinv(2 * pFA);

zCR         = -sqrt(2).* erfcinv(2 * pCR);

% calculate d-prime
dprime      = zHit - zFA;


% calculate c criterion
ccriterion  = (zHit + zFA)/2;

% visualize













