clear all
close all

%% Setup
demog = inputdlg({... % Get demographic info
    'Participant Number', ...
    'Condition', ...
    'Age', ...
    'Gender' ...
    });
pName = demog{1}; % Extract participant name

% Define go/no go proportions
baseprop = [0.5 0.8 0.875 0.875 0.8]; % Base proportions of go/no go
switch demog{2}
    case '0' % If they chose the "mostly nogo" condition
        goprop = 1-baseprop;% Proportion of trials in each block which are "go"
        noprop = baseprop; % Proportion of trials in each block which are "no go"
    case '1' % If they chose the "mostly go" condition
        goprop = baseprop;% Proportion of trials in each block which are "go"
        noprop = 1-baseprop; % Proportion of trials in each block which are "no go"
    otherwise
        error('Invalid condition. Please select either 0 (mostly nogo) or one (mostly go)');
end

% Initialise block structure
blocks = struct( ... % For each block, define...
    'num', {0 1 2 3 4}, ... % Block numbe
    'noTrials', {10 53 53 53 53}, ... % Number of trials
    'goP', num2cell(goprop), ... % Proportion of go trials
    'noP', num2cell(noprop), ... % Proportion of nogo trials
    'practice', {true false false false false} ... % Whether the block is a practice block
    );

% Initialise trial table
tt = []; % Create blank trial table
for b = blocks
    condmat = [true(1, ceil(b.noTrials*b.goP)), false(1, floor(b.noTrials*b.noP))]; % Create logical matrix using proportions from b
    block = struct(... % Create structure for this block
        'block', b.num, ... % Block number
        'trial', num2cell(1:b.noTrials)', ... % Trial number
        'cond', num2cell(condmat(randperm(b.noTrials)))', ... % Matrix of ones (go trials) and zeros (nogo trials), shuffled
        'im', [], ... % Image (placeholder)
        'resp', [], ... % Participant response (placeholder)
        'rt', [] ... % Participant response time (placeholder)
    );
    tt = [tt; block]; % Append block structure to grand trial table
end


% Pre-load images
stim = struct(...
    'nogo', dir('NoGo'), ... % Read nogo stimulus folder
    'go', dir('Moles') ... % Read go stimulus folder
    );
stim.nogo( ~contains({stim.nogo.name}, '.png') ) = []; % Remove non-image files
for n = 1:length(stim.nogo) % For each nogo stimulus...
    [stim.nogo(n).img, stim.nogo(n).map, stim.nogo(n).alpha] = imread([stim.nogo(n).folder '\' stim.nogo(n).name]); % Read in corresponding image
end
stim.go( ~contains({stim.go.name}, '.png') ) = []; % Remove non-image files
for n = 1:length(stim.go)% For each go stimulus...
    [stim.go(n).img, stim.go(n).map, stim.go(n).alpha] = imread([stim.go(n).folder '\' stim.go(n).name]); % Read in corresponding image
end
[bg.img, bg.map, bg.alpha] = imread('Background.png'); % Read in background image
inst = dir('Instructions'); % Read instruction folder
inst( ~contains({inst.name}, '.png') ) = []; % Remove non-image files
for n = 1:length(inst) % For each instruction file...
    [inst(n).img, inst(n).map, inst(n).alpha] = imread([inst(n).folder '\' inst(n).name]); % Read in corresponding image
end
react(1,1).name = 'Awesome.png'; % Save filename of awesome reaction
react(1,2).name = 'Oops.png'; % Save filename of oops reaction
react(2,1).name = 'Miss.png'; % Save filename of miss reaction
react(2,2).name = 'Whack.png'; % Save filename of whack reaction
for n = [{1 1}; {1 2}; {2 1}; {2 2}]' % For each index of react
    [react(n{:}).img, react(n{:}).map, react(n{:}).alpha] = imread(['Reactions\' react(n{:}).name]); % Read in corresponding image
end

% Intialise window
sDim = get(groot, 'ScreenSize');
fig = figure(... % Create full screen figure
    'InnerPosition', sDim, ... % Fullscreen figure
    'KeyPressFcn', @keyFcn, ... % Create keypress listener
    'WindowButtonDownFcn', @clickFcn, ... % Create click listener 
    'SizeChangedFcn', @sizeFcn, ... % Function to match axis limits of fullscreen axes to figure size
    'CloseRequestFcn', @closeFcn, ... % Function to save data on close
    'UserData', struct(...
        'Key', [], ...
        'Click', [], ...
        'Store', [] ...
        ) ...
    );
ax = axes(fig, ... % Create axis within figure
    'Position', [0 0 1 1], ... % Occupy entire figure
    'XLim', sDim([1,3]), ... % X limits are width of screen in pixels
    'YLim', sDim([2,4]), ... % Y limits are height of screen in pixels
    'Color', [1 1 1], ... % Colour defined by user
    'TickLength', [0 0], ... % Remove ticks
    'Box', 'off' ... % Remove box
    );

% Show background
bg.obj = image(ax, ...
    'XData', ax.XLim, ... % Position horizontal
    'YData', ax.YLim, ... % Position vertical
    'CData', flipud(bg.img), ... % Flip upside down as y axes are backwards
    'AlphaData', flipud(bg.alpha) ... % Apply transparency
    );

% Show instructions
for n = 1:length(inst)
    inst(n).obj = image(ax, ...
        'XData', ax.XLim, ... % Position horizontal
        'YData', ax.YLim, ... % Position vertical
        'CData', flipud(inst(n).img), ... % Flip upside down as y axes are backwards
        'AlphaData', flipud(inst(n).alpha) ... % Apply transparency
        );
    fig.UserData.Key = []; % Reset key listener
    while isempty(fig.UserData.Key) % Until there is a response...
        drawnow % Continuously refresh screen
    end
    delete(inst(n).obj); % Delete instructions
end

%% Start trials
for t = 1:length(tt) % For each row of the trial table
    app.UserData.Store = tt; % Save trial table in figure for safekeeping
    if tt(t).cond % If current row is a go trial...
        cond = 'go'; % Assign string
    else % If it is a nogo trial...
        cond = 'nogo'; % Assign string
    end
    i = randi([1, length(stim.(cond))]); % Pick random stimulus from relevant array
    tt(t).im = stim.(cond)(i).name; % Store stimulus name
    
    stim.(cond)(i).obj = image(ax, ...
        'XData', mean(ax.XLim) + [-400 400], ... % Position horizontal (center, 400px)
        'YData', mean(ax.YLim) + [-400 400], ... % Position vertical (center, 400px)
        'CData', flipud(stim.(cond)(i).img), ... % Flip upside down as y axes are backwards
        'AlphaData', flipud(stim.(cond)(i).alpha) ... % Apply transparency
        );
    fig.UserData.Key = []; % Reset key listener
    fig.UserData.Click = []; % Reset click listener
    tic
    while ~strcmp(fig.UserData.Key, 'space') && toc < 1 + (10-str2num(demog{2}))/10 % Until space bar is pressed, or until timeout (higher age = shorter timeout)...
        drawnow % Continuously refresh screen
    end
    delete(stim.(cond)(i).obj); % Delete stimulus
    tt(t).resp = fig.UserData.Key; % Store key
    tt(t).rt = toc; % Store reaction time
    
    i = {tt(t).cond+1, ~isempty(tt(t).resp)+1}; % Get index of appropriate reaction image
    react(i{:}).obj = image(ax, ...
        'XData', mean(ax.XLim) + [-400 400], ... % Position horizontal (center, 600px)
        'YData', mean(ax.YLim) + [-400 400], ... % Position vertical (center, 600px)
        'CData', flipud(react(i{:}).img), ... % Flip upside down as y axes are backwards
        'AlphaData', flipud(react(i{:}).alpha) ... % Apply transparency
        );
    drawnow % Refresh screen
    pause(1) % Wait 1s
    delete(react(i{:}).obj) % Clear reaction image
    drawnow % Refresh screen
end

close(fig) % End experiment











function [fig, w] = newWindow()
% Create a new window

sDim = get(groot, 'ScreenSize'); % Get Screen size
fig = figure( ...
    'InnerPosition', sDim, ... % Fullscreen figure
    'KeyPressFcn', @keyPress, ... % Create keypress listener
    'WindowButtonDownFcn', @clickFcn ... % Create click listener
    );
w = axes(fig, ...
    'Position', [0 0 1 1], ... % Fullscreen axis
    'XLim', [sDim([1 3])], ... % Align x axis to screen width
    'YLim', [sDim([2 4])], ... % Align y axis to screen height
    'TickLength', [0 0] ... % Hide ticks
    );

    function keyPress(app, event)
        if strcmp(event.Key, 'esc')
            close(app)
        end
        app.UserData = event.Key; % Set the UserData of the figure to equal the key which was just pressed
    end
    function clickFcn(app, varargin)
        app.UserData = get(w, 'CurrentPoint'); % Set the UserData of the figure to equal the coords of mouse
    end
end


function [resp, rt] = getresp(w, dur)
% Collect a response

tic % Start a timer
if dur == Inf % If duration is infinity...
    waitfor(w.Parent, 'UserData'); % Wait for a response
    resp = w.Parent.UserData; % Store response
    rt = toc; % Store timer value as reaction time
else
    cont = true;
    while toc < dur && cont % While timer is less than specified duration and no response is received
        resp = w.Parent.UserData; % Look for a response
        drawnow
        if ~isempty(resp) % If no response...
            cont = false; % End while loop
            drawnow
        end
    end
    rt = toc; % Store timer value as reaction time
end

if strcmp('escape', resp) % If they pressed escape...
    close all % Exit
    error('Experiment terminated by user'); % Print an error
end
end


function savedata(app, event)
% Save data and close window
drawnow
try
    evalin('base','writetable(tt, [''Data\'' join(demog, ''_'') ''.csv'']);'); % Save the base workspace variable tt to an excel file
    if ~exist('Data', 'dir')
        mkdir('Data')
    end
    evalin('base','save([''Data\'' pName ''.mat''], ''tt'', ''demog'', ''-mat'');'); % Save the base workspace variable tt and demog to a .mat file
        
catch
    disp('Experiment failed to save'); % Notify experimenter if save fails
end
delete(app) % Close window
end




function keyFcn(app, event)
app.UserData.Key = event.Key; % Store last key to user data
if strcmp(event.Key, 'escape')
    close(app);
end
end

function clickFcn(app, ~)
axArray = findobj(app.Children, 'Type', 'axes', 'Position', [0 0 1 1]); % Find all full screen axes
app.UserData.Click = get(axArray, 'CurrentPoint'); % Store mouse position to user data
end

function sizeFcn(app, ~)
axArray = findobj(app.Children, 'Type', 'axes', 'Position', [0 0 1 1]); % Find all full screen axes
for a = axArray' % For each axis...
    set(a, ...
        'XLim', [0, app.Position(3)], ... % Match XLim to figure width
        'YLim', [0, app.Position(4)] ... % Match YLim for figure height
        );
end
end

function closeFcn(app, ~)
assignin('base', 'data_backup', app.UserData.Store);
disp('Experiment terminated by user.');
delete(app)
end