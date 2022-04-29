%% Image Analysis for Biometric features
% Identify points in a frame that correspond the center point of a fish's head 
% by analyzing the intensity characteristics of the larvae. The solution should 
% not depend on threshold values that are manually determined. Investigate the 
% accuracy of your determinations.
%% Acquiring images from file

folder = '.\zebraFish\frames_grey';
filePattern = fullfile(folder, '*.png');
theFiles = dir(filePattern);
numimages = length(theFiles);

% Not fully implemented, will need to create functions to be called within
% the loop and add to a montage of images

% for i = 1:1
    i = 1;
    baseFileName = theFiles(i).name;
    fullFileName = fullfile(theFiles(i).folder, baseFileName);
    img = imread(fullFileName);
    % will call functions here to process the image
    
    imtool(img);
% end

%% Convert Image to Grayscale
% Despite the image already being in grayscale, matlab still considers the image 
% an rgb even though the rgb values are all the same within each pixel. Converting 
% the to grayscale gets rid of the rgb and allows the usage of functions that 
% require grayscale images.

grayimg = im2gray(img);
imshow(grayimg);

%% Edge Detection
% Using edge detection to see if it helps separate the fish from the background.

edgeimg = edge(grayimg, 'approxcanny');
imshow(edgeimg);

se = strel("square",2);
dilimg = imdilate(edgeimg,se);
imshow(dilimg);

se = strel("square",2);
eroimg = imerode(dilimg, se);
imshow(eroimg);
dilimg3 = imdilate(edgeimg,se);
imshow(dilimg3);