%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   feedback
%   
%   ~~
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maximal_force = MVIC_squat();
%maximal_force = 10;
[option, err] = InputGUI_mi();

if ~isempty(err)
    maximal_force = '';
    err = 'figure close';
    return;
end

option = str2double(option);

target_force = maximal_force * option/100;

rate = 100;
during_time = 20;
prior_time = 3;
total_time = during_time + prior_time;
time = linspace(0, total_time, total_time*rate + 10);

threshold = [target_force * 0.9, target_force * 1.1];

% Connect to QTM
ip = '127.0.0.1';
% Connects to QTM and keeps the connection alive.
QCM('connect', ip, 'frameinfo', 'force');

fig = figure(1);
hold on
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

xlim([0, total_time]);
ylim([0, target_force * 2]);

title('Force Measurement')

xlabel("Time(sec)", 'FontWeight', 'bold');
ylabel("Force(N)", 'FontWeight', 'bold');

plot([0, total_time], [0, 0],'black--')
plot([0, total_time], [target_force, target_force], 'Color', 'black', 'LineWidth', 1.5)
plot([0, total_time], [threshold(1), threshold(1)], 'g--', 'LineWidth', 1.5);
plot([0, total_time], [threshold(2), threshold(2)], 'g--', 'LineWidth', 1.5);
plot([3, 3], get(gca, 'ylim'), 'r--', 'LineWidth', 1.5);

realtime_data = plot(NaN, NaN, 'black', 'LineWidth', 1.5);

YData = NaN(1, length(time));
i=1;
while ishandle(fig)
    tStart = toc;
    event = QCM('event');
    [frameinfo, force] = QCM;
    
    % 1:right, 2:left
    right_vgrf = force{2, 1}(1, 3);
    left_vgrf = force{2, 2}(1, 3);
    vgrf = right_vgrf + left_vgrf;
    
    YData(i) = vgrf;
    set(realtime_data, 'XData', time(1:i), 'YData', YData(1:i));
    
    drawnow;
    i = i+1;
end

delete(fig);

% remove prior_time data
force_data = YData(rate*3+1:end);

% remove redundancy data
force_data = force_data(:, 1:during_time*rate);