% Histogram Equalization
clc
clear
close all

imagePath = 'dog_image.jpg';
histogramFilePath = 'matlab_equalized_histogram.txt';
outputFilePath = 'matlab_output_image.txt';
inputFilePath = fopen('vhdl_output_image.txt', 'rb');

pixelValues = [];
while ~feof(inputFilePath)
    % Read one line of the text file
    binaryLine = fgetl(inputFilePath);
    
    % Check if the line is empty (end of file)
    if isempty(binaryLine)
        break;
    end
    
    % Convert the binary line to an integer
    integerValue = bin2dec(binaryLine); % Convert binary to decimal
    
    % Store the integer in the array
    pixelValues = [pixelValues, integerValue];
end

output_image = reshape(pixelValues, 152, []);
output_image = output_image';
output_image = uint8(output_image);

% Open the txt file for writing
histogramfileID = fopen(histogramFilePath, 'w');
outputfileID = fopen(outputFilePath, 'w');

% Check if the file was opened successfully
if histogramfileID == -1
    error('Unable to open the histogram file for writing.');
end

% Check if the file was opened successfully
if outputfileID == -1
    error('Unable to open the output file for writing.');
end

originalImage = imread(imagePath);

grayImage = rgb2gray(originalImage);

figure
subplot(2, 4, 1)
imshow(grayImage)
title({'Original Grayscale Image', ''});
subplot(2, 4, 5)
histogram(grayImage)
title({'Histogram of Original Grayscale Image',''});

hgram = ones(1, 1) * prod(size(grayImage)) / 1;
J = histeq(grayImage, hgram);

subplot(2, 4, 2)
imshow(J)
title({'Image after histogram', 'equalization with built-in function'});
subplot(2, 4, 6)
histogram(J)
title({'Histogram of Image after histogram', 'equalization with built-in function'});

% Histogram Equalization without built-in histeq function:
[row, col] = size(grayImage);
no_of_pixels = row * col;
H = uint8(zeros(row,col));

freq = zeros(256,1);
cdf = zeros(256,1);
output = zeros(256,1);

% Calculating Probability
for i = 1:row          
    for j = 1:col
        value = grayImage(i, j);
        freq(value + 1) = freq(value + 1) + 1;
    end  
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
        H(i,j) = output(grayImage(i,j) + 1);
    end
end

for i = 1:row
    for j = 1:col
        fprintf(outputfileID, '%s\n', dec2bin(H(i,j), 8));
    end
end

subplot(2, 4, 3)
imshow(H)
title({'Image after histogram', 'equalization without built-in function'});
subplot(2, 4, 7)
histogram(H)
title({'Histogram of Image after histogram', 'equalization without built-in function'});


subplot(2, 4, 4)
imshow(output_image);
title({'Image after histogram equalization', 'in VHDL'});
subplot(2, 4, 8)
histogram(output_image)
title({'Histogram of Image after histogram', 'equalization in VHDL'});


% Write histogram values to the file as binary strings
for i = 1:256
    fprintf(histogramfileID, '%s\n', dec2bin(output(i), 14));
end




