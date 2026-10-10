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

        % Iterate through each unique idx_glob and calculate the quiver vectors
        for k = 1:numel(unique_idx_glob)
            % Select data points with the current idx_glob
            idx_glob_data = region_data(region_data.idx_glob == unique_idx_glob(k), :);

            % Calculate the differences between next frame and current frame
            dx = diff(idx_glob_data.xumap);
            dy = diff(idx_glob_data.yumap);

            % Calculate the position of the quiver
            x_pos = idx_glob_data.xumap(1:end-1);
            y_pos = idx_glob_data.yumap(1:end-1);

            % Create quiver plot for the current idx_glob
            quiver(x_pos, y_pos, dx, dy, 'Color', 'r');
        end
    end
end

hold off; % No more addition to the plot
