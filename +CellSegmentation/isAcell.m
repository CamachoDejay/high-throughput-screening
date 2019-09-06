function [ cell_struct ] = isAcell( cell_props, cell_struct,...
                                                        f_bg,...
                                                        frame_props)
% now the important question is if the current region is really a cell or
% if it is a false positive. To try to clean some of the data we do the
% following. 
%   Detailed explanation goes here

% if we are in test mode then we do figures
test_mode = cell_props.test_mode;

% information coming from the frame, this is used for intensity related
% calculations.
BGVal  = frame_props.BGVal;
BGFWHM = frame_props.BGFWHM;

% cell must be larger than certain number of pixels.
size_thresh        = cell_props.min_size_px;
remove_round_cells = cell_props.remove_round_cells;

% information that I will use form the cell
boundary_k  = cell_struct.Boundary;
n_pixels    = cell_struct.PixelNumber;

% init information for calculation of int descriptors
c_n       = 8;
edges = linspace(0,2,c_n+1);
assert(length(edges)>1)
count_names = cell((length(edges)-1)*2,1);
count_vals  = cell((length(edges)-1)*2,1);

for i = 1 : length(edges)-1;
    count_names(i,1) = {['cell_counts_' num2str(i)]};
    count_names(length(edges)-1+i,1) = {['halo_counts_' num2str(i)]};
end

% init of other variables        
is_cell  = false;
is_round = false;
right_width = false;
r_area = [];
cell_width = [];
cell_dark_test = [];
cell_bright_test = [];
under_pressure = [];

cell_mean_int = [];
cell_dark_val = [];
cell_brig_val = [];

halo_dark_test   = [];
halo_bright_test = [];
halo_mean_int    = [];
halo_dark_val    = [];
halo_brig_val    = [];

% now the code really starts

% 1) cell must be larger than certain number of pixels.
large_enough = n_pixels > size_thresh;

% 2) if cell is large enough, then I want to check if it is round, and if
% it has the right width

if large_enough
    % Then cell is large enough
    
    % Test if the cell, which should look like a snake, has appropriate
    % width
    width_thresh      = cell_props.min_width_px;
    [ cell_width ] = CellSegmentation.cellWidth( boundary_k' );
    right_width = cell_width > width_thresh;
    
    % Do I want to check if cell is small and round?
    if remove_round_cells
        % Then I want to check if cell is small and round
        % get thres value form cell_props
        size_thres_round   = cell_props.round_size_threshold;
        if n_pixels < size_thres_round;
            % calculation of roundness by area
            [ ~, r_area ] = roundness( boundary_k' );
            % thresholding
            is_round = r_area > 0.82;            
        end
    end
end

% 3) if the cell has teh right shape then it should also have an intensity
% that makes sense.

if all([large_enough, right_width, ~is_round])

    % cell seems to have the right shape. Now is this is a cell
    % then it must also contain some darker than BG features,
    % and further it can not contain only brighter than BG
    % features.
    % calculation of the pixel values for cell and halo areas
    dilation_pix = 10;
    [ cell_stats, halo_stats ] = CellSegmentation.getIntStats( cell_struct,...
                                                            dilation_pix );
    

    % intensity of the cell relative to the background
    cell_int_rel = double(cell_stats.PixelValues) ./ BGVal;
    
    Thres_low   = 1 - (f_bg*BGFWHM / BGVal);
    Thres_high  = 1 + (f_bg*BGFWHM / BGVal);
        
%     cell_int_rel = double(cell_stats.PixelValues) - BGVal;
%     cell_int_rel = cell_int_rel ./  BGFWHM;
    
    % number of pixels that are darker than BG by at least one FWHM
    cell_dark_test     = sum(cell_int_rel < Thres_low) / n_pixels;
    % number of pixels that are brighter than BG by at least one FWHM
    cell_bright_test   = sum(cell_int_rel > Thres_high) / n_pixels;
    % mean int of the cell relative to BG value
    cell_mean_int = mean(cell_int_rel);
    % mean value of the dark pixels
    cell_dark_val = mean(cell_int_rel(cell_int_rel < 1));
    % mean value of the bright pixels
    cell_brig_val = mean(cell_int_rel(cell_int_rel > 1));
    % is the cell under pressure
    under_pressure = any(cell_brig_val>f_bg);

    % for the region to be considered a cell dark_per% of the
    % cell must be darker than background, less than 80% must
    % be brighter than the cell.
    dark_propor = cell_props.dark_per / 100;
    is_cell = cell_dark_test > dark_propor & cell_bright_test < 0.80;    
    

end

if is_cell
    % then I want to calculate extra descriptors of intensity that will be
    % later used to classify the cell as alive or dead.
    
    %     figure(1)
    %     histogram(cell_int_rel,edges,'Normalization','probability');
    [N_c] = histcounts(cell_int_rel,edges,'Normalization','probability');
    count_vals(1:length(edges)-1) = num2cell(N_c);
    
    h_n_pixels = length(halo_stats.PixelValues);
    
    %instentisy of the halo relative to BG
    halo_int_rel = double(halo_stats.PixelValues) ./ BGVal;
    
    
%     halo_int_rel = double(halo_stats.PixelValues) - BGVal;
%     halo_int_rel = halo_int_rel ./  BGFWHM;
    
    halo_dark_test     = sum(halo_int_rel < Thres_low) / h_n_pixels;
    halo_bright_test   = sum(halo_int_rel > Thres_high) / h_n_pixels;
    halo_mean_int = mean(halo_int_rel);
    halo_dark_val = mean(halo_int_rel(halo_int_rel < 1));
    halo_brig_val = mean(halo_int_rel(halo_int_rel > 1));
    
%     figure(2)
%     histogram(halo_int_rel,edges,'Normalization','probability');
    
    [N_h] = histcounts(halo_int_rel,edges,'Normalization','probability');
    count_vals(length(edges):end) = num2cell(N_h);
end

if test_mode
    
    ROI         = cell_struct.ROI;
    crop_im     = cell_struct.CropImage;
%     f_size = frame_props.ImSize;
    
    figure(2)
    c      = boundary_k;
    c(:,1) = c(:,1) - ROI(3) + 1;
    c(:,2) = c(:,2) - ROI(1) + 1;
    im     = crop_im;   %%%% IS IT NEEDED?
    imagesc(crop_im), axis image
    hold on
    plot(c(:,2),c(:,1),'b-')
    hold off
    title_str = ['size: ' num2str(n_pixels,4) ';'];
    
    if ~large_enough
        title_str = [title_str ' cell is NOT large enough;'];
    end
    
    if and(large_enough,is_round)
        title_str = [title_str ' cell is ROUND;'];
    end
    
    if and(large_enough, ~right_width)
        title_str = [title_str ' width: ' num2str(cell_width,3) ...
              ' cell is NOT broad enough'];
    end
    
    if all([large_enough, right_width, ~is_round])
        Thres_low = BGVal - f_bg*BGFWHM;
        Thres_high = BGVal + f_bg*BGFWHM;
%         G_l_ids = stats.PixelIdxList(stats.PixelValues < Thres_1);
        G_l_ids = cell_stats.PixelIdxList(cell_stats.PixelValues < Thres_low);
%         R_l_ids = stats.PixelIdxList(stats.PixelValues > Thres_2);
        R_l_ids = cell_stats.PixelIdxList(cell_stats.PixelValues > Thres_high);
        [G(:,1),G(:,2)] = ind2sub(size(im),G_l_ids);
%         G(:,1) = G(:,1) - ROI(3) + 1;
%         G(:,2) = G(:,2) - ROI(1) + 1;
        [R(:,1),R(:,2)] = ind2sub(size(im),R_l_ids);
%         R(:,1) = R(:,1) - ROI(3) + 1;
%         R(:,2) = R(:,2) - ROI(1) + 1;
        imagesc(im), axis image
        hold on
        plot(c(:,2),c(:,1),'b-')
        scatter(G(:,2),G(:,1),'g.' )
        scatter(R(:,2),R(:,1),'r.' )
        hold off
        title_str = [title_str ' G: ' num2str(cell_dark_test,3)...
                     '; R: ' num2str(cell_bright_test,3)...
                     '; width: ' num2str(cell_width,3)...
                     '; roundness: ' num2str(r_area,3)...
                     ' is cell: ' num2str(is_cell)];
         clear R G G_l_ids R_l_ids
    end
    
    title(title_str);
    waitforbuttonpress
    
    
end

cell_struct.IsCell = is_cell;
cell_struct.NegPix = cell_dark_test;
cell_struct.PosPix = cell_bright_test;
cell_struct.CellWidth = cell_width;

cell_struct.CellMeanInt  = cell_mean_int;
cell_struct.DarkTest = cell_dark_val;
cell_struct.CellBrigthVal = cell_brig_val;
cell_struct.UnderPressure = under_pressure;


cell_struct.HaloNegPix    = halo_dark_test;
cell_struct.HaloPosPix    = halo_bright_test;
cell_struct.HaloMeanInt   = halo_mean_int;
cell_struct.HaloDarkVal   = halo_dark_val;
cell_struct.HaloBrightVal = halo_brig_val;
        
for i = 1 : length(count_names);
    cell_struct.(count_names{i}) = count_vals{i};    
end


end

