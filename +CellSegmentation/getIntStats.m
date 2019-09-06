function [ cell_stats, halo_stats ] = getIntStats( cell_k_struct, dilation_pix )
%GETINTSTATS Summary of this function goes here
%   Detailed explanation goes here

% load relevant information from contour
c   = cell_k_struct.Boundary;
ROI = cell_k_struct.ROI;
im  = cell_k_struct.CropImage;

% shift contour so it lies within the CropImage dimentions. This
% has to be done because I save the contour using as reference the
% dimentions of the original image
c(:,1) = c(:,1) - ROI(3) + 1;
c(:,2) = c(:,2) - ROI(1) + 1;

% now we add the contour info to the iamge
BW          = false(size(im));
lin_idx     = sub2ind(size(BW), c(:,1), c(:,2));
BW(lin_idx) = true;

% image that contains the cell
BW_cell = imfill(BW, 'holes');

% image that contains the halo
SE      = strel('disk', dilation_pix, 8);
BW_tmp  = imdilate(BW_cell, SE);
BW_halo = and(BW_tmp, ~BW_cell);

% combine both areas
areas = (BW_cell+BW_halo.*2);

% calculation of stats
stats = regionprops(areas, im,'PixelIdxList','PixelValues');

% outputs
cell_stats = stats(1);
halo_stats = stats(2);

end

