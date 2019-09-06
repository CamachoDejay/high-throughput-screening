function [ subFolders, data_set_name ] = FindWellSubfolders( plate_contour_dir )
%UNTITLED Finds folders in a directory (Contours folder) that start with
%the key word "Well", it returns this list and the name of the data_set
%(Plate)
%   Detailed explanation goes here

if ~strcmp (plate_contour_dir(end), filesep )
    plate_contour_dir = [plate_contour_dir filesep];
end
tmp = strfind(plate_contour_dir, filesep);

assert(length(tmp)>=3,'unexpected error')

ind = tmp(end-2:end);


tmp_test = plate_contour_dir(ind(2)+1:ind(3)-1);
assert(strcmp(tmp_test,'Contours'),'Cant find the contours folder')

data_set_name = plate_contour_dir(ind(1)+1:ind(2)-1);

% parent_content = dir([plate_contour_dir '*.*']);
parent_content = dir(plate_contour_dir);

dirFlags = [parent_content.isdir];
% Extract only those that are directories.
subFolders = parent_content(dirFlags);
% Print folder names to command window.
for k = length(subFolders):-1:1
    s1  = subFolders(k).name;
    s2 = '.';
    s3 = '..';
    s4 = 'Well';
    if strcmp(s1,s2) || strcmp(s1,s3)
        subFolders(k) = [];
    else
        s1 = s1(1:4);
        if ~strcmp(s1,s4)
            subFolders(k) = [];
        end
        
    end
end

if isempty(subFolders)
    warning(['No well subfolder found! for dataset: ' data_set_name])
end

end

