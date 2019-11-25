clc, clear all;
[fName, pName] = uigetfile('*.tif');  
info = imfinfo(fName);
num_images = numel(info);


dummy3=1;
for i=3:3:num_images 
Data3(:,:,dummy3) = imread(fullfile(pName, fName),i);
 dummy3=dummy3+1; 
end

imageData3=double(Data3(:,:,1));
