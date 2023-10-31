% main.m

clc;
clear variables;
close all;

% Call the ReorientVentricle function
[outputImage, selectedDimension] = ReorientVentricle();

if ~isempty(outputImage)
    % Call the drawEndocardialBoundary function to draw the endocardial boundary
    drawEndocardialBoundary(outputImage, selectedDimension);
else
    disp('ReorientVentricle function did not return an image.');
end