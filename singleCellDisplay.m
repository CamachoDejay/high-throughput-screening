clear all
close all
clc

% get reference to contours dir
test = true;
while test
    cpath = uigetdir(cd,'path to contour folder');
    % user canceled
    if cpath == 0
        uiwait(msgbox('Leaving the program','Bye','modal'));
        break
    else
        try
            test = ~endsWith(cpath,[filesep 'Contours']);
        catch
            test = ~strcmp(cpath(end-8:end),[filesep 'Contours'] );
        end
        
        if test
            uiwait(msgbox('Incorrect path, does not finish with "Contours"',...
                'modal'));
        end
    end
    
end

%% get plate data
% get number of timepoints
prompt = {'Enter expected number of timepoints:'};
title = 'User Input';
dims = [1 20];
definput = {'4'};
answer = inputdlg(prompt,title,dims,definput);
nt_expected = str2double( answer{1} );

% get plate data
PlateData = Core.Data.PlateDataSet(cpath, nt_expected);

%% get well and t point
WellList = unique({PlateData.contour_paths.Well});
[indx,~] = listdlg('PromptString','Select a well:',...
                    'ListString',WellList,...
                    'SelectionMode','single');
Well = WellList{indx};


times = num2cell(1:nt_expected);
times = cellfun(@(x) num2str(x),times,'UniformOutput',false);
[indx,~] = listdlg('PromptString','Select a timepoint:',...
                    'ListString',times,...
                    'SelectionMode','single');
t2look = str2double( times{indx} );

% get well data
well_pointer = PlateData.findWell(Well, t2look);
WellData = Core.Data.WellDataSet(well_pointer);

%% plot single cells
nCells = WellData.info.cell_n;
dCell = 1;
while true
    
    prompt = {['Cell to image [max val ' num2str(nCells) '] <-1 to exit>:']};
    title = 'User Input';
    dims = [1 50];
    definput = {num2str(dCell)};
    answer = inputdlg(prompt,title,dims,definput);
    answer = str2double( answer{1} );
    if answer > 0 && answer <= nCells
        WellData.plotSingleImage(answer,'true')
    elseif answer > nCells
        uiwait(msgbox('Cell index is too large',...
                'modal'));
    else
        break
    end
    dCell = dCell + 1;
end