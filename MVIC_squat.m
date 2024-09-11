function maximal_force = MVIC_squat()
    UserInfo = input_UserInfo();

    UserNumber = UserInfo.UserNumber;
    % Connect to QTM
    ip = '127.0.0.1';
    % Connects to QTM and keeps the connection alive.
    QCM('connect', ip, 'frameinfo', 'force');

    rate = 100;
    during_time = 5;
    trial = 3;
    time = linspace(0, during_time, during_time*rate + 10);
    
    fig = figure(1);
    hold on
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);    
    xlim([0, during_time]);

    realtime_data = plot(NaN, NaN, 'black', 'LineWidth', 1.5);
    plot([0, during_time], [0, 0], 'black--')
    
    right_vgrfs = NaN(trial, length(time));
    left_vgrfs = NaN(trial, length(time));
    force_data = NaN(trial, length(time));
    for t=1:trial
        % Add text for countdown timer
        y_pos = 0.8 * max(ylim);
        timerText = text(0.1, y_pos, 'Start: 2', 'FontSize', 14, 'FontWeight', 'bold');
        w = waitforbuttonpress;
        if ~isempty(w)
            for sec = 2:-1:0
                set(timerText, 'String', ['Start: ', num2str(sec)]);
                pause(1);
            end
        end
        delete(timerText);
        try
            tStart = tic;
            i=1;
            while true
                event = QCM('event');
                % Fetch data from QTM
                [frameinfo,force] = QCM;
        
                if ~ishandle(fig)
                    QCM('disconnect');
                    break;
                end
                
                % 1:right, 2:left
                right_vgrf = force{2, 1}(1, 3); 
                left_vgrf = force{2, 2}(1, 3);
                % sum both foot
                vgrf = right_vgrf + left_vgrf;
                
                right_vgrfs(i) = right_vgrf;
                left_vgrfs(i) = left_vgrf;
                force_data(t, i) = vgrf;
                set(realtime_data, 'XData', time(1:i), 'YData', force_data(t, 1:i));
                
                i = i+1;

                drawnow;
                
                if toc(tStart) >= during_time
                    break;
                end
            end
        catch exception
            disp(exception.message);
            break
        end
    end

    delete(fig);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get maximal force for each trial
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % remove redundancy data
    force_data = force_data(:, 1:during_time*rate);
    % calculate maximal force for each trial
    maximal_force_per_trial = max(force_data, [], 2);
    % calculate total maximal force 
    maximal_force = average(maximal_force_per_trial);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % save result data at folder named today
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dir_name = sprintf('%s', UserNumber);
    mkdir(sprintf('maximal_isometric/%s',dir_name));
    
    right_xlsx_file_name = sprintf('maximal_isometric/%s/mvic_squat_right.xlsx', dir_name);
    writematrix(transpose(right_vgrfs), right_xlsx_file_name);
    left_xlsx_file_name = sprintf('maximal_isometric/%s/mvic_squat_left.xlsx', dir_name);
    writematrix(transpose(left_vgrfs), left_xlsx_file_name);
    sum_xlsx_file_name = sprintf('maximal_isometric/%s/mvic_squat_sum.xlsx', dir_name);
    writematrix(transpose(force_data), sum_xlsx_file_name)
%{
    right_mat_file_name = replace(right_xlsx_file_name, ".xlsx", ".mat");
    save_file(right_mat_file_name, dir_name, true, true, "right_vgrfs");
    left_mat_file_name = replace(left_xlsx_file_name, ".xlsx", ".mat");
    save_file(left_mat_file_name, dir_name, true, true, "left_vgrfs");
    sum_mat_file_name = replace(sum_xlsx_file_name, ".xlsx", ".mat");
    save_file(sum_mat_file_name, dir_name, true, true, "force_data");
end

function save_file(data, dir, xlsx, mat, variable_name)
    if xlsx
        writematrix(transpose(data), dir);
    end
    if mat
        save(dir, variable_name);
    end
end
%}