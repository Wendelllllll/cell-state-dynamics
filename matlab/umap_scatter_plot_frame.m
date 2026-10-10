% Import data 
filename = 'data/cell_observations.csv';
data = readtable(filename);

xumap = data.xumap;
yumap = data.yumap;
frame = data.Frame;

% Normalize the frame column values to the range [0, 1]
normalizedFrame = (frame - min(frame)) / (max(frame) - min(frame));

% Create a custom colormap for the plot, ranging from light blue to dark blue
colormapSize = 256;
colormapBlue = linspace(1, 0, colormapSize)';
colormapGreen = linspace(1, 0, colormapSize)';
colormapRed = zeros(colormapSize, 1);
customColormap = [colormapRed, colormapGreen, colormapBlue];

% Create a scatter plot with color variation based on the frame column
figure;
hScatter = scatter(xumap, yumap, [], normalizedFrame, 'filled');
colormap(customColormap);
xlabel('xumap');
ylabel('yumap');
title('Scatter plot of xumap vs. yumap with color variation based on frame');

% Create a custom colorbar with the original frame numbers
hColorbar = colorbar;
numTicks = 5; % Change this value to have more or fewer ticks on the colorbar
tickPositions = linspace(0, 1, numTicks);
tickLabels = round(linspace(min(frame), max(frame), numTicks));
hColorbar.Ticks = tickPositions;
hColorbar.TickLabels = tickLabels;
hColorbar.Label.String = 'Frame';
