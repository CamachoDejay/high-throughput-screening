% Main script for the calculation of shape descriptors.
%   note that only files of known extension will be analyzed.
clear
close all
clc

% path to main folder containing all the contours folders
init_dir = 'C:\Data';
[main_PathName] = uigetdir(init_dir, 'Select the directory that contains all plates to be analyzed');
clear init_dir                             

% Find all folders in the directory
[ PlateFolders ] = LoadTools.subFolderList( main_PathName );

if isempty(PlateFolders)
    warning('No plate folders found')
end
% create pool object - for par computing
if isempty(gcp('nocreate'))
    poolobj = parpool;
else
    poolobj = gcp;
end

% create wait bar so user knows all is going on ok
h_im = waitbar(0,'Please wait processing plates...');

for P_dir_i = 1:length(PlateFolders)
    % dir to plate
    sub_dir_PathName = [main_PathName filesep PlateFolders(P_dir_i).name];
    % dir to Contours folder of the particular plate
    contour_i = [sub_dir_PathName filesep 'Contours' ];
    % we check that the Contours folder does exist
    if isdir(contour_i)
        % look into the contours folder and find all subfolders that have
        % the keyword Well
        [ WellFolders ] = Misc.FindWellSubfolders( contour_i );
        % number of Well folders in the Contours diractory
        n_W = length(WellFolders);
        % now we iterate ofer all well folders
        parfor W_i = 1:n_W %% parfor can be placed here!!!!!!!!!!!!!!!!!!!!
            % getting sorted all the paths that could be of interest
            Well_directory = [contour_i filesep WellFolders(W_i).name];
            c_file_path = [Well_directory filesep 'Cells_Contours.mat' ];
%             i_file_path = [Well_directory '\Cells_Int_Desc.mat' ];
            s_file_path = [Well_directory filesep 'Cells_Shap_Desc.mat' ];
%             f_file_path = [Well_directory '\Frame_Props.mat' ];
            
            % loading relevant information
            [ Cells_Contours] = Misc.LoadContours( c_file_path );
            [ Cells_SD] = Misc.LoadContours( s_file_path );
%             [ Cells_IntD] = Misc.LoadContours( i_file_path );
%             [ f_props ]       = Misc.LoadFProps( f_file_path );
            
            % Check that there are cells in the Cells_Contours file
            if ~isempty(Cells_Contours)
                % number of cells - actually objects detected
                n_cells    = length(Cells_Contours);
                % now we iterate over each detected object (via our
                % segmentation algorithms)
                for cell_i = 1: n_cells 
                    % get info for the object/cell
                    c_info_i  = Cells_Contours(cell_i);
                    % check if object is a cell
                    IsCell    = c_info_i.IsCell;
                    % init SDs
                    [ SDvals, SDnames ] = SDcalc.calc_shape_descriptors([]);
                    % if object is a cell then we calculate the SD
                    if IsCell
                        % lets check that we have the info we need
                        assert(isfield(c_info_i, 'Boundary_RS'),'problem 001')       
                        % here we handle casses where no appropriate
                        % contour was found
                        if isempty(c_info_i.Boundary_RS)
                            warning('missing one contour')
                        else
                            % all is as it should so we calculate the SDs
                            do_figures = false;
                            [ SDvals, SDnames ] = ...
                                SDcalc.calc_shape_descriptors(c_info_i.Boundary_RS'); 
                        end

                    end
                    % now we store the values
                    for nn = 1:size(SDnames,1)
                        name_nn = SDnames{nn};
                        Cells_SD(cell_i).(name_nn) = SDvals{nn};
                    end
                end
                % saving has to be done in a function due to the use of
                % parfor
                Misc.ParForSave(s_file_path, Cells_SD)
            end

            
        end
        % we indicate to the user that all was done for the plate
        disp(['DONE for plate: ' PlateFolders(P_dir_i).name])
        % update waitbar
        waitbar(P_dir_i / length(PlateFolders))
    end
    
end

close(h_im)

% we indicate to the user that all is done
disp('DONE DONE DONE')








