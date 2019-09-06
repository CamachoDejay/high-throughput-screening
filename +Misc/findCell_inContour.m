function [idx] = findCell_inContour(cell_id, Cells_Contours)
%FINDCELL_INCONTOUR Summary of this function goes here
%   Detailed explanation goes here

cent = cat(1,Cells_Contours.Centroid);
cent = round(cent);
 
X_str = cell_id(strfind(cell_id,'X:')+2 : strfind(cell_id,'Y:')-2);
Y_str = cell_id(strfind(cell_id,'Y:')+2 : end);

cell_idx = and(cent(:,1) == str2double(X_str), cent(:,2) == str2double(Y_str));
idx = find(cell_idx);

assert(length(idx)==1, 'more than one cell found, maybe you need more than X Y')
end

