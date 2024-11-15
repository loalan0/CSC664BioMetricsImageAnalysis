%% Image Analysis for Biometric features
% Identify points in a frame that correspond the center point of a fish's head 
% by analyzing the intensity characteristics of the larvae. The solution should 
% not depend on threshold values that are manually determined. Investigate the 
% accuracy of your determinations.
%% Acquiring images from file

clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures.
clear;  % Erase all existing variables.
workspace;  % Make sure the workspace panel is showing.

grayfishds = imageDatastore("zebraFish\frames_grey", "FileExtensions",".png", "LabelSource","foldernames");
numImgs = length(grayfishds.Labels);

numFish = 8;
numProcessed = 0;
totalFishFound = 0;

for i = 1:1
    img = readimage(grayfishds, 100);
%% Convert Image to Grayscale
% Despite the image already being in grayscale, matlab still considers the image 
% an rgb even though the rgb values are all the same within each pixel. Converting 
% the to grayscale gets rid of the rgb and allows the usage of functions that 
% require grayscale images.
    grayimg = im2gray(img);

%% Edge Detection
% Using edge detection to see if it helps separate the fish from the background.

    edges_prewitt = edge(grayimg,"prewitt");
    edges_canny = edge(grayimg,"canny");
    edges_roberts = edge(grayimg,"roberts");
    edges_sobel = edge(grayimg,"sobel");
    edges_approxcan = edge(grayimg,"approxcanny");

    figure;
    subplot(2,3,1);
    imshow(edges_prewitt);
    subplot(2,3,2);
    imshow(edges_canny);
    subplot(2,3,3);
    imshow(edges_roberts);
    subplot(2,3,4);
    imshow(edges_sobel);
    subplot(2,3,5);
    imshow(edges_approxcan);
    linkaxes;
%%
    [edges_prewitt2, edge_threshold] = edge(grayimg, "prewitt");

    step_size = 0.02;
    sensitivity = edge_threshold + step_size;
    edges_prewitt2 = edge(grayimg, "prewitt",sensitivity);
    figure;
    test = imshow(edges_prewitt2);
    title(sprintf("Sensitivity: %.03f", sensitivity));
end