% Sort data by 'idx_glob' and 'Frame'
sorted_data = sortrows(data, {'idx_glob', 'Frame'});

% Calculate the number of divisions in x and y directions
numDivisionsX = 10;
numDivisionsY = 10;

% Calculate the size of each rectangular region
xStep = range(sorted_data.xumap) / numDivisionsX;
yStep = range(sorted_data.yumap) / numDivisionsY;

% Create scatter plot
figure;
scatter(sorted_data.xumap, sorted_data.yumap, 'filled');
xlabel('xumap');
ylabel('yumap');
title('Scatter plot of xumap vs. yumap with quivers');

hold on; % Add to the existing plot

% Draw rectangles for each region
for i = 1:numDivisionsX
    for j = 1:numDivisionsY
        % Calculate the boundaries of the current rectangle
        xMin = min(sorted_data.xumap) + (i-1) * xStep;
        xMax = min(sorted_data.xumap) + i * xStep;
        yMin = min(sorted_data.yumap) + (j-1) * yStep;
        yMax = min(sorted_data.yumap) + j * yStep;

        % Select data points within the current rectangle
        region_data = sorted_data(sorted_data.xumap >= xMin & sorted_data.xumap <= xMax & sorted_data.yumap >= yMin & sorted_data.yumap <= yMax, :);

        % Get unique idx_glob values in the current region
        unique_idx_glob = unique(region_data.idx_glob);

        % Initialize the sums of dx and dy to zero
        sum_dx = 0;
        sum_dy = 0;

        % Iterate through each unique idx_glob and calculate the quiver vectors
        for k = 1:numel(unique_idx_glob)
            % Select data points with the current idx_glob
            idx_glob_data = region_data(region_data.idx_glob == unique_idx_glob(k), :);

            % Make sure we have at least 3 frames to calculate the quiver vectors
            if height(idx_glob_data) >= 3
                % Iterate through the data frames
                for frame_index = 2:height(idx_glob_data) - 1
                    % Get the previous, current, and future frames
                    prev_frame = idx_glob_data(frame_index - 1, :);
                    current_frame = idx_glob_data(frame_index, :);
                    future_frame = idx_glob_data(frame_index + 1, :);

                    % Calculate the quiver vectors
                    dx = future_frame.xumap - prev_frame.xumap;
                    dy = future_frame.yumap - prev_frame.yumap;

                    % Add the dx and dy to the sum
                    sum_dx = sum_dx + dx;
                    sum_dy = sum_dy + dy;
                end
            end
        end

        % Calculate the position of the quiver
        x_pos = xMin + xStep / 2;
        y_pos = yMin + yStep / 2;

        % Normalize the sum of dx and dy
        quiver_length = sqrt(sum_dx^2 + sum_dy^2);
        normalized_dx = sum_dx / quiver_length;
        normalized_dy = sum_dy / quiver_length;

        % Create quiver plot for the current region
        quiver(x_pos, y_pos, normalized_dx, normalized_dy, 'Color', 'r');
    end
end

hold off; % No more addition to the plot