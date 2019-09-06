clear
close all
clc

%% load models

which_model = '4_unk';
            
% model for classification of shapes.
if strcmp(which_model,'4_unk')
    data = load([cd filesep 'models' filesep 'Shapes' filesep 'model_4classes_bul_unk_170719.mat'],'model','varlabels','ClassNames', 'AllowedConfu');
    
    wanted_vars_S = data.varlabels;
    
    ClassNames = data.ClassNames;
    
    AllowedConfu = data.AllowedConfu;

else
    error('Since 2017-07-19 we decided that all other models are outdates')
end
modelS  = data.model;

% load model for classification of live/dead status.
load([cd filesep 'models' filesep 'LD' filesep 'model04.mat'],'model_3LV')
load([cd filesep 'models' filesep 'LD' filesep 'model04.mat'],'varlabels')
% we choose the most widely applicable model
modelLD = model_3LV;
% THIS IS SUPER IMPORTANT USER INPUT
%   LIVE DEAD INPUTS
%   variables that are wanted to calculate the LD status
wanted_vars_LD = varlabels;
 

%store information
LDmodelData.model = modelLD;
LDmodelData.wanted_vars = wanted_vars_LD;
clear model_3LV varlabels modelLD wanted_vars_LD

ShapemodelData.model = modelS;
ShapemodelData.wanted_vars = wanted_vars_S;
ShapemodelData.ClassNames = ClassNames;
ShapemodelData.Allowed    = AllowedConfu;
clear AllowedConfu ClassNames wanted_vars_S modelS
clear data

%% Find plates
nt_expected  = 4; % number of time points expected

% path to main folder containing all the contours folders
init_dir = 'C:\Data';
[main_dir] = uigetdir(init_dir, 'Select the directory that contains all plates to be analyzed');
clear init_dir                             

% Find all folders in the directory
[ PlateFolders ] = LoadTools.subFolderList( main_dir );

% create pool object
if isempty(gcp('nocreate'))
    poolobj = parpool;
else
    poolobj = gcp;
end

%% lets look at a plate

parfor P_dir_i = 1:length(PlateFolders) % parfor can go here
    sub_dir_PathName = [main_dir filesep PlateFolders(P_dir_i).name];
    plate_i_path = [sub_dir_PathName filesep 'Contours' ];
    if isdir(plate_i_path)
        
        % lets look at a Plate
        [ LD, SStats_multi, SCounts_multi, SStats_binary, SCounts_binary  ] = ...
                                      Misc.getClassStats( plate_i_path,...
                                                          nt_expected,...
                                                          LDmodelData,...
                                                          ShapemodelData );

        % save data to a csv file
        t_filename = [plate_i_path filesep 'class_live_dead_stats.csv'];
        writetable(LD,t_filename)

        t_filename = [plate_i_path filesep 'class_multi_' which_model '_stats.csv'];
        writetable(SStats_multi,t_filename)

        t_filename = [plate_i_path filesep 'class_multi_' which_model '_counts.csv'];
        writetable(SCounts_multi,t_filename)

        t_filename = [plate_i_path filesep 'class_binary_' which_model '_stats.csv'];
        writetable(SStats_binary,t_filename)

        t_filename = [plate_i_path filesep 'class_binary_' which_model '_counts.csv'];
        writetable(SCounts_binary,t_filename)
        
        disp(['DONE for plate: ' PlateFolders(P_dir_i).name])
%         waitbar(P_dir_i / length(PlateFolders))
        
    end
    
end

disp('DONE DONE DONE')




