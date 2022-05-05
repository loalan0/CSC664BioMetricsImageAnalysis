%% Image Analysis for Biometric features
% Identify points in a frame that correspond the center point of a fish's head 
% by analyzing the intensity characteristics of the larvae. The solution should 
% not depend on threshold values that are manually determined. Investigate the 
% accuracy of your determinations.
%% Acquiring images from file

grayfishds = imageDatastore("zebraFish\frames_grey", "FileExtensions",".png", "LabelSource","foldernames");
numObs = length(grayfishds.Labels);


for i = 1:20
    img = readimage(grayfishds, 300);
    grayimg = turnGray(img);
    examValues(grayimg);
    [eyesregions, closedhead] = multiOtsu(grayimg);
    regionProps(eyesregions, closedhead);
    edgeDetect(grayimg);
    subplot(5,60, i), imshow(grayimg);
%     will call functions here to process the image
 end
 

%% Convert Image to Grayscale
% Despite the image already being in grayscale, matlab still considers the image 
% an rgb even though the rgb values are all the same within each pixel. Converting 
% the to grayscale gets rid of the rgb and allows the usage of functions that 
% require grayscale images.

function grayimg = turnGray(img)
    grayimg = im2gray(img);
    imshow(grayimg);

end
%% Examining intensity values
% Using imhist function on the grayimg in order to see the intensity value distribution 
% 
% of the grayscale image.

function examValues(img)
    figure('Name','grayimg histogram'), imhist(img);
    title("Intensity values histogram");
end
%% Multithresh or multiotsu
% Using multithresh will return a number of threshold values that will help 
% to group regions with like intensity characteristics.

function [eyesregions, closedhead] = multiOtsu(grayimg)
    thresh = multithresh(grayimg, 12);
    
    seg_I = imquantize(grayimg,thresh);
    
    RGB = label2rgb(seg_I);
    threshedimg= im2gray(RGB);
    imshow(threshedimg);
    figure;
    imshow(RGB);
    axis off
    title('RGB Segmented Image');
    eyesregions = (seg_I == 1 );
    imshow(eyesregions);
    
    headregions = ( seg_I == 1 | seg_I == 2 | seg_I == 3 | seg_I == 4 | seg_I == 5 | seg_I == 6);
    
    se = strel("square",2);
    closedhead = imclose(headregions, se);
    
    closedhead = bwareaopen(closedhead, 30);
    imshow(closedhead);
    title("Cleaned heads image",'FontSize',20);
end

%% Regionprops

function regionProps(eyesregions, closedhead)
    [labeledeyes, numberOfOEyes] = bwlabel(eyesregions);
    
    [labeledheads, numberOfHeads] = bwlabel(closedhead);
    blobMeasurements = regionprops(labeledheads,...
	    'Perimeter', 'Area', 'FilledArea', 'Solidity', 'Centroid');
    
    [boundaries,L] = bwboundaries(labeledheads, 'noholes');
    imshow(label2rgb(L, @jet, [.5 .5 .5]));
    hold on
    
    for k = 1:length(boundaries)
       boundary = boundaries{k};
       plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    end
    
    % Collect some of the measurements into individual arrays.
    perimeters = [blobMeasurements.Perimeter];
    areas = [blobMeasurements.Area];
    filledAreas = [blobMeasurements.FilledArea];
    solidities = [blobMeasurements.Solidity];
    % Calculate circularities:
    circularities = perimeters .^2 ./ (4 * pi * filledAreas);
    % Print to command window.
    fprintf('#, Perimeter,        Area, Filled Area, Solidity, Circularity\n');
    for blobNumber = 1 : numberOfHeads
	    fprintf('%d, %9.3f, %11.3f, %11.3f, %8.3f, %11.3f\n', ...
		    blobNumber, perimeters(blobNumber), areas(blobNumber), ...
		    filledAreas(blobNumber), solidities(blobNumber), circularities(blobNumber));
    end
    
    for blobNumber = 1 : numberOfHeads
	    % Outline the object so the user can see it.
	    thisBoundary = boundaries{blobNumber};
	    subplot(2, 2, 2); % Switch to upper right image.
	    hold on;
	    % Display prior boundaries in blue
	    for k = 1 : blobNumber-1
		    thisBoundary = boundaries{k};
		    plot(thisBoundary(:,2), thisBoundary(:,1), 'b', 'LineWidth', 3);
	    end
	    % Display this bounary in red.
	    thisBoundary = boundaries{blobNumber};
	    plot(thisBoundary(:,2), thisBoundary(:,1), 'r', 'LineWidth', 3);
	    subplot(2, 2, 4); % Switch to lower right image.
	    
	    % Determine the shape.
	    if circularities(blobNumber) < 1.2
		    % Theoretical value for a circle is 1.
		    message = sprintf('For object #%d,\nthe perimeter = %.3f,\nthe area = %.3f,\nthe circularity = %.3f,\nso the object is a circle',...
			    blobNumber, perimeters(blobNumber), areas(blobNumber), circularities(blobNumber));
		    shape = 'circle';
	    elseif circularities(blobNumber) < 1.5
		    % Theoretical value for a square is (4d)^2 / (4*pi*d^2) = 4/pi = 1.273
		    message = sprintf('For object #%d,\nthe perimeter = %.3f,\nthe area = %.3f,\nthe circularity = %.3f,\nso the object is a square',...
			    blobNumber, perimeters(blobNumber), areas(blobNumber), circularities(blobNumber));
		    shape = 'square';
	    elseif circularities(blobNumber) > 1.5 && circularities(blobNumber) < 1.8
		    % Theoretical value for an isosceles triangle is (3d)^2 / (4 * pi * 0.5 * d * d * sind(60)) = 9/(4 * pi * 0.5*sind(60)) = 1.6539
		    message = sprintf('For object #%d,\nthe perimeter = %.3f,\nthe area = %.3f,\nthe circularity = %.3f,\nso the object is an isosceles triangle',...
			    blobNumber, perimeters(blobNumber), areas(blobNumber), circularities(blobNumber));
		    shape = 'triangle';
	    else
		    message = sprintf('The circularity of object #%d is %.3f,\nso the object is something else.',...
			    blobNumber, circularities(blobNumber));
		    shape = 'something else';
	    end
	    
	    % Display the classification that we determined in overlay above the object.
	    overlayMessage = sprintf('Object #%d = %s\ncirc = %.2f, s = %.2f', ...
		    blobNumber, shape, circularities(blobNumber), solidities(blobNumber));
	    text(blobMeasurements(blobNumber).Centroid(1), blobMeasurements(blobNumber).Centroid(2), ...
		    overlayMessage, 'Color', 'r');
	    
	    % Ask the user if they want to continue
    % 	if blobNumber < numberOfHeads
    % 		button = questdlg(message, 'Continue', 'Continue', 'Cancel', 'Continue');
    % 		if strcmp(button, 'Cancel')
    % 			break;
    % 		end
    % 	end
    end
   
end
%% Edge Detection
% Using edge detection to see if it helps separate the fish from the background.

    
function edgeDetect(grayimg)
%     [~, threshOut] = edge(threshedimg, 'roberts');
    
    edgeimg = edge(grayimg, 'canny');
    imshow(edgeimg);
    
    se = strel("square",1);
    
    closedimg = imclose(edgeimg, se);
    imshow(closedimg);
    
    filledimg = imfill(closedimg, 8,'holes');
    imshow(filledimg);
    filledimg = imfill(closedimg, 8,'holes');
    imshow(filledimg);
end