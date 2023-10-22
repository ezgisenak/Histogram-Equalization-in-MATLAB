clc
clear
close all;

% Create a figure to display frames and histograms
mainFigure = figure;

% Create axes objects for displaying frames and histograms
axOriginalFrame = subplot(2, 3, 1); 
axOriginalHistogram = subplot(2, 3, 4);
axEqualizedFrame = subplot(2, 3, 2); 
axEqualizedHistogram = subplot(2, 3, 5); 
axMyEqualizedFrame = subplot(2, 3, 3); 
axMyEqualizedHistogram = subplot(2, 3, 6); 

% Open the video file
videoFilePath = 'dark_video.mp4'; % Replace with your video file name
videoObj = VideoReader(videoFilePath);

% Open the text file for writing
textFile = 'pixel_values_video.txt'; % Replace with your desired text file name
outputFilePath = 'matlab_output_video.txt';
histogramFilePath = 'matlab_histogram_video.txt';
equalizedHistogramFilePath = 'matlab_equalized_histogram_video.txt';
VHDLOutputFilePath = 'vhdl_output_video.txt';
VHDLHistogramPath = 'vhdl_equalized_histogram_video.txt';

fileID = fopen(textFile, 'w');
outputfileID = fopen(outputFilePath, 'w');
histogramfileID = fopen(histogramFilePath, 'w');
equalizedHistogramfileID = fopen(equalizedHistogramFilePath, 'w');
vhdlFileID = fopen(VHDLOutputFilePath, 'r');
vhdlHistogramID  = fopen(VHDLHistogramPath, 'r');

% Create a video writer object to save the processed video
outputVideo = VideoWriter('equalized_video.mp4', 'MPEG-4');
outputVideo.FrameRate = videoObj.FrameRate;
open(outputVideo);

% Loop through each frame
while hasFrame(videoObj)
    % Read the frame
    frame = readFrame(videoObj);

    % Convert the frame to grayscale
    grayFrame = rgb2gray(frame);

    % Perform histogram equalization
    equalizedFrame = histeq(grayFrame);

    % Get the dimensions of the frame
    [row, col] = size(equalizedFrame);
    no_of_pixels = row * col;

    H = uint8(zeros(row,col));

    freq = zeros(256,1);
    cdf = zeros(256,1);
    output = zeros(256,1);

    % Loop through each pixel and write the grayscale pixel values to the text file
    for i = 1:row          
        for j = 1:col
            pixelValue = grayFrame(i, j); % Get grayscale pixel value

            % Convert the pixel value to a binary string
            binaryString = dec2bin(pixelValue, 8);

            % Write the binary string to the file
            fprintf(fileID, '%s\n', binaryString);
        end
    end
    
    % Loop through each pixel and calculate histogram
    for i = 1:row          
        for j = 1:col
            value = grayFrame(i, j); % Get grayscale pixel value

            freq(value + 1) = freq(value + 1) + 1;
        end
    end

    % Write histogram values to the file as binary strings
    for i = 1:256
        fprintf(histogramfileID, '%s\n', dec2bin(freq(i), 15));
    end

    sum = 0;
    no_bins = 255;
    
    % Calculating Cumulative Probability
    for i = 1:size(freq)
    
       sum = sum + freq(i);
    
       cdf(i) = sum/no_of_pixels;
    
       output(i) = floor(cdf(i) * no_bins);
    
    
    end
    
    for i = 1:row
        for j = 1:col
            H(i,j) = output(grayFrame(i,j) + 1);
        end
    end
    
    for i = 1:row
        for j = 1:col
            fprintf(outputfileID, '%s\n', dec2bin(H(i,j), 8));
        end
    end

    % Write equalized histogram values to the file as binary strings
    for i = 1:256
        fprintf(equalizedHistogramfileID, '%s\n', dec2bin(output(i), 15));
    end

    % Display the original frame and histogram on the left side
    imshow(grayFrame, 'Parent', axOriginalFrame);
    histogram(axOriginalHistogram, grayFrame, 'BinMethod', 'auto', 'Normalization', 'probability');
    
    % Calculate the position of axOriginalHistogram
    posOriginalHistogram = get(axOriginalHistogram, 'Position');
    
    % Add text annotation above axOriginalHistogram
    annotation(mainFigure, 'textbox', [posOriginalHistogram(1) + 0.05, posOriginalHistogram(2) + posOriginalHistogram(4) + 0.01, posOriginalHistogram(3), 0.04], 'String', 'Original Histogram', 'FitBoxToText', 'on', 'EdgeColor', 'none');
    
    % Display the equalized frame and histogram on the right side
    imshow(equalizedFrame, 'Parent', axEqualizedFrame);
    histogram(axEqualizedHistogram, equalizedFrame, 'BinMethod', 'auto', 'Normalization', 'probability');
    
    % Calculate the position of axEqualizedHistogram
    posEqualizedHistogram = get(axEqualizedHistogram, 'Position');
    
    % Add text annotation above axEqualizedHistogram
    annotation(mainFigure, 'textbox', [posEqualizedHistogram(1) + 0.04, posEqualizedHistogram(2) + posEqualizedHistogram(4) + 0.01, posEqualizedHistogram(3) + 0.02, 0.04], 'String', 'Equalized Histogram', 'FitBoxToText', 'on', 'EdgeColor', 'none');
    
    % Display the my equalized frame and histogram on the left side
    imshow(H, 'Parent', axMyEqualizedFrame);
    histogram(axMyEqualizedHistogram, H, 'BinMethod', 'auto', 'Normalization', 'probability');
    
    % Calculate the position of axMyEqualizedHistogram
    posMyEqualizedHistogram = get(axMyEqualizedHistogram, 'Position');
    
    % Add text annotation above axMyEqualizedHistogram
    annotation(mainFigure, 'textbox', [posMyEqualizedHistogram(1) + 0.03, posMyEqualizedHistogram(2) + posMyEqualizedHistogram(4) + 0.01, posMyEqualizedHistogram(3), 0.04], 'String', 'My Equalized Histogram', 'FitBoxToText', 'on', 'EdgeColor', 'none');

    % Calculate the position of axOriginalFrame
    posOriginalFrame = get(axOriginalFrame, 'Position');

    % Add text annotation above axOriginalFrame
    annotation(mainFigure, 'textbox', [posOriginalFrame(1) + 0.06, posOriginalFrame(2) + posOriginalFrame(4) + 0.01, posOriginalFrame(3), 0.04], 'String', 'Original Video', 'FitBoxToText', 'on', 'EdgeColor', 'none');
    
    % Calculate the position of axEqualizedFrame
    posEqualizedFrame = get(axEqualizedFrame, 'Position');

    % Add text annotation above axEqualizedFrame
    annotation(mainFigure, 'textbox', [posEqualizedFrame(1) + 0.06, posEqualizedFrame(2) + posEqualizedFrame(4) + 0.01, posEqualizedFrame(3), 0.04], 'String', 'Equalized Video', 'FitBoxToText', 'on', 'EdgeColor', 'none');

    % Calculate the position of axMyEqualizedFrame
    posMyEqualizedFrame = get(axMyEqualizedFrame, 'Position');

    % Add text annotation above axMyEqualizedFrame
    annotation(mainFigure, 'textbox', [posMyEqualizedFrame(1) + 0.06, posMyEqualizedFrame(2) + posMyEqualizedFrame(4) + 0.01, posMyEqualizedFrame(3), 0.04], 'String', 'My Equalized Video', 'FitBoxToText', 'on', 'EdgeColor', 'none');

    % Write the equalized frame to the output video
    writeVideo(outputVideo, uint8(equalizedFrame));
    
    % Add a pause to control the frame display speed (adjust as needed)
    pause(1/videoObj.FrameRate);
    
    % Check if the main figure is still open
    if ~ishandle(mainFigure)
        break;
    end
end

% Close the video writer object
close(outputVideo);

% Close the text file
fclose(fileID);
