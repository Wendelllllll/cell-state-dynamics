function [seg] = cellsegNucMask100722_SN2(im)
im = double(im);
thresh = 1550; %
im(im < thresh) = 0;
im_ = im;
im_(im_ < 1640) = 0; % was 190
h1 = fspecial('gaussian',[5 5], 2); % 2D guassian filter was 30
i1 = imfilter(im,h1);   % gaussian filtered image


%watershed algorithm based on signal intensity
A = imbinarize(im_);
%imtool(A)
B = bwdist(~A);
%imtool(B)
C = -B;
%imtool(C)
D = imhmin(C,0.8);%was 0.55
%imtool(D)
L = watershed(D);
i1(L==0) = 0;

%%
log_threshold = -0.03;%3;  % edge-detection threshold for finding cell boundaries
low_in = 100./6000; % lowest intensity input value for cell regonition was 0.5
high_in = 4000./6000; % higest intensity input value to guarantee cell
low_out = 0; % adjusted low intensity output
high_out = 1; % adjusted high intensity output
minsize = 10;%250;   % minimum size of a cell
maxsize = 300; %2000;  % maximum size of a cell
maxecc = 2;%2;    % the maximum eccentricity of a cell
maxratio = 400; % the maximum perimeter squared/area of a cell 
% maxwobble = 0.03; % the maximum variation in cell perimeter
unsharp_size = 7;  % 'size' of the unsharp filter
unsharp_alpha = 1;  % degree of unsharp filtering between 0.2 and 0.9

h2 = fspecial('laplacian', unsharp_alpha);  % what is this shape factor?  worry about this later.
se = strel('disk',1); % morphological structuring element

i2 = imadjust(i1./6000,[low_in; high_in],[low_out; high_out]); % adjust image based on intensity thresholds
i3 = imfilter(i2,h2);   % the laplacian of the gaussian filtered image
i4 = (i3 < -log_threshold);      % select negative values of the laplacian
i5 = imopen(i4,se);   % erodes then dilates image to remove noise
i6 = imclearborder(i5,4);  % clear border objects
i7 = bwmorph(i6,'clean');  % remove isolated pixels
i8 = imfill(i7,'holes');   % fill holes
i9 = imopen(i8,strel('disk',2)); %get rid of more noise was 8
i10 = bwlabel(i9);

props = regionprops(i10, im, 'Area','Perimeter','MajorAxisLength','MinorAxisLength','MeanIntensity'); % properties of objects

%imtool(i1)

% find ways to exclude the non-cells
myecc = [props.MajorAxisLength]./[props.MinorAxisLength]; % eccentricity of each object
area = [props.Area]; % area of each object
ratio = [props.Perimeter].^(2)./[props.Area]; % perimeter squared/area ratio of each object
% [w] = wobble(i9,im); % wobble of each object
%disp(area)
select = intersect(find(area > minsize), find(area < maxsize));   % select objects of a certain size
select = intersect(select, find(myecc < maxecc));  % select objects that are not too eccentric
select = intersect(select, find(ratio < maxratio)); % select objects that are below a certain perimeter squared/area ratio 
%select = intersect(select, find(w < maxwobble)); % select objects without too much wobble

seg = ismember(i10, select); % select objects within parameters from labeled objects060117 to output
end