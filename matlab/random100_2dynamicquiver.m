% Set the number of random samples you want to select
numSamples = 100;

% Generate random indices for the subset
randomIndices = datasample(1:height(data), numSamples, 'Replace', false);

% Select the random subset of data
sub_data = data(randomIndices, :);

% Sort data by 'idx_glob' and 'Frame'
sub_data = sortrows(sub_data, {'idx_glob', 'Frame'});

% Initialize arrays to hold differences
dx = zeros(height(sub_data), 1);
dy = zeros(height(sub_data), 1);

% Calculate differences
for i = 2:height(sub_data) - 2
    if sub_data.idx_glob(i) == sub_data.idx_glob(i+1) && sub_data.idx_glob(i) == sub_data.idx_glob(i-1) % check if the previous and next rows are the same cell
        dx(i) = (sub_data.xumap(i+1) - sub_data.xumap(i-1)) / 2;
        dy(i) = (sub_data.yumap(i+1) - sub_data.yumap(i-1)) / 2;
    end
end

% Normalize dx and dy for direction
mag = sqrt(dx.^2 + dy.^2);
dx = dx ./ mag;
dy = dy ./ mag;

% Create scatter plot
figure;
scatter(sub_data.xumap, sub_data.yumap, 'filled');
xlabel('xumap');
ylabel('yumap');
title('Scatter plot of xumap vs. yumap with dynamic movement vectors');

hold on; % Add to the existing plot

% Create quiver plot
quiver(sub_data.xumap(2:end-2), sub_data.yumap(2:end-2), dx(2:end-2), dy(2:end-2), 'AutoScale', 'off', 'Color', 'r'); % 'r' for red color
hold off; % No more addition to the plot
