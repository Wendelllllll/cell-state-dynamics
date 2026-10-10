
% Sort data by 'idx_glob' and 'Frame'
sorted_data = sortrows(data, {'idx_glob', 'Frame'});

% Get unique idx_glob values*
unique_idx_glob_all = unique(sorted_data.idx_glob);

% Select a random subset of 10 unique idx_glob values*
unique_idx_glob_subset = randsample(unique_idx_glob_all, 10);

% Select data points with the subset of idx_glob*
subset_data = sorted_data(ismember(sorted_data.idx_glob, unique_idx_glob_subset), :);

% Calculate the number of divisions in x and y directions
numDivisionsX = 10;
numDivisionsY = 10;

% Calculate the size of each rectangular region
xStep = range(subset_data.xumap) / numDivisionsX;
yStep = range(subset_data.yumap) / numDivisionsY;

% Create scatter plot
figure;
scatter(subset_data.xumap, subset_data.yumap, 'filled');
xlabel('xumap');
ylabel('yumap');
title('Scatter plot of xumap vs. yumap with quivers');

hold on; % Add to the existing plot

% Draw rectangles for each region
for i = 1:numDivisionsX
    for j = 1:numDivisionsY
        % Calculate the boundaries of the current rectangle
        xMin = min(subset_data.xumap) + (i-1) * xStep;
        xMax = min(subset_data.xumap) + i * xStep;
        yMin = min(subset_data.yumap) + (j-1) * yStep;
        yMax = min(subset_data.yumap) + j * yStep;

        % Select data points within the current rectangle
        region_data = subset_data(subset_data.xumap >= xMin & subset_data.xumap <= xMax & subset_data.yumap >= yMin & subset_data.yumap <= yMax, :);

        % Get unique idx_glob values in the current region
        unique_idx_glob = unique(region_data.idx_glob);

        % Iterate through each unique idx_glob and calculate the average quiver vectors
        for k = 1:numel(unique_idx_glob)
            % Select data points with the current idx_glob
            idx_glob_data = region_data(region_data.idx_glob == unique_idx_glob(k), :);

            % Make sure we have at least 3 frames to calculate the average quiver vectors
            if height(idx_glob_data) >= 3
                % Get the previous, current, and future frames
                prev_frames = idx_glob_data(1:end-2, :);
                current_frame = idx_glob_data(2:end-1, :);
                future_frames = idx_glob_data(3:end, :);

                % Calculate the average quiver vectors
                dx = mean(future_frames.xumap - prev_frames.xumap);
                dy = mean(future_frames.yumap - prev_frames.yumap);

                % Calculate the position of the quiver
                x_pos = mean(current_frame.xumap);
                y_pos = mean(current_frame.yumap);

                % Create quiver plot for the current idx_glob
                quiver_length = sqrt(dx^2 + dy^2);
                normalized_dx = dx / quiver_length;
                normalized_dy = dy / quiver_length;

                quiver(x_pos, y_pos, normalized_dx, normalized_dy, 'Color', 'r');

                
            end
        end
    end
end

hold off;

