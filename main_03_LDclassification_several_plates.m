clear all
close all
clc

% THIS IS SUPER IMPORTANT USER INPUT %%%%%%%%%%%%%%%%%%%%%%%
nt_expected  = 4;
%%%%%%%%%%%%%%% end of user inputs %%%%%%%%%%%%%%%%%%%%%%%%%

% load model for classification of live/dead status.
load([cd filesep 'models' filesep 'LD' filesep 'model04.mat'],'model_3LV')
load([cd filesep 'models' filesep 'LD' filesep 'model04.mat'],'varlabels')
% we choose the most widely applicable model
LDmodelData.model = model_3LV;

LDmodelData.wanted_vars = varlabels;
clear model_3LV varlabels 
             
% path to main folder containing all the contours folders
init_dir = 'C:\Data';
[main_PathName] = uigetdir(init_dir, 'Select the directory that contains all plates to be analyzed');
clear init_dir                             

% Find all folders in the directory
[ PlateFolders ] = LoadTools.subFolderList( main_PathName );

% create pool object
if isempty(gcp('nocreate'))
    poolobj = parpool;
else
    poolobj = gcp;
end

% h_im = waitbar(0,'Please wait processing plates...');

% TODO TODO TODO
disp('add parfor below')

for P_dir_i = 1:length(PlateFolders) % parfor can be placed here
    sub_dir_PathName = [main_PathName filesep PlateFolders(P_dir_i).name];
    contour_i = [sub_dir_PathName filesep 'Contours' ];
    if isdir(contour_i)
        
        % lets look at a Plate
        [ LDtotalT  ] = Misc.getClassLD( contour_i, nt_expected, LDmodelData );
        
        % save data to a csv file
        t_filename = [contour_i filesep 'live_dead_stats.csv'];
        writetable(LDtotalT,t_filename)
                       
        disp(['DONE for plate: ' PlateFolders(P_dir_i).name])
%         waitbar(P_dir_i / length(PlateFolders))
        
    end
    
end

disp('DONE DONE DONE')