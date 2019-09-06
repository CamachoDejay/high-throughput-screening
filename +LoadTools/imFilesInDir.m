function [ ListOfImageNames ] = imFilesInDir( PathName, known_extensions )
%IMFILESINDIR Generates a list of images contained in the directory, only
%images of known extension are kept
%   Detailed explanation goes here

ImageFiles = dir([PathName '/*.*']);                             

% list of all files
ct = sum(~[ImageFiles.isdir]);
ListOfImageNames = cell(ct,1);

c=0;
for Index = 1:length(ImageFiles)
    if ~ImageFiles(Index).isdir
        baseFileName = ImageFiles(Index).name;
        tmp_ind = strfind(baseFileName,'.');
        assert(length(tmp_ind)==1,['File name can not contain a . :' baseFileName])
        tmp_str = baseFileName(tmp_ind:end);
        isKnown = sum( cell2mat( strfind( known_extensions,tmp_str))) == 1;
       
        
        if isKnown
            c=c+1;
            ListOfImageNames{c} = baseFileName;
            
        else
            warning((['I dont know/trust this file extension: ' tmp_str]))
            
        end
    end
end

ListOfImageNames(c+1:end,:) = [];
end

