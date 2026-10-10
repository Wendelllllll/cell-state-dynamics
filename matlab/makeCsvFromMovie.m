clear all

csv_file = fopen('nuclei_segmentation.csv', 'w');



fprintf(csv_file, 'Frame Number,Mean Pixel Intensity,Area,Perimeter,Cell ID\n');


num_iterations = 433;

Raw_meat = 'positionsxy01c2.tif';

% Loop through each iteration
for frame_number = 1:num_iterations
    fprintf('frame number: %d\n',frame_number)


    % Read the image
    image_Raw = imread(Raw_meat,frame_number);
    
    
%     if frame_number == 1
%         imtool(image_Raw);
%         keyboard
%     elseif frame_number == 30
%         imtool(image_Raw);
%         keyboard
%     end
    % Segment the cell nuclei using the `cellsegNucMask100722_SN2` function
    seg = cellsegNucMask100722_SN2(image_Raw);

    % Calculate the area, perimeter, and mean pixel intensity for each labeled region (cell nucleus)
    properties = regionprops(seg, image_Raw, 'Area', 'Perimeter', ...
        'MeanIntensity');

    % Loop through each component (cell nucleus) and write its properties to the CSV file
    for cell_id = 1:numel(properties)
        fprintf(csv_file, '%d,%f,%f,%f,%d\n', frame_number, ...
            properties(cell_id).MeanIntensity, properties(cell_id).Area, ...
            properties(cell_id).Perimeter, cell_id);
    end
end


% Close the CSV file
fclose(csv_file);