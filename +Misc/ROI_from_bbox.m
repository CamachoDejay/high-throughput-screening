function [ ROI ] = ROI_from_bbox( bbox, df, y_dim, x_dim )
% calculate ROI values from bounding box
%   Detailed explanation goes here

ROI = round([bbox(1) - df, bbox(1) + bbox(3) + df,...
            bbox(2) - df, bbox(2) + bbox(4) + df]);
ROI(ROI<1) = 1;

if ROI(2) > y_dim
    ROI(2) = y_dim;
end
if ROI(4) > x_dim
    ROI(4) = x_dim;
end   
        

end

