function [ f_porps] = LoadFProps( file_path )
%LoadFProps Summary of this function goes here
%   Detailed explanation goes here

if strcmp (file_path(end), filesep )
    file_path = file_path(1:end-1);
end
tmp = strfind(file_path,'\');
assert(length(tmp)>=3,'unexpected error')

if (exist(file_path, 'file') == 2);
        
        C = load(file_path);
        a = fieldnames(C);
        f_porps = C.(a{1});
else 
    warning('could not find contours')
    
        f_porps = [];
        
end
    

end

