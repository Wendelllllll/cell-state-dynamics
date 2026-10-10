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
title('Scatter plot of xumap vs. yumap with divisions');

hold on; % Add to the existing plot

% Draw rectangles for each region
for i = 1:numDivisionsX
    for j = 1:numDivisionsY
        % Calculate the boundaries of the current rectangle
        xMin = min(sorted_data.xumap) + (i-1) * xStep;
        xMax = min(sorted_data.xumap) + i * xStep;
        yMin = min(sorted_data.yumap) + (j-1) * yStep;
        yMax = min(sorted_data.yumap) + j * yStep;

        % Draw the rectangle
        rectangle('Position', [xMin, yMin, xStep, yStep], 'EdgeColor', 'r');
    end
end

hold off; % No more addition to the plot
