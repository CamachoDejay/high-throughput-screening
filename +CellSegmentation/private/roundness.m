function [ metric_perim, metric_area ] = roundness( contour )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

[Perim]    = perimeter_li( contour );
[~,~,Area] = centroid_by_area( contour );
Area       = abs(Area);

metric_perim = Perim / (2*(pi*Area)^0.5);
metric_area  = 4 * pi * Area / ( Perim^2 );

% keep in mind that:
% metric_perim = 1 / (metric_area)^2
% thus this two metrics are nos independent from each other.

end

