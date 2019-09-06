function  error = AnalyzeSingleFile( PathName, FileName, cell_props)
%Takes an image file and calculates the cell boundaries. Then saves this
%information in a mat file.
%   Detailed explanation goes here

% % % test_vector = [];

%% load data using bioformat
error.msg = 'no error';
error.data = [];
try
    % Code to be executed goes here.
    bio_for_data = bfopen([PathName filesep FileName]);
    n_frames = size(bio_for_data,1);
    time_stamp = zeros(n_frames,1);
    for i = 1:n_frames
        ht = bio_for_data{i,2};
        if ht.containsKey('timestamp #1')
            time_stamp(i) = ht.get('timestamp #1');
            continue
        else
            keys_char = char(ht.keySet);
            test = strfind(keys_char, 'timestamp #1');
            assert(~isempty(test),'Problems with time stamp')
            sep  = strfind(keys_char, ', ');
            tidx = test(end);
            sep  = sep(sep < tidx);
            idx1 = sep(end);
            KeyName = keys_char(idx1+2:tidx+11);
            
            assert(ht.containsKey(KeyName), 'Problems with time stamp')
            ts = ht.get(KeyName);
            if isnumeric(ts)
                time_stamp(i) = ts;
            elseif ischar(ts)
                time_stamp(i) = str2double(ts);
            else
                error('dont know how to handle the time stamp value');
            end
            
        end
        
    end
    
catch
    disp('An error occurred while retrieving information from file');
    disp(['file name was: ' FileName]);
    disp('Execution will continue.');
    error.msg = 'problems with bio format';
    error.data =  FileName;
    return
end


%% change bio format data into my data convention

[ data ] = LoadTools.reformat_bioForData( bio_for_data );
clear bio_for_data
data.PathName = PathName;
data.FileName = FileName;
clear FileName

%% figure optional
% currentFrame     = 1;
% disp_data       =data.movie(currentFrame).Image; 
% i_lims      = [min(disp_data (:)) max(disp_data (:))];
% imshow(disp_data,[min(i_lims(:)) max(i_lims(:))])
% clear currentFrame disp_data i_lims 

%% edge detection
method_list = {'simple', 'opening_closing', 'adaptive_histogram','adaptive_histogram_new', 'top_hat'};
method_name = method_list{4};
min_size = cell_props.min_size_px; % in pixels
do_figure = false;

h = waitbar(0,'Please wait...');

% for the moment we take several frames of the same well at the same time
% point to get a good amount of total detected cells. Here we iterate over
% these frames. 
for i_frame = 1:data.n_frames
    in_frame = data.movie(i_frame).Image;
    % initial cell detection
    [ BWfilled ] = CellSegmentation.phaseContrast( in_frame, min_size, method_name, do_figure );
    data.movie(i_frame).initial_outlines = bwperim(BWfilled);
    
    % identifies all cells in BWfilled
    [B,L]     = bwboundaries(BWfilled,'noholes');
    
    % calculates parameters for each region indentified (cell)
    stats     = regionprops(L, in_frame,'Centroid','BoundingBox',...
                            'PixelIdxList','PixelValues','Image');
    
    % estimation og background level in the frame
    %   init of frame_props
    data.frame_props(i_frame) = struct('MeanInt',[],'IntHist',[],...
                                       'BGVal',[],'BGFWHM',[],...
                                       'Frame',i_frame,'Well',[],'Seq',[],'ImSize',[],'TimeStamp',[]);
                                   
    %   now I fill in the timestamp information
    data.frame_props(i_frame).TimeStamp = time_stamp(i_frame);
   
    %   now we fill in the BG information
    [ data.frame_props(i_frame) ] = CellSegmentation.frame_bg_estimation( in_frame, BWfilled, data.frame_props(i_frame) );
    
    % find well and sequence information from the filename
    [ data.frame_props(i_frame) ] = Misc.find_well_seq( data.FileName, data.frame_props(i_frame) );
    
    data.frame_props(i_frame).ImSize = size(in_frame);
            
    % Iterates over cells
    for cell_k = 1:length(B)
        
        cell_k_struct = struct('Well',data.frame_props(i_frame).Well,...
                               'Seq',data.frame_props(i_frame).Seq,...
                               'Frame',i_frame,'CellNumber',cell_k);
        
        cell_k_struct.Boundary = B{cell_k,1};
        
        cell_k_struct.Boundary_S = CellSegmentation.smoothBoundary( cell_k_struct.Boundary );         
        
        cell_k_struct.Boundary_RS = ...
                         CellSegmentation.resampleBoundary( cell_k_struct.Boundary_S, 500 );
        
        cell_k_struct.Centroid = stats(cell_k).Centroid;
        
        bbox = stats(cell_k).BoundingBox;
        cell_k_struct.BoundingBox = bbox;
                
        [ ROI ] = Misc.ROI_from_bbox( bbox, 10, data.y_dim, data.x_dim );
        cell_k_struct.ROI = ROI;
        
        cell_k_struct.CropImage = in_frame(ROI(3):ROI(4),ROI(1):ROI(2));
        
        n_pixels = length(stats(cell_k).PixelValues);
        mean_int = data.frame_props(i_frame).MeanInt;
        n_counts = ((sum(stats(cell_k).PixelValues)...
                  /n_pixels) - mean_int)./mean_int;       

        cell_k_struct.PixelNumber = n_pixels;
        
        cell_k_struct.CountsRelative = n_counts;
        
        % now the important question is if the current region is really a
        % cell or if it is a false positive. To try to clean some of the
        % data we do the following. 1) cell must be larger than certain
        % number of pixels.
        
        f_bg = 1.2;
        [ cell_k_struct] = CellSegmentation.isAcell( cell_props,...
                                                        cell_k_struct,...
                                                        f_bg,...
                                                        data.frame_props(i_frame));
        
        data.cell_properties.frame(i_frame).cell(cell_k) = cell_k_struct;        
        clear tmp ROI cell_k_struct
    end
    waitbar(i_frame/data.n_frames)
    
end

close(h)

FileName = data.FileName;
out_dir = [PathName filesep 'Contours' filesep FileName(1:find(FileName == '.')-1)];
mkdir(out_dir)

Cont_fields = {'Well';'Seq';'Frame';'CellNumber';'IsCell';'Boundary';'Boundary_S';'Boundary_RS';'Centroid';'BoundingBox';'ROI';'CropImage'};
IntD_fields = {'Well';'Seq';'Frame';'CellNumber';'IsCell';'CountsRelative';'NegPix';'PosPix';'CellMeanInt';'DarkTest';'CellBrigthVal';'UnderPressure';'HaloNegPix';'HaloPosPix';'HaloMeanInt';'HaloDarkVal';'HaloBrightVal';'cell_counts_1';'cell_counts_2';'cell_counts_3';'cell_counts_4';'cell_counts_5';'cell_counts_6';'cell_counts_7';'cell_counts_8';'halo_counts_1';'halo_counts_2';'halo_counts_3';'halo_counts_4';'halo_counts_5';'halo_counts_6';'halo_counts_7';'halo_counts_8'};
Shap_fields = {'Well';'Seq';'Frame';'CellNumber';'IsCell';'PixelNumber';'CellWidth'};
if isfield(data,'cell_properties')
    Cells_data = cat(2,data.cell_properties.frame(:).cell);
    n = size(Cells_data,2);
    
    Cells_Contours = [];
    for j = 1 : length(Cont_fields)
        Cells_Contours(n).(Cont_fields{j}) = [];
        [Cells_Contours(:).(Cont_fields{j})] =  deal(Cells_data.(Cont_fields{j}));
    end
    
    Cells_Int_Desc = [];
    for j = 1 : length(IntD_fields)
        Cells_Int_Desc(n).(IntD_fields{j}) = [];
        [Cells_Int_Desc(:).(IntD_fields{j})] =  deal(Cells_data.(IntD_fields{j}));
    end
    
    Cells_Shape_Desc = [];
    for j = 1 : length(Shap_fields)
        Cells_Shape_Desc(n).(Shap_fields{j}) = [];
        [Cells_Shape_Desc(:).(Shap_fields{j})] =  deal(Cells_data.(Shap_fields{j}));
    end

    
    fil_name = [out_dir filesep 'Cells_Contours.mat'];
    save(fil_name, 'Cells_Contours')
    
    fil_name = [out_dir filesep 'Cells_Int_Desc.mat'];
    save(fil_name, 'Cells_Int_Desc')
    
    fil_name = [out_dir filesep 'Cells_Shap_Desc.mat'];
    save(fil_name, 'Cells_Shape_Desc')
else
    disp(['No cells found in file: ' FileName])
end

if isfield(data,'frame_props')
    Frame_Props    = cat(2,data.frame_props(:));
    fil_name = [out_dir filesep 'Frame_Props.mat'];
    save(fil_name, 'Frame_Props')
else
    warning('Something very strange, there in no frame information')
    
end

end

