clear all
close all
% Import the data from the CSV file
filename = 'Dataset2.0.csv';
data = readtable(filename);
data = data(data.fluo1_mean_corr > 0, :);

data = data(data.fluo2_corr > 0, :);

data = data(log10(data.fluo1_mean_corr) > 2.45, :);
data = data(log10(data.fluo1_mean_corr) < 3.25, :);

figure;
scatter(data.xumap, data.yumap, 20, log10(data.fluo1_mean_corr), "filled");
set(gca,"clim",[2.5,3])

figure;
scatter(data.xumap, data.yumap, 20, log10(data.fluo2_corr), "filled");



CELLID = unique(data.idx_glob);

All_lifespan = [];

for c = CELLID'
    subdata = data(data.idx_glob == c, :);
    maxframe = max(subdata.Frame);
    sub_lifespan = subdata.Frame/maxframe;
    All_lifespan = [All_lifespan; sub_lifespan];
end
 
data.lifespan = All_lifespan;

figure;
scatter(log10(data.fluo2_corr), log10(data.fluo1_mean_corr), 20, data.lifespan, "filled");

figure;
scatter(data.xumap, data.yumap, 20, data.lifespan, "filled");

