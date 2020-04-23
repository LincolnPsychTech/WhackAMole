clear all
close all

%% Setup
noTrials = 53;
noBlocks = 4;
preTrials = 10;

demog = inputdlg({... % Get demographic info
    'Participant Number', ...
    'Condition', ...
    'Age', ...
    'Gender' ...
    });
pName = demog{1}; % Extract participant name

switch demog{2}
    case '0'
        ratios = [...
            0.8, 0.2;
            0.875, 0.125 ...
            ];
    case '1'
        ratios = [...
            0.2, 0.8;
            0.125, 0.875 ...
            ];
end
[fig, w] = newWindow(); % Create new window
fig.CloseRequestFcn = @savedata; % Tell the window to save before closing


tt = struct2table(struct( ... % Create an empty table to store data / parameters in
    'block', cell(noTrials*noBlocks, 1), ...
    'trial', cell(noTrials*noBlocks, 1), ...
    'cond', cell(noTrials*noBlocks, 1), ...
    'im', cell(noTrials*noBlocks, 1), ...
    'resp', cell(noTrials*noBlocks, 1), ...
    'rt', cell(noTrials*noBlocks, 1) ...
    ));

% Assign trials
blocks = cell(1,noBlocks);
for n = [1, noBlocks] % First & last blocks to have avg. 7 Gos before NoGo
    blocks{n} = [ones(1, ceil(noTrials*0.875)), zeros(1, floor(noTrials*0.125))];
    blocks{n} = blocks{n}(randperm(noTrials));
end
for n = 2:noBlocks-1 % Middle blocks to be 80% Gos
    blocks{n} = [ones(1, ceil(noTrials*0.8)), zeros(1, floor(noTrials*0.2))];
    blocks{n} = blocks{n}(randperm(noTrials));
end
tt.cond = logical([blocks{:}]');

% Show background
[bg.pix, bg.map, bg.alpha] = imread('Background.png');
background = imshow(bg.pix, bg.map);
set(w, ...
    'TickLength', [0 0], ...
    'NextPlot', 'add' ...
    );

% Read moles
moles = dir('Moles');
moles(1:2) = [];

% Read NoGos
nogos = dir('NoGo');
nogos(1:2) = [];

% Instructions
[img.pix, img.map, img.alpha] = imread('Instructions/Instructions1.png');
inst1 = imshow(img.pix, img.map);
inst1.AlphaData = img.alpha;
inst1.XData = background.XData;
inst1.YData = background.YData;
drawnow
getresp(w, Inf)
delete(inst1);
fig.UserData = []; % Reset keypress/click listener


[img.pix, img.map, img.alpha] = imread('Instructions/Instructions2.png');
inst2 = imshow(img.pix, img.map);
inst2.AlphaData = img.alpha;
inst2.XData = background.XData;
inst2.YData = background.YData;
drawnow
getresp(w, Inf)
delete(inst2);
fig.UserData = []; % Reset keypress/click listener


[img.pix, img.map, img.alpha] = imread('Instructions/Instructions3.png');
inst3 = imshow(img.pix, img.map);
inst3.AlphaData = img.alpha;
inst3.XData = background.XData;
inst3.YData = background.YData;
drawnow
getresp(w, Inf)
delete(inst3);
fig.UserData = []; % Reset keypress/click listener


% Practice Trials
for t = 1:preTrials
    cond = logical(round(rand()));
    % ISI
    [img.pix, img.map, img.alpha] = imread('Hole.png');
    hole = imshow(img.pix, img.map);
    hole.AlphaData = img.alpha;
    hole.XData = mean(w.XLim) + size(img.pix,2)./[-2 2];
    hole.YData = w.YLim(2) - 200 - [size(img.pix,1), 0];
    drawnow
    pause(5)
    delete(hole); % Clear ISI
    
    fig.UserData = []; % Reset keypress/click listener
    if cond
        % Show mole
        choice = round(rand()*(length(moles)-1))+1; % Choose mole at random
        [img.pix, img.map, img.alpha] = imread(['Moles/' moles(choice).name]); % Read mole image
        mole = imshow(img.pix, img.map); % Display mole
        mole.AlphaData = img.alpha; % Apply transparency
        mole.XData = mean(w.XLim) + size(img.pix,2)./[-2 2]; % Resize (horizontal)
        mole.YData = w.YLim(2) - 200 - [size(img.pix,1), 0]; % Resize (vertical)
        drawnow
    else
        % Show NoGo
        choice = round(rand()*(length(nogos)-1))+1; % Choose nogo at random
        [img.pix, img.map, img.alpha] = imread(['NoGo/' nogos(choice).name]); % Read nogo image
        nogo = imshow(img.pix, img.map); % Display mole
        nogo.AlphaData = img.alpha; % Apply transparency
        nogo.XData = mean(w.XLim) + size(img.pix,2)./[-2 2]; % Resize (horizontal)
        nogo.YData = w.YLim(2) - 200 - [size(img.pix,1), 0]; % Resize (vertical)
        drawnow
    end
    
    % Get response
    [resp, rt] = getresp(w, 1.5);
    if ~isempty(resp)
        resp = true;
    else
        resp = false;
    end
    
    if cond && resp
        % Show whack
        [img.pix, img.map, img.alpha] = imread('Whack.png');
        whack = imshow(img.pix, img.map);
        whack.AlphaData = img.alpha;
        whack.XData = mean(w.XLim) + size(img.pix,2)./[-2 2];
        whack.YData = mean(w.YLim) + size(img.pix,1)./[-2 2];
        drawnow
    end
    if ~cond && resp
        % Show oops
        [img.pix, img.map, img.alpha] = imread('Oops.png');
        oops = imshow(img.pix, img.map);
        oops.AlphaData = img.alpha;
        oops.XData = mean(w.XLim) + size(img.pix,2)./[-2 2];
        oops.YData = mean(w.YLim) + size(img.pix,1)./[-2 2];
        drawnow
    end
    if ~cond && ~resp
        % Show awesome
        [img.pix, img.map, img.alpha] = imread('Awesome.png');
        awesome = imshow(img.pix, img.map);
        awesome.AlphaData = img.alpha;
        awesome.XData = mean(w.XLim) + size(img.pix,2)./[-2 2];
        awesome.YData = mean(w.YLim) + size(img.pix,1)./[-2 2];
        drawnow
    end
    if cond && ~resp
        % Show miss
        [img.pix, img.map, img.alpha] = imread('Miss.png');
        miss = imshow(img.pix, img.map);
        miss.AlphaData = img.alpha;
        miss.XData = mean(w.XLim) + size(img.pix,2)./[-2 2];
        miss.YData = mean(w.YLim) + size(img.pix,1)./[-2 2];
        drawnow
    end
    
    pause(1)
    
    % Clear
    delete(w.Children(w.Children ~= background));
end

[img.pix, img.map, img.alpha] = imread('Instructions/Instructions3.png');
inst3 = imshow(img.pix, img.map);
inst3.AlphaData = img.alpha;
inst3.XData = background.XData;
inst3.YData = background.YData;
drawnow
getresp(w, Inf)
delete(inst3);
fig.UserData = []; % Reset keypress/click listener

% Start Experiment
for t = 1:noTrials*noBlocks
    tt{t, 'trial'}{:} = mod(t, noTrials); % Store trial number
    tt{t, 'block'}{:} = ceil(t/noTrials); % Store block number
    
    % ISI
    [img.pix, img.map, img.alpha] = imread('Hole.png');
    hole = imshow(img.pix, img.map);
    hole.AlphaData = img.alpha;
    hole.XData = mean(w.XLim) + size(img.pix,2)./[-2 2];
    hole.YData = w.YLim(2) - 200 - [size(img.pix,1), 0];
    drawnow
    pause(5)
    delete(hole); % Clear ISI
    
    fig.UserData = []; % Reset keypress/click listener
    if tt{t,'cond'}
        % Show mole
        choice = round(rand()*(length(moles)-1))+1; % Choose mole at random
        [img.pix, img.map, img.alpha] = imread(['Moles/' moles(choice).name]); % Read mole image
        tt{t, 'im'}{:} = {moles(choice).name}; % Store mole choice
        mole = imshow(img.pix, img.map); % Display mole
        mole.AlphaData = img.alpha; % Apply transparency
        mole.XData = mean(w.XLim) + size(img.pix,2)./[-2 2]; % Resize (horizontal)
        mole.YData = w.YLim(2) - 200 - [size(img.pix,1), 0]; % Resize (vertical)
        drawnow
    else
        % Show NoGo
        choice = round(rand()*(length(nogos)-1))+1; % Choose nogo at random
        [img.pix, img.map, img.alpha] = imread(['NoGo/' nogos(choice).name]); % Read nogo image
        tt{t, 'im'}{:} = {nogos(choice).name}; % Store NoGo choice
        nogo = imshow(img.pix, img.map); % Display mole
        nogo.AlphaData = img.alpha; % Apply transparency
        nogo.XData = mean(w.XLim) + size(img.pix,2)./[-2 2]; % Resize (horizontal)
        nogo.YData = w.YLim(2) - 200 - [size(img.pix,1), 0]; % Resize (vertical)
        drawnow
    end
    
    % Get response
    [tt{t,'resp'}{:}, tt{t,'rt'}{:}] = getresp(w, 1.5);
    if ~isempty(tt{t,'resp'}{:})
        tt{t,'resp'}{:} = true;
    else
        tt{t,'resp'}{:} = false;
    end
    
    if tt{t,'cond'} && tt{t,'resp'}{:}
        % Show whack
        [img.pix, img.map, img.alpha] = imread('Whack.png');
        whack = imshow(img.pix, img.map);
        whack.AlphaData = img.alpha;
        whack.XData = mean(w.XLim) + size(img.pix,2)./[-2 2];
        whack.YData = mean(w.YLim) + size(img.pix,1)./[-2 2];
        drawnow
    end
    if ~tt{t,'cond'} && tt{t,'resp'}{:}
        % Show oops
        [img.pix, img.map, img.alpha] = imread('Oops.png');
        oops = imshow(img.pix, img.map);
        oops.AlphaData = img.alpha;
        oops.XData = mean(w.XLim) + size(img.pix,2)./[-2 2];
        oops.YData = mean(w.YLim) + size(img.pix,1)./[-2 2];
        drawnow
    end
    if ~tt{t,'cond'} && ~tt{t,'resp'}{:}
        % Show awesome
        [img.pix, img.map, img.alpha] = imread('Awesome.png');
        awesome = imshow(img.pix, img.map);
        awesome.AlphaData = img.alpha;
        awesome.XData = mean(w.XLim) + size(img.pix,2)./[-2 2];
        awesome.YData = mean(w.YLim) + size(img.pix,1)./[-2 2];
        drawnow
    end
    if tt{t,'cond'} && ~tt{t,'resp'}{:}
        % Show miss
        [img.pix, img.map, img.alpha] = imread('Miss.png');
        miss = imshow(img.pix, img.map);
        miss.AlphaData = img.alpha;
        miss.XData = mean(w.XLim) + size(img.pix,2)./[-2 2];
        miss.YData = mean(w.YLim) + size(img.pix,1)./[-2 2];
        drawnow
    end
    
    pause(1)
    
    % Clear
    delete(w.Children(w.Children ~= background));
    
    % Rest between blocks
    if tt{t,'trial'}{:} == 0
        [img.pix, img.map, img.alpha] = imread('Instructions/Instructions3.png');
        inst3 = imshow(img.pix, img.map);
        inst3.AlphaData = img.alpha;
        inst3.XData = background.XData;
        inst3.YData = background.YData;
        drawnow
        getresp(w, Inf)
        delete(inst3);
        tt.trial([tt.trial{:}] == 0) = deal({noTrials});
    end
end


close(fig)











function [fig, w] = newWindow()
% Create a new window

fig = figure; % Create figure
w = axes(fig); % Draw axes
sDim = get(groot, 'ScreenSize'); % Get monitor size

set(fig, ...
    'InnerPosition', sDim, ... % Fullscreen figure
    'KeyPressFcn', @keyPress, ... % Create keypress listener
    'WindowButtonDownFcn', @clickFcn ... % Create click listener
    );

set(w, ...
    'Position', [0 0 1 1], ... % Fullscreen axis
    'XLim', [sDim([1 3])], ... % Align x axis to screen width
    'YLim', [sDim([2 4])], ... % Align y axis to screen height
    'TickLength', [0 0] ... % Hide ticks
    );

    function keyPress(app, event)
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
close % Close window
end