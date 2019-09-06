clear
close all
clc

disp('Information related to CONTROL-------------')
disp('-------------------------------------------')
%% loading conotrol data
init_dir = 'C:\Data';
% load control
h=helpdlg('Please load the CONTROL data');
uiwait(h);
% control is a structure taht contains the data, the variable anmes and ids
% for the plate/well
[ control.data, control.ids, control.vars ] = CellsCmp.load_LDdata( init_dir );

%% Selecting the variables
[Selection,ok] = listdlg('PromptString',{'Select descriptors','to be use in model:','Hold CTRL for multiple choise'},...
                         'SelectionMode','multiple','ListString',control.vars);
if ok                      
    var4model = control.vars(:,Selection);
else
    error('No vars selected')
end

%% Help to find the number of components
[ explained ] = CellsCmp.svd_explained( control, var4model );
th = 80;
pc_sug = CellsCmp.explained_fig(explained,th);

%%
% number of principal components used in the model
prompt = {'Enter number of principal components used in model:'};
dlg_title = 'Input for PCA model';
num_lines = 1;
defaultans = {num2str(pc_sug)};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
pc = str2double(answer{:});

% calculating limit for the number of cells, we want to find a limit as to
% how much cells can there be in an experiment to be consisten with
% control. 
% finding the number of cells in control
varName = {'n cells 2'};
nCellData = CellsCmp.getNamedData(control, varName);
nc_control = mean(nCellData.data,2);
% threshold for the number of cells alive at timepoint 2, a threshold value
% of 0.8 means that 80% of the control data will be within threshold.
th_nc = 0.95;
Y = quantile(nc_control,th_nc);
% correction factor, had to be used later on many mutants were very
% abundant
Y = Y * 1.5;
nc_lim  = round(Y);

% creating PCA model
modelProps.PCnumber = uint16(pc); % it has to be numeric
modelProps.standardization = 'batch'; % 'batch' or 'global'
modelProps.max_cells = uint16(nc_lim); % can also be empty if no limit is to be set
modelProps.variables = var4model; % variables to be used for the generation of the model
[c_model, control] = CellsCmp.svd_control(control, modelProps);

%% figure control
hfig = figure(30);
CellsCmp.ld_scat_plot( hfig, control )

%% loading sample and comparing it to control
disp(' ')
disp('Information related to SAMPLE--------------')
disp('-------------------------------------------')

h=helpdlg('Please load the SAMPLE to compare');
uiwait(h);
% load sample
[ sample.data, sample.ids, sample.vars, sample.dir, noDataIds] = ...
                                          CellsCmp.load_LDdata( init_dir );

% Saving ids that have no data in case is needed later on 
if ~isempty(noDataIds)
    disp('Sample contains wells which had no data at all, saving a list')
    noData = cell2table(noDataIds,'VariableNames',{'Plate' 'Well'});
    writetable(noData,[sample.dir filesep 'NoDataWells_LD.csv'])
end

% Saving control data in case is needed later on 
save([sample.dir filesep 'ControlDataLD.mat'],'control','var4model')

% compare to WT
[idx_95, idx_99, SPE_val, T2_val, cleanSample, missData, highDens] = ...
                                          CellsCmp.svd_cmp(sample,c_model);
writetable(missData,[sample.dir filesep 'MissingDataWells_LD.csv'])
writetable(highDens,[sample.dir filesep 'HighDensityWells_LD.csv'])

% if idx_out = 0 then sample is same as control
% if idx_out = 1 then sample is above SPE limit only
% if idx_out = 2 then sample is above T2 limit only
% if idx_out = 3 then sample is above both limits
str95 = cell(size(idx_95));
str95(idx_95==0) = {'Same as control'};
str95(idx_95==1) = {'Above SPE lim'};
str95(idx_95==2) = {'Above T2 lim'};
str95(idx_95==3) = {'Above both lims'};

str99 = cell(size(idx_99));
str99(idx_99==0) = {'Same as control'};
str99(idx_99==1) = {'Above SPE lim'};
str99(idx_99==2) = {'Above T2 lim'};
str99(idx_99==3) = {'Above both lims'};

outT1 = cell2table(...
       cat(2,cleanSample.ids,str95,str99,num2cell(SPE_val),num2cell(T2_val)),...
    'VariableNames',{'Plate' 'Well' 'limit95' 'limit99' 'SPEval' 'T2val'});

vn = c_model.var_names;
for i = 1:length(c_model.var_names)
    n_cells_idx = vn{i};
    n_cells_idx(strfind(n_cells_idx,' ')) = [];
    n_cells_idx(strfind(n_cells_idx,'-')) = [];
    vn{i} = n_cells_idx;
end

[sdata] =  cleanSample.data;
outT2 = array2table(sdata,'VariableNames',vn);
outT1 = cat(2,outT1,outT2);

writetable(outT1,[sample.dir filesep 'SampleVsControlLD.csv'])
save([sample.dir filesep 'LDcmpModel.mat'],'c_model')
disp(['N of wells out of control (lim 99): ' num2str(sum(idx_99~=0))])
disp(['% of wells out of control (lim 99): ' num2str(round(sum(idx_99~=0)*100/length(idx_99),1))])
disp('All done, output saved')
return

%% extra figures
idx2show = 1;
idval = idx_99(idx2show);
P_str = cleanSample.ids{idx2show,1};
P_str(strfind(P_str,'_')) = ' ';
t_str = {['Plate: ' P_str];...
         ['Well: ' cleanSample.ids{idx2show,2}...
                 '; SPE: ' num2str(SPE_val(idx2show),3)...
                 '; T^2: ' num2str(T2_val(idx2show),3)]};
switch idval
    case 0
        t_str = cat(1,t_str,'Same as control');
    case 1
        t_str = cat(1,t_str,'Different in SPE');
    case 2
        t_str = cat(1,t_str,'Different in T2');
    case 3
        t_str = cat(1,t_str,'Different in both SPE and T2');
end
disp(t_str)

hfig = figure(30);
CellsCmp.ld_scat_plot( hfig, control, cleanSample.data(idx2show,:))


[sdata] =  cleanSample.data;
[cdata] =  CellsCmp.getNamedData(control,c_model.var_names);
cdata = cdata.data;
y2show = sdata(idx2show,:);

figure(21)
if length(c_model.var_names)<=12
    last_i = length(c_model.var_names);
else
    last_i = 12;
end
for i = 1:last_i
subplot(4,3,i)
histogram(cdata(:,i))
hold on
plot([y2show(i) y2show(i)], ylim,'linewidth',2)
hold off
title(c_model.var_names(i))
end