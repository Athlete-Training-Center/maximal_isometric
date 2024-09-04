function [option, err] = InputGUI_mi()
    err = '';
    fig = figure('Position', [300, 300, 400, 200], 'MenuBar','none', 'Name', ...
        'Measure Vertical Maximal Force', 'NumberTitle','off', 'Resize','off', ...
        'CloseRequestFcn',@closeCallback);

    % Create input label and text bot
    uicontrol('Style','text', 'Position', [50, 120, 200, 30], 'String', ...
        'choose the option (10/40/70)%', 'HorizontalAlignment', 'left', 'FontSize',10);
    option_box = uicontrol('Style', 'edit', 'Position', [250, 120, 100, 30], 'FontSize',10);
    
    % Create a submit button
    uicontrol('Style', 'pushbutton', 'Position', [150, 20, 100, 40], 'String', ...
       'Submit', 'FontSize',10, 'Callback', @submitCallback);

    data.option = '';
    set(fig, 'UserData', data);

    uiwait(fig);

    % if date input, save that in variables
    if isvalid(fig)
        data = get(fig, 'UserData');
        option = data.option;
        delete(fig);
    else
        disp('Figure was closed before data could be retrieved')
    end

    % Callback function for the submit button
    function submitCallback(~, ~)
        option = get(option_box, 'String');

        % store the inputs in the figure's UserData property
        data.option = option;
        set(fig, 'UserData', data);

        % Resume the GUI
        uiresume(fig);
    end


    % Callback function for closing the figure
    function closeCallback(~, ~)
        % Resume the GUI
        uiresume(fig);

        % Delete the figure
        delete(fig);

        err = 'figure close';
    end
end