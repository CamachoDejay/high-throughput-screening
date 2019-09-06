function [ Cells_Contours] = LoadContours( contours_file_path )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if strcmp (contours_file_path(end), filesep )
    contours_file_path = contours_file_pat(1:end-1);
end
tmp = strfind(contours_file_path, filesep);
assert(length(tmp)>=3,'unexpected error')

if (exist(contours_file_path, 'file') == 2)
        
        C = load(contours_file_path);
        a = fieldnames(C);
        Cells_Contours = C.(a{1});
else 
    warning('could not find contours')
    
        Cells_Contours = [];
        
end
    

end

