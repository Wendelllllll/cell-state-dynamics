% Import data 
filename = 'data/cell_observations.csv';
data = readtable(filename);

% Sort data by 'idx_glob' and 'Frame'
data = sortrows(data, {'idx_glob', 'Frame'});

% Initialize arrays to hold differences
dx = zeros(height(data), 1);
dy = zeros(height(data), 1);

% Calculate differences
for i = 1:height(data) - 1
    if data.idx_glob(i) == data.idx_glob(i+1)  % check if the next row is the same cell
        dx(i) = data.xumap(i+1) - data.xumap(i);
        dy(i) = data.yumap(i+1) - data.yumap(i);
    end
end

% Create quiver plot
figure;
quiver(data.xumap, data.yumap, dx, dy, 'AutoScale', 'off', 'Color', 'r'); 
xlabel('xumap');
ylabel('yumap');
title('Quiver plot of cell movement');
