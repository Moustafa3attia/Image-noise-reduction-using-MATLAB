% Source: https://www.mathworks.com/matlabcentral/answers/45268-noise-removal-from-colored-image
clc;	% Clear command window.
clear;	% Delete all variables.
close all;	% Close all figure windows except those created by imtool.
imtool close all;	% Close all figure windows created by imtool.
workspace;	% Make sure the workspace panel is showing.
fontSize = 15;


% Read the path of the image %%%%%%%%%%%%%%%%%%%% BE CAREFUL !! Change the path of the image and the name as desired !! %%%%%%%%%%%%%%%%%%%%%%
folder = fullfile('C:\Users\Moustafa\Documents\MATLAB\Noise Reduction\images');
baseFileName = 'lion.jpg';
% Get the full filename, with path prepended.
fullFileName = fullfile(folder, baseFileName);


% if file exists then 
if ~exist(fullFileName, 'file')
	% Didn't find it there.  Check the search path for it.
	errorMessage = sprintf('Error: %s does not exist.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
end

% Read the image from the path (as an actual image not just a path of a file)
inputImage = imread(fullFileName);


% Get the dimensions of the image.  numberOfColorBands equals the number of image array or the number of image channels (in our case I used RGB image which gives 3).
[rows columns numberOfColorBands] = size(inputImage);

h1 = figure;
figure(h1);
% Display the original image.
subplot(2, 2, 1);
imshow(inputImage);
title('Original Image', 'FontSize', fontSize);

% Enlarge figure to full screen.
set(gcf, 'Position', get(0,'Screensize')); 

% Generate a noisy image.  This has salt and pepper noise independently on
% each color channel so the noise may be colored.
noisyImage = imnoise(inputImage,'salt & pepper', 0.15);
subplot(2, 2, 2);
imshow(noisyImage);
title('Image with Salt and Pepper Noise', 'FontSize', fontSize);


if numberOfColorBands == 3
	%
	% That's a RGB image
	%
	% Extract the individual red, green, and blue color channels from the noisy RGB image.
	redChannel = noisyImage(:, :, 1); % Red channel
	greenChannel = noisyImage(:, :, 2); % Green channel
	blueChannel = noisyImage(:, :, 3); % Blue channel

	% Normally, the above variables are gray scaled
	% so we define new images just to display the channels in their correct colors
	% Source: https://www.mathworks.com/matlabcentral/answers/91036-split-an-color-image-to-its-3-rgb-channels#answer_100475
	a = zeros(size(inputImage, 1), size(inputImage, 2));
	just_red = cat(3, redChannel, a, a);
	just_green = cat(3, a, greenChannel, a);
	just_blue = cat(3, a, a, blueChannel);

	% Create another figure just for the 3 channels preview
	h2 = figure;
	figure(h2);
	set(gcf, 'Position', get(0,'Screensize')); 
	% Display the individual red, green, and blue color channels (w/o noise).
	subplot(2, 2, 1);
	imshow(just_red);
	title('Red Channel', 'FontSize', fontSize);
	subplot(2, 2, 2);
	imshow(just_green);
	title('Green Channel', 'FontSize', fontSize);
	subplot(2, 2, 3);
	imshow(just_blue);
	title('Blue Channel', 'FontSize', fontSize);

	% Median Filter the channels:
	redMF = medfilt2(redChannel, [5 5]);
	greenMF = medfilt2(greenChannel, [5 5]);
	blueMF = medfilt2(blueChannel, [5 5]);

	% Order-Statistics Filter the image (try and error with filter order)
	redOS = ordfilt2(redChannel,10,true(5));
	greenOS = ordfilt2(greenChannel,10,true(5));
	blueOS = ordfilt2(blueChannel,10,true(5));

	% Find the noise in the red.
	noisePixels = (redChannel == 0 | redChannel == 255);
	% Get rid of the noise in the red by replacing with median.
	noiseFreeRed1 = redChannel;
	noiseFreeRed1(noisePixels) = redMF(noisePixels);
	% Get rid of the noise in the red by replacing with Order-statistics
	noiseFreeRed2 = redChannel;
	noiseFreeRed2(noisePixels) = redOS(noisePixels);

	% Find the noise in the green.
	noisePixels = (greenChannel == 0 | greenChannel == 255);
	% Get rid of the noise in the green by replacing with median.
	noiseFreeGreen1 = greenChannel;
	noiseFreeGreen1(noisePixels) = greenMF(noisePixels);
	% Get rid of the noise in the green by replacing with Order-statistics
	noiseFreeGreen2 = greenChannel;
	noiseFreeGreen2(noisePixels) = greenOS(noisePixels);

	% Find the noise in the blue.
	noisePixels = (blueChannel == 0 | blueChannel == 255);
	% Get rid of the noise in the blue by replacing with median.
	noiseFreeBlue1 = blueChannel;
	noiseFreeBlue1(noisePixels) = blueMF(noisePixels);
	% Get rid of the noise in the blue by replacing with Order-statistics
	noiseFreeBlue2 = blueChannel;
	noiseFreeBlue2(noisePixels) = blueOS(noisePixels);


	% Reconstruct the noise free RGB image (Median)
	noiseFreeImage1 = cat(3, noiseFreeRed1, noiseFreeGreen1, noiseFreeBlue1);

	% Reconstruct the noise free RGB image (Order-statistics)
	noiseFreeImage2 = cat(3, noiseFreeRed2, noiseFreeGreen2, noiseFreeBlue2);


elseif numberOfColorBands == 1
	%
	% it's a grayscale image
	%	
	% Median Filter the image:
	medianFilteredImage = medfilt2(noisyImage, [5 5]);
	% Order-Statistics Filter the image (try and error with filter order)
	osFilteredImage = ordfilt2(noisyImage,10,true(5));

	% Find the noise.  It will have a gray level of either 0 or 255.
	noisePixels = (noisyImage == 0 | noisyImage == 255);
	
	% Get rid of the noise by replacing with median.
	noiseFreeImage1 = noisyImage; % Initialize
	noiseFreeImage1(noisePixels) = medianFilteredImage(noisePixels); % Replace.

	% Get rid of the noise by replacing with order-statistics
	noiseFreeImage2 = noisyImage; %Initialize
	noiseFreeImage2(noisePixels) = osFilteredImage(noisePixels);

end


% Back to the first figure to display the restored image (Median Filter)
figure(h1);
% Display the image.
subplot(2, 2, 3);
imshow(noiseFreeImage1);
title('Restored Image using Median Filter', 'FontSize', fontSize);



% Back to the first figure to display the restored image (order-statistics Filter)
figure(h1);
% Display the image.
subplot(2, 2, 4);
imshow(noiseFreeImage2);
title('Restored Image using order-statistics Filter', 'FontSize', fontSize);