function calculate(Well_directory)
%CALCULATE calculates shape descriptors for all celss withing a contours
%file
%   Detailed explanation goes here


c_file_path = [Well_directory filesep 'Cells_Contours.mat' ];
s_file_path = [Well_directory filesep 'Cells_Shap_Desc.mat' ];

% loading relevant information
[ Cells_Contours] = Misc.LoadContours( c_file_path );
[ Cells_SD] = Misc.LoadContours( s_file_path );

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
%                 do_figures = false;
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

