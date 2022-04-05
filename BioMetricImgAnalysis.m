%% Image Analysis for Biometric features
% Identify points in a frame that correspond the center point of a
% fish's head by analyzing the intensity characteristics of the larvae. The solution should not
% depend on threshold values that are manually determined. Investigate the accuracy of your
% determinations.

%% Acquiring images from file
%

location = 'C:\Users\Alan\Documents\MATLAB\zebraFish\frames_grey\*.png';
ds = imageDatastore(location);
img = read(ds);
imshow(img);

%% Convert Image to Grayscale
% Despite the image already being in grayscale, matlab still considers the
% image an rgb even though the rgb values are all the same within each
% pixel. Converting the to grayscale gets rid of the rgb and allows the
% usage of functions that require grayscale images.

grayimg = im2gray(img);
imtool(img);

%% Cropping out unnecessary pixels.
%
r = images.spatialref.Rectangle([15 96],[3 86]);
cropimg = imcrop(grayimg,r);
imshow(cropimg);
%% Examining intensity values
% Using imhist function on the grayimg in order to see the intensity value
% distribution of the grayscale image.

figure('Name','grayimg histogram'), imhist(cropimg);
title("Adjusted histogram");

%% imtophat from morphology
%
tomimg = imtophat(cropimg);
%% Edge Detection
% Using edge detection to see if it helps separate the fish from the
% background.

edgeimg = edge(cropimg, 'approxcanny');
imshow(edgeimg);

%% Morphology to fill in the Fish outline
% 

%% Thresholding the image
% Using thresholding in an attempt to separate the fishes from the
% background.

