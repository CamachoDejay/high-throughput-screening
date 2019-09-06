% Main script for the cell outline determination.
%   note that only files of known extension will be analyzed.

clc 
close 
clear

%%%%%%%%%%%%% USER INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Inputs for loading of files
known_extensions = {'.nd2'};
% note that for the moment the loading of images is adapted to our personal
% experiment. If you make your experiments using a different instrument or
% saving in a different format you will ahve to modify the function
% LoadTools.reformat_bioForData.

%
cell_props.min_size_px  = 220; % smallest size a cell can have
cell_props.min_width_px = 9.8;   % smallest width a cell can have
cell_props.dark_per     = 20;  % smalles percentage of the cell that must 
                               % darker than background
cell_props.remove_round_cells   = true;   % remove small round cells
cell_props.round_size_threshold = 300;
% Do you want to do parallel computing? its faster but you can not see
% figures.
do_parcomputing = true;

% Live dead determination is done later now

%%%%%%%%%%%%% END OF USER INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% For running test mode and see in details the output images and so on
%  Do not use if you dont know what you are doing
cell_props.test_mode    = false;
if cell_props.test_mode
    do_parcomputing = false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% path to tiff file, regardless of it is a stack or not  
init_dir = 'D:\Rafa\Results';
[main_PathName] = uigetdir(init_dir, 'Select the directory that contains all plates to be analyzed');
clear init_dir                             

% Find all folders in the directory
[ Folders ] = LoadTools.subFolderList( main_PathName );

for dir_i = 1:length(Folders)
    sub_dir_PathName = [main_PathName filesep Folders(dir_i).name];
    % Find all image files in the directory
    ListOfImageNames = LoadTools.imFilesInDir(sub_dir_PathName,known_extensions);


    % now we run analysis
    bad_files = {};
    if do_parcomputing
        parfor file_indx = 1:length(ListOfImageNames)
            FileName = ListOfImageNames{file_indx};
            if ~isempty(FileName)
                error = CellSegmentation.AnalyzeSingleFile( sub_dir_PathName, FileName, cell_props);
                if strcmp(error.msg, 'problems with bio format')
                    bad_files = {bad_files, error.data};
                end           
            end

        end    

    else
        for file_indx = 1:length(ListOfImageNames)
            FileName = ListOfImageNames{file_indx};
            if ~isempty(FileName)
                error = CellSegmentation.AnalyzeSingleFile( sub_dir_PathName, FileName, cell_props);
                if strcmp(error.msg, 'problems with bio format')
                    bad_files = {bad_files, error.data};
                end

            end

        end
    end

    set_dir = [sub_dir_PathName filesep 'Contours' filesep 'Run_settings' filesep];
    mkdir(set_dir)
    save([set_dir 'cell_props.mat'],'cell_props');
    save([set_dir 'bad_files.mat'],'bad_files');       
    disp(['DONE for folder: ' Folders(dir_i).name])
end

%% 
disp('DONE DONE DONE')

