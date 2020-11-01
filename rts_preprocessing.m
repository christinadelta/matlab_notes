% PRE-PROCESS REACTION TIMES DATA FROM A MAT FILE

% a few paths and variables
startpath   = pwd; % home dir
task        = 'rts';
taskpath    = 'github_personal_repos'; 
taskname    = 'rts_practice_data';
session     = 1;
trials      = 144;
runs        = 10;

categories  = 8;
animate     = 2;
previousrts = 0;

allrtdata   = [];

% find subjects dir
subs        = dir(fullfile(startpath,taskpath,taskname, '*sub*'));
nbsubjects  = length(subs); % number of subjects 

% only keep the subject number
rtsubs = {subs.name};

% loop over subjects to read the mat files 
for sub = 1:nbsubjects
    
    subject = subs(sub).name;

    subdir = fullfile(startpath, taskpath, taskname, subject);

    fprintf('\t reading data from subject %d\n',sub); 
    
    
    for run = 1:runs
        
        subFile = fullfile(subdir, sprintf('%s_task-%s_ses-%02d_run-%02d_params.mat',subject, task, session, run));
        load(subFile)
        
        % loop over trials
        for trial = 1:trials
            
            trial_index = ((run - 1)*trials) + trial;
            
            % find trials with more than 1 rt and keep the 2nd 
            [m,n] = size(params.trials(trial).rt);
            
            if n > 1
                
                rt(trial_index) = params.trials(trial).rt(2);
                
            else 
                rt(trial_index) = params.trials(trial).rt;
                
            end
            
            trialno(trial_index) = params.trials(trial).trialnumber;
            animacy(trial_index) = params.trials(trial).condition;
            category(trial_index) = params.trials(trial).imcategory;
            item(trial_index) = params.trials(trial).imshown;
            correct(trial_index) = params.trials(trial).correct;
            answer(trial_index) = params.trials(trial).answer;
            
        end % end of trials loop
        
    end % end of run loop
    
    rtdata = [item' animacy' category' rt' answer' correct'];
    
    % how many images?
    items = length(unique(rtdata(:,1)));
    
    % sort trials relative to images from 1-48
    for i = 1:items
        
        thistrial           = rtdata(:,1) == i;
        thistrialrt         = rtdata(thistrial,4);
        thistrialanimate    = rtdata(thistrial,2);
        thistrialcat        = rtdata(thistrial,3);
        thistrialresp       = rtdata(thistrial,5);
        thistrialcorrect    = rtdata(thistrial,6);
        
        rts_total           = length(thistrialrt);
        
        if previousrts < rts_total
            
            previousrts     = rts_total;
        end
        
        alldata = [repmat(sub, [rts_total,1]), repmat(i, [rts_total,1]), thistrialanimate, thistrialcat, thistrialrt, thistrialresp, thistrialcorrect];
        
        allrtdata = cat(1, allrtdata, alldata);
        
    end
        
    
end % end of subjects loop

% remove rts less than 0.2
allrtdata(allrtdata(:,5) < 0.2, :)      = [];

% % remove rows with nan rts
allrtdata(any(isnan(allrtdata), 2), :)  = [];

% % save matrix in csv format for r and python
csvwrite('allrt_data.csv', allrtdata)


