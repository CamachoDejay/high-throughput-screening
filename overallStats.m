clear
close all
clc

% path to main folder containing all the contours folders
init_dir = cd;
[main_dir] = uigetdir(init_dir, 'Select the directory that contains all plates');
clear init_dir                             

% Find all folders in the directory
[ PlateFolders ] = LoadTools.subFolderList( main_dir );

%% load all data
liveData = [];
shapeData = [];
totalFrames = 0;
h = waitbar(0,'Please wait going through your data...');

nPlates = length(PlateFolders);
for i = 1:nPlates
    tic;
    c_path = [main_dir filesep PlateFolders(i).name filesep 'Contours'];
    PlateData = Core.Data.PlateDataSet(c_path , 4);
    validWells = unique({PlateData.contour_paths.Well});
    nWells = length(validWells);
    nFrames = zeros(nWells,1);
    
    for j = 1:nWells
        % we always take the same number of frames for tpoints 2-4
        well_pointer = PlateData.findWell(validWells{j}, 2);
        WellData = Core.Data.WellDataSet(well_pointer);
        nFrames(j) = WellData.info.nFrames;
    end
    totalFrames = totalFrames + sum(nFrames);
    
    pi_path = [c_path filesep 'class_live_dead_stats.csv'];
    T = readtable([pi_path]);
    tmp = cell(size(T,1),1);
    tmp(:,1) = {PlateFolders(i).name};
    T.Plate = tmp;
    liveData = [liveData; T];
    
    pi_path = [c_path filesep  'class_binary_4_unk_counts.csv'];
    T = readtable([pi_path]);
    tmp = cell(size(T,1),1);
    tmp(:,1) = {PlateFolders(i).name};
    T.Plate = tmp;
    shapeData = [shapeData; T];
    
    waitbar(i / nPlates,h,...
    ['Please wait going through your data ' num2str(i) '/' num2str(nPlates)])
    
    tmp = toc;
    fprintf('time taken for this plate: %.0f [sec]\n', tmp )
    tmp = tmp*(nPlates-i)/60;
    fprintf('Approx time left: %.0f [minutes]\n', tmp )
    
end
close(h) 
clear i j nFrames nWells pi_path tmp validWells well_pointer
%%
nPlates = length(unique(liveData.Plate));
nWells = sum(liveData.File);

live = liveData.Live2;
dead = liveData.Dead2;
cellsWell2 = live+dead;
totalCWt2 = nansum(cellsWell2);
meanCWt2 = nanmean(cellsWell2);
stdCWt2 = nanstd(cellsWell2);

live = liveData.Live3;
dead = liveData.Dead3;
cellsWell3 = live+dead;
totalCWt3 = nansum(cellsWell3);
meanCWt3 = nanmean(cellsWell3);
stdCWt3 = nanstd(cellsWell3);

live = liveData.Live4;
dead = liveData.Dead4;
cellsWell4 = live+dead;
totalCWt4 = nansum(cellsWell4);
meanCWt4 = nanmean(cellsWell4);
stdCWt4 = nanstd(cellsWell4);

clc

fprintf('Overall stats----------\n')
fprintf('Total number of plates: %.0f \n', nPlates)
fprintf('Total number of valid Wells: %.0f \n', nWells)
fprintf('Total number of Frames analysed (per time point): %.0f \n', totalFrames)

fprintf('\nTimepoint 2 ----------\n')
fprintf('Total number of Cells analysed for time point 2: %.0f \n', totalCWt2)
fprintf('Mean number of Cells analysed for time point 2: %.0f +- %.0f \n', meanCWt2, stdCWt2)

fprintf('\nTimepoint 3 ----------\n')
fprintf('Total number of Cells analysed for time point 3: %.0f \n', totalCWt3)
fprintf('Mean number of Cells analysed for time point 3: %.0f +- %.0f \n', meanCWt3, stdCWt3)

fprintf('\nTimepoint 4 ----------\n')
fprintf('Total number of Cells analysed for time point 4: %.0f \n', totalCWt4)
fprintf('Mean number of Cells analysed for time point 4: %.0f +- %.0f \n', meanCWt4, stdCWt4)

% saving to file
fileID = fopen('OverallStats.txt','w');
fprintf(fileID,'Overall stats----------\n');
fprintf(fileID,'Total number of plates: %.0f \n', nPlates);
fprintf(fileID,'Total number of valid Wells: %.0f \n', nWells);
fprintf(fileID,'Total number of Frames analysed (per time point): %.0f \n', totalFrames);
fprintf(fileID,'\nTimepoint 2 ----------\n');
fprintf(fileID,'Total number of Cells analysed for time point 2: %.0f \n', totalCWt2);
fprintf(fileID,'Mean number of Cells analysed for time point 2: %.0f +- %.0f \n', meanCWt2, stdCWt2);
fprintf(fileID,'\nTimepoint 3 ----------\n');
fprintf(fileID,'Total number of Cells analysed for time point 3: %.0f \n', totalCWt3);
fprintf(fileID,'Mean number of Cells analysed for time point 3: %.0f +- %.0f \n', meanCWt3, stdCWt3);
fprintf(fileID,'\nTimepoint 4 ----------\n');
fprintf(fileID,'Total number of Cells analysed for time point 4: %.0f \n', totalCWt4);
fprintf(fileID,'Mean number of Cells analysed for time point 4: %.0f +- %.0f \n', meanCWt4, stdCWt4);
fclose(fileID);

disp('All saved to the file OverallStats.txt in the main path of the program')