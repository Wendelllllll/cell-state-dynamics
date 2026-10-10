% Sort data by 'idx_glob' and 'Frame'
sorted_data = sortrows(data, {'idx_glob', 'Frame'});

% Initialize arrays to hold differences
dx = zeros(height(sorted_data), 1);
dy = zeros(height(sorted_data), 1);

% Calculate differences
for i = 2:height(sorted_data) - 2
    if sorted_data.idx_glob(i) == sorted_data.idx_glob(i+1) && sorted_data.idx_glob(i) == sorted_data.idx_glob(i-1) % check if the previous and next rows are the same cell
        dx(i) = (sorted_data.xumap(i+1) - sorted_data.xumap(i-1)) / 2;
        dy(i) = (sorted_data.yumap(i+1) - sorted_data.yumap(i-1)) / 2;
    end
end

% Normalize dx and dy for direction
mag = sqrt(dx.^2 + dy.^2);
dx = dx ./ mag;
dy = dy ./ mag;

% Create scatter plot
figure;
scatter(sorted_data.xumap, sorted_data.yumap, 'filled');
xlabel('xumap');
ylabel('yumap');
title('Scatter plot of xumap vs. yumap with dynamic movement vectors');

hold on; % Add to the existing plot

% Create quiver plot
quiver(sorted_data.xumap(2:end-2), sorted_data.yumap(2:end-2), dx(2:end-2), dy(2:end-2), 'AutoScale', 'off', 'Color', 'r'); % 'r' for red color
hold off; % No more addition to the plot
