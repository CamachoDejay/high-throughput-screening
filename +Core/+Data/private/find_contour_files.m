function [ subFolders ] = find_contour_files( main_path )
%FIND_CONTOUR_FILES Summary of this function goes here
%   Detailed explanation goes here
% parent_content = dir([main_path '/*.*']);
parent_content = dir([main_path]);

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
        else
            c_file_path = [main_path filesep...
                           subFolders(k).name...
                           filesep 'Cells_Contours.mat'];
            i_file_path = [main_path filesep...
                           subFolders(k).name...
                           filesep 'Cells_Int_Desc.mat'];
            s_file_path = [main_path filesep...
                           subFolders(k).name...
                           filesep 'Cells_Shap_Desc.mat'];
            f_file_path = [main_path filesep...
                           subFolders(k).name...
                           filesep 'Frame_Props.mat'];
                       
                       
            if ~(exist(c_file_path, 'file') == 2);
                c_file_path = [];
            end
            
            if ~(exist(i_file_path, 'file') == 2);
                i_file_path = [];
            end
            
            if ~(exist(s_file_path, 'file') == 2);
                s_file_path = [];
            end
            
            if ~(exist(s_file_path, 'file') == 2);
                f_file_path = [];
            end
            
             subFolders(k).contour_path = c_file_path;
             subFolders(k).intensD_path = i_file_path;
             subFolders(k).shapeD_path  = s_file_path;
             subFolders(k).frameinfo_path  = f_file_path;
             
             tmp = strfind(subFolders(k).name,'_Seq');
             subFolders(k).Well = subFolders(k).name(5:tmp-1);
             subFolders(k).Sequence = subFolders(k).name(tmp+4:end);
            
             
        end

    end
end
clear k dirFlags s1 s2 s3 parent_content
n_im = length (subFolders);

fields = {'date','bytes','isdir','datenum'};
subFolders = rmfield(subFolders,fields);

if isempty(subFolders)
    warning('Cant find contour files')
end
end

