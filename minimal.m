clear 
close all
clc

%% get path to image(s)
d = uigetdir(cd, 'select directory that contains images');

known_extensions = {'.tif'}; % {'.tif', '.nd2'};
% Find all image files in the directory
ListOfImageNames = LoadTools.imFilesInDir(d,known_extensions);


%% Cell segmentation of single image


[indx,tf] = listdlg('PromptString','Select an image:',...
                           'SelectionMode','single',...
                           'ListString',ListOfImageNames);
                       
FileName = ListOfImageNames{indx};
% user input for segmentation
cell_props.min_size_px  = 220; % smallest size a cell can have
cell_props.min_width_px = 9.8;   % smallest width a cell can have
cell_props.dark_per     = 20;  % smalles percentage of the cell that must 
                               % darker than background
cell_props.remove_round_cells   = true;   % remove small round cells
cell_props.round_size_threshold = 300;
cell_props.test_mode    = false;

%% segmentation
CellSegmentation.AnalyzeSingleFile( d, FileName, cell_props);

%% Calculation of shape descriptors
contour_dir = [d filesep 'Contours'];
tmp_idx = strfind(FileName, '.')-1;
wellSeq_dir = [contour_dir filesep FileName(1:tmp_idx)];
SDcalc.calculate(wellSeq_dir);
%% LD and Shape Classification
well_pointer.name = FileName(1:tmp_idx);
well_pointer.folder = contour_dir;
well_pointer.contour_path = [wellSeq_dir filesep 'Cells_Contours.mat'];
well_pointer.intensD_path = [wellSeq_dir filesep 'Cells_Int_Desc.mat'];
well_pointer.shapeD_path  = [wellSeq_dir filesep 'Cells_Shap_Desc.mat'];
well_pointer.frameinfo_path = [wellSeq_dir filesep 'Frame_Props.mat'];
Frame_Props = load([wellSeq_dir filesep 'Frame_Props.mat']);
Frame_Props = Frame_Props.Frame_Props;
well_pointer.Well = Frame_Props.Well;
well_pointer.Sequence = Frame_Props.Seq;
well_pointer.TimePoint = 1;

% load model for classification of live/dead status.
load([cd filesep 'models' filesep 'LD' filesep 'model04.mat'],'model_3LV')
load([cd filesep 'models' filesep 'LD' filesep 'model04.mat'],'varlabels')
% we choose the most widely applicable model
modelLD = model_3LV;
wanted_vars_LD = varlabels;
clear model_3LV varlabels 

% load model for shape classification
data = load([cd filesep 'models' filesep 'Shapes' filesep 'model_4classes_bul_unk_170719.mat'],'model','varlabels','ClassNames', 'AllowedConfu');
wanted_vars_S = data.varlabels;
ClassNames = data.ClassNames;
Allowed = data.AllowedConfu;
modelS  = data.model;
n_class     = length(ClassNames);
clear data

% loading data
[ x, names, id4liveDead, cpath, time_stamp ] = Misc.getValuesFromWellPointer(well_pointer);

% get live dead status and stats 
%   changing x into matrix containing variables expected by the
%   LD model
[ xld ] = Misc.getWantedVars( x, names, wanted_vars_LD );
%   calculating the LD status
[ ypredLD ] = ClassLD.ypred_modelSPE( modelLD, xld );
boolAlive =  logical( ypredLD(:,1) );

% storing values used to find live dead status
Ttable = array2table(xld, 'VariableNames', wanted_vars_LD);
Ttable.CellID = id4liveDead;
Ttable.Alive  = boolAlive;
% save data to a csv file
fname = ['LDClass_Well_' well_pointer.Well '_Seq_' well_pointer.Sequence '.csv'];
t_filename = [wellSeq_dir filesep fname];
writetable(Ttable,t_filename)

% get class status and stats 
%   changing x into matrix containing variables expected by the
%   Shape model
[ xs] = Misc.getWantedVars( x, names, wanted_vars_S );
%   shape class is only valid for live cells, boolAlive is used
%   to Index
xs(~boolAlive,:) = [];
id4Shape = id4liveDead(boolAlive,:);
%   calculating the class data
[~, ypredS_multi, ~, ypredS_binary] = ClassShapes.simcapred(xs,n_class,modelS);

Ttable = array2table(xs, 'VariableNames', wanted_vars_S);
Ttable.CellID = id4Shape;
Ttmp = array2table( ypredS_multi,  'VariableNames', ClassNames);
Ttable = [Ttable, Ttmp];
% save data to a csv file
fname = ['ShapeClass_Well_' well_pointer.Well '_Seq_' well_pointer.Sequence '.csv'];
t_filename = [wellSeq_dir filesep fname];
writetable(Ttable,t_filename)

%% load data

contour_dir = [d filesep 'Contours'];
tmp_idx = strfind(FileName, '.')-1;
wellSeq_dir = [contour_dir filesep FileName(1:tmp_idx)];


Frame_Props = load([wellSeq_dir filesep 'Frame_Props.mat']);
Frame_Props = Frame_Props.Frame_Props;

Cells_Contours = load([wellSeq_dir filesep 'Cells_Contours.mat']);
Cells_Contours = Cells_Contours.Cells_Contours;


bfdata = bfopen([d filesep FileName]);
[ data ] = LoadTools.reformat_bioForData( bfdata );
clear bfdata
assert(length(data.movie)==1, 'This was made for single frame tifs')
im = data.movie(1).Image;

% Figure that contains the contours
figure(1)
imagesc(im)
axis image
a = gca;
a.XTickLabel = [];
a.YTickLabel = [];
colormap gray
title(['Image for ' FileName]);

colors = {'magenta', 'green'};
hold on
n_contours = length(Cells_Contours);
for i = 1:n_contours
    C = Cells_Contours(i).Boundary_RS;
    isCell = Cells_Contours(i).IsCell;
    color = colors{isCell+1};
    plot(C(:,2), C(:,1), '-', 'Color', color, 'LineWidth', 2)
end
hold off

f = gcf;
pos = f.Position;
pos(3) = 700;
pos(4) = 700;
f.Position = pos;

clims = caxis;
%% figures for each cell
figure(2)
f = gcf;
pos = f.Position;
pos(3) = 1000;
pos(4) = 200;
f.Position = pos;
colormap gray


isCell = cat(1,Cells_Contours.IsCell);
nCells = sum(isCell);
cellIdx = find(isCell);

tCol = zeros(nCells,1);
for i = 1:nCells
    idx = cellIdx(i);
    cellIm   = Cells_Contours(cellIdx(i)).CropImage;
    col = size(cellIm,2);
    tCol(i) = col;
end

dWidth = tCol ./ sum(tCol);
colPos = cumsum(dWidth);
colPos = cat(1, 0, colPos(1:end-1));

for i = 1:nCells
    ax = axes('Position',[colPos(i) 0.1 dWidth(i) 0.7]);
    cellIm   = Cells_Contours(cellIdx(i)).CropImage;
    cellCont = Cells_Contours(cellIdx(i)).Boundary_RS;
    bBox     = Cells_Contours(cellIdx(i)).ROI;
    cent     = Cells_Contours(cellIdx(i)).Centroid;
    cent     = round(cent);
    
    id2find = ['W:' well_pointer.Well,...
               '_S:' well_pointer.Sequence,...
               '_F:1',...
               '_X:' num2str(cent(1)),...
               '_Y:' num2str(cent(2))];
    
    tmp = strcmp(id2find, id4liveDead);
    
    Alive = boolAlive(tmp);
    
    imagesc(cellIm)
    caxis(clims)
    hold on
    plot(cellCont(:,2)-bBox(1), cellCont(:,1)-bBox(3), '-g', 'LineWidth', 2)
    hold off
    axis image
    ax.XTickLabel = [];
    ax.YTickLabel = [];
    if Alive
        title('Alive')
        tmp = strcmp(id2find, id4Shape);
        yShape = ypredS_multi(tmp,:);
        yShape = boolean(yShape);
        if any(yShape)
            ShapeStr = ClassNames(yShape);
        else
            ShapeStr = {'Unknown/Bulge'};
        end
        
        title(cat(2,{'Alive'}, ShapeStr))

    else
        title({'Dead', 'No Shape'})
    end
end
