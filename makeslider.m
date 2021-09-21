
% Add PTB to your path and start the experiment 
ptbdir          = '/Applications/Psychtoolbox';                             % change to your ptb directory
addpath(genpath(ptbdir))

scrn.ptbdir     = ptbdir;

% start the code for the slider
try
    
    % define colours
    scrn.black      = [0 0 0];
    scrn.white      = [255 255 255];
    scrn.grey       = [128 128 128];
    scrn.green      = [0 140 54];
    scrn.blue       = [30 70 155];
    scrn.red        = [225 25 0];

    % text settings
    scrn.textfont       = 'Verdana';
    scrn.textsize       = 20;
    scrn.smalltext      = 15;
    scrn.fixationsize   = 30;
    scrn.textbold       = 1; 
    
    % Screen('Preference', 'SkipSyncTests', 0) % set a Psychtoolbox global preference.
    Screen('Preference', 'SkipSyncTests', 1) % for testing I have set this to 1. When running the actuall task uncomment the above

    screenNumber            = max(Screen('Screens'));
    
    [window, windrect]      = Screen('OpenWindow', screenNumber, scrn.grey); % open window
    
    AssertOpenGL;                                                           % Break and issue an error message if PTB is not based on OpenGL or Screen() is not working properly.
    Screen('Preference', 'Enable3DGraphics', 1);                            % enable 3d graphics
    Screen('BlendFunction', window, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);   % Turn on blendfunction for for the screen
    priorityLevel = MaxPriority(window);                                    % query the maximum priority level
    Priority(priorityLevel);
    HideCursor;
    
    [xcenter, ycenter]      = RectCenter(windrect);                         % get the centre coordinate of the window in pixels
    [xpixels, ypixels]      = Screen('WindowSize', window);                 % size of the on-screen window in pixels

    
    % pc actual screen settings
    scrn.actscreen          = Screen('Resolution', screenNumber);
    [actwidth, actheight]   = Screen('DisplaySize', screenNumber);
    scrn.acthz              = Screen('FrameRate', window, screenNumber);    % maximum speed at which you can flip the screen buffers, we normally use the flip interval (ifi), but better store it 
    
    scrn.ifi                = Screen('GetFlipInterval', window);            % frame duration, inverse of frame rate, returns the duration of the frame in miliseconds
    
    scrn.slack              = Screen('GetFlipInterval', window)/2;          % Returns an estimate of the monitor flip interval for the specified onscreen window (this is frame duration /2)
    
    scrn.frame_rate         = 1/scrn.ifi;
    scrn.actwidth           = actwidth;
    scrn.actheight          = actheight;
    scrn.window             = window;
    scrn.windrect           = windrect;
    scrn.xcenter            = xcenter;
    scrn.ycenter            = ycenter;
    scrn.xpixels            = xpixels;
    scrn.ypixels            = ypixels;
    
    % start and end of the scale
    endpoints       = {'1', '100'};
    anchors         = {'0', '50', '100'};
    center          = round([windrect(3) windrect(4)]/2);
    line            = 10;
    width           = 3;
    scalelength     = 0.9; % will change this?
    scalepos        = 0.8; % scale position (0 =top, 1=bottom, and in between)
    scalecolour     = scrn.white;
    slidercolour    = scrn.black;
    device          = 'mouse';
    startposition   = 'left';
    maxtime         = 20; % in seconds
    stepsize        = 1;
    rangetype       = 1;
    displaypos      = 1;
    mousebutton     = 1; 
    fixation        = '+';
    
    globalrect      = Screen('Rect', screenNumber);
    
    % create fixation cross offscreen and paste later (faster)
    fixationdisplay = Screen('OpenOffscreenWindow',window);
    Screen('FillRect', fixationdisplay, scrn.grey);
    Screen('TextFont',fixationdisplay, scrn.textfont);
    Screen('TextSize',fixationdisplay, scrn.fixationsize);
    DrawFormattedText(fixationdisplay, fixation, 'center', ycenter, scrn.white);
    
    % calculate coordinates of scale line and text bounds
    if strcmp(startposition, 'left')
        x = globalrect(3)*(1-scalelength);
    elseif strcmp(startposition, 'center')
        x = globalrect(3)/2;
    elseif strcmp(startposition, 'right')
        x = globalrect(3)*scalelength;
    end
    
    % this goes to the run funtion
    SetMouse(round(x), round(windrect(4)*scalepos), window, 1)
    
    midclick    = [center(1) windrect(4)*scalepos - line - 5 center(1), windrect(4)*scalepos + line + 5];
    leftclick   = [windrect(3)*(1-scalelength) windrect(4)*scalepos - line windrect(3)*(1-scalelength) windrect(4)*scalepos + line];
    rightclick  = [windrect(3)*(scalelength) windrect(4)*scalepos - line windrect(3)*(scalelength) windrect(4)*scalepos + line];
    horzline    = [windrect(3)*scalelength windrect(4)*scalepos windrect(3)*(1-scalelength) windrect(4)*scalepos];
    
    % Calculate the range of the scale, which will be need to calculate the
    % position
    scalerange        = round(windrect(3)*(1-scalelength)):round(windrect(3)*scalelength); % Calculates the range of the scale
    scalerangeshifted = round((scalerange)-mean(scalerange)); % Shift the range of scale so it is symmetrical around zero
    
    % display fixation
    Screen('CopyWindow', fixationdisplay,window, windrect, windrect)
    fliptime    = Screen('Flip', window); % flip fixation window
    trialstart  = fliptime;
    
    % object offset
    object_offset   = trialstart + 0.7 - scrn.ifi;
    
    t0                         = GetSecs;
    respmade                   = 0;
    
    textBounds = [Screen('TextBounds', window, sprintf(anchors{1})); Screen('TextBounds', window, sprintf(anchors{3}))];
    
    % Now we need two mouse clicks (in two while loops). During the first
    % mouse click, we just show the scale (0 to 100) and allow subject to
    % press the mouse the first time 
    
    while respmade == 0 && (GetSecs - trialstart) < maxtime
        
        [x,~,buttons,~,~,~] = GetMouse(window, 1);
        
        % Stop at upper and lower bound
        if x > windrect(3)*scalelength
            x = windrect(3)*scalelength;
        elseif x < windrect(3)*(1-scalelength)
            x = windrect(3)*(1-scalelength);
        end
    
        % draw the question
        Screen('TextSize', window, scrn.textsize);
        Screen('FillRect', window, scrn.grey ,windrect);
        DrawFormattedText(window,'Please test the slider','center',scrn.ycenter,scrn.white);

        % Left, middle and right anchors
        DrawFormattedText(window, anchors{1}, leftclick(1, 1) - textBounds(1, 3)/2,  windrect(4)*scalepos+40, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(window, anchors{2}, 'center',  windrect(4)*scalepos+40, [],[],[],[],[],[],[]); % Middle point
        DrawFormattedText(window, anchors{3}, rightclick(1, 1) - textBounds(2, 3)/2,  windrect(4)*scalepos+40, [],[],[],[],[],[],[]); % Right point

         % Drawing the scale
        Screen('DrawLine', window, scalecolour, midclick(1), midclick(2), midclick(3), midclick(4), width);         % Mid tick
        Screen('DrawLine', window, scalecolour, leftclick(1), leftclick(2), leftclick(3), leftclick(4), width);     % Left tick
        Screen('DrawLine', window, scalecolour, rightclick(1), rightclick(2), rightclick(3), rightclick(4), width); % Right tick
        Screen('DrawLine', window, scalecolour, horzline(1), horzline(2), horzline(3), horzline(4), width);     % Horizontal line 

        object_onset = Screen('Flip', window, object_offset - scrn.slack); % flip the screen 

        % wait for second response 
        secs = GetSecs;
        if buttons(mousebutton) == 1
            respmade = 1;
        end
        
        % Abort if answer takes too long
        if secs - t0 > maxtime 
            break
        end
 
    end
    
    KbReleaseWait; %Keyboard
    WaitSecs(0.1) % % delay to prevent CPU logging
 
    % after the first mouse press we add the slider (which should start on
    % the left side of the scale/bar) and allow them to adjust the slider
    % and press the mouse click again 
    
    t0                         = GetSecs;
    answer                     = 0;
    
    while answer == 0 && (GetSecs - object_onset) < maxtime
        
        [x,~,buttons,~,~,~] = GetMouse(window, 1);
        
        % Stop at upper and lower bound
        if x > windrect(3)*scalelength
            x = windrect(3)*scalelength;
        elseif x < windrect(3)*(1-scalelength)
            x = windrect(3)*(1-scalelength);
        end
    
        % draw the question
        Screen('TextSize', window, scrn.textsize);
        Screen('FillRect', window, scrn.grey ,windrect);
        DrawFormattedText(window,'Please rate how confident you are','center',scrn.ycenter,scrn.white);

        % Left, middle and right anchors
        DrawFormattedText(window, anchors{1}, leftclick(1, 1) - textBounds(1, 3)/2,  windrect(4)*scalepos+40, [],[],[],[],[],[],[]); % Left point
        DrawFormattedText(window, anchors{2}, 'center',  windrect(4)*scalepos+40, [],[],[],[],[],[],[]); % Middle point
        DrawFormattedText(window, anchors{3}, rightclick(1, 1) - textBounds(2, 3)/2,  windrect(4)*scalepos+40, [],[],[],[],[],[],[]); % Right point

         % Drawing the scale
        Screen('DrawLine', window, scalecolour, midclick(1), midclick(2), midclick(3), midclick(4), width);         % Mid tick
        Screen('DrawLine', window, scalecolour, leftclick(1), leftclick(2), leftclick(3), leftclick(4), width);     % Left tick
        Screen('DrawLine', window, scalecolour, rightclick(1), rightclick(2), rightclick(3), rightclick(4), width); % Right tick
        Screen('DrawLine', window, scalecolour, horzline(1), horzline(2), horzline(3), horzline(4), width);     % Horizontal line
        
         % The slider
        Screen('DrawLine', window, slidercolour, x, windrect(4)*scalepos - line, x, windrect(4)*scalepos  + line, width);

        position = round((x)-min(scalerange));                       % Calculates the deviation from 0. 
        position = (position/(max(scalerange)-min(scalerange)))*100; % Converts the value to percentage

        DrawFormattedText(window, num2str(round(position)), 'center', windrect(4)*(scalepos - 0.05), scrn.white); 

        object_onset = Screen('Flip', window, object_offset - scrn.slack); % flip the screen 

        % wait for second response 
        secs = GetSecs;
        if buttons(mousebutton) == 1
            answer = 1;
        end

        rt                = (secs - t0);    
    end
    
    object_offset   = secs + 0.4 - scrn.ifi;
    
    KbReleaseWait; %Keyboard
    
    % clean up at the end of the experiment
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    fclose('all');
    
catch 
    
    Screen('CloseAll');
    ShowCursor;
    Priority(0);
    psychrethrow(psychlasterror);
    
end
