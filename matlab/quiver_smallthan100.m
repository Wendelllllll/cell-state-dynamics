% Filter data
sub_data = data(data.idx_glob < 100, :);

% Sort data by 'idx_glob' and 'Frame'
sub_data = sortrows(sub_data, {'idx_glob', 'Frame'});

% Initialize arrays to hold differences
dx = zeros(height(sub_data), 1);
dy = zeros(height(sub_data), 1);

% Calculate differences
for i = 1:height(sub_data) - 1
    if sub_data.idx_glob(i) == sub_data.idx_glob(i+1)  % check if the next row is the same cell
        dx(i) = sub_data.xumap(i+1) - sub_data.xumap(i);
        dy(i) = sub_data.yumap(i+1) - sub_data.yumap(i);
    end
end

% Create scatter plot
figure;
scatter(sub_data.xumap, sub_data.yumap, 'filled');
xlabel('xumap');
ylabel('yumap');
title('Scatter plot of xumap vs. yumap with movement vectors');

hold on; % Add to the existing plot

% Create quiver plot
quiver(sub_data.xumap, sub_data.yumap, dx, dy, 'AutoScale', 'off', 'Color', 'r'); % 'r' for red color
hold off; % No more addition to the plot
