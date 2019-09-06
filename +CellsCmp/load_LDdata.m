function [ data4LDcmp, ids, var_names, main_dir, ids_no_data ] = load_LDdata( init_dir )
%LOAD_LDDATA Load all data related to the LD comparison. Now cleaning of
%data occurs later on the code, once we know the variables to be used for
%the model.
%   Detailed explanation goes here

% path to main folder containing all the contours folders
[main_dir] = uigetdir(init_dir, 'Select the directory that contains all plates');
clear init_dir                             

% Find all folders in the directory
[ PlateFolders ] = LoadTools.subFolderList( main_dir );

data = [];
for i = 1:length(PlateFolders)
    pi_path = [main_dir filesep PlateFolders(i).name filesep 'Contours'...
                                            filesep 'live_dead_stats.csv'];
    T = readtable([pi_path]);
    tmp = cell(size(T,1),1);
    tmp(:,1) = {PlateFolders(i).name};
    T.Plate = tmp;
    data = [data; T];
end

% data_var_names = data.Properties.VariableNames;
nt  = (size(data,2)-3)/6; % number of time points expected
assert(nt==4,'script assumnes that we have 4 time points')

% time stamps
t_stamps = [data.TimeStamp1 data.TimeStamp2 data.TimeStamp3 data.TimeStamp4];
% time differences
delta_time = [t_stamps(:,3)-t_stamps(:,2), t_stamps(:,4)-t_stamps(:,3), t_stamps(:,4)-t_stamps(:,2)];
% removing time stamp of first sample
t_stamps = t_stamps(:,2:4);
% calculation of LD differences
LD_ratios = [data.LiveRatio1 data.LiveRatio2 data.LiveRatio3 data.LiveRatio4];
delta_LD = [LD_ratios(:,3)-LD_ratios(:,2), LD_ratios(:,4)-LD_ratios(:,3), LD_ratios(:,4)-LD_ratios(:,2)];
% removing first time point
LD_ratios = LD_ratios(:,2:4);
% calculation of LD slopes
LD_slopes = delta_LD./delta_time;

% number of live dead and total cells
live_cells = [data.Live1 data.Live2 data.Live3 data.Live4];
dead_cells = [data.Dead1 data.Dead2 data.Dead3 data.Dead4];
total_cells = live_cells + dead_cells;
total_cells = total_cells(:,2:4);

% storing data for output
data4LDcmp = [LD_slopes, delta_time, LD_ratios, t_stamps, total_cells];
ids = [data.Plate data.Well_Name];
idx = isnan(data4LDcmp);

% % this are the idx for data that is missing only some element
% idx_miss = and(~all(idx,2), any(idx,2));
% ids_miss_data = ids(idx_miss,:);
% if ~isempty(ids_miss_data)
%     warning('some of the wells have missing data, below a list')
%     disp({'Plate:', 'Well'})
%     disp(ids_miss_data)
%     disp('However, now cleaning of the data occurs later on once we know')
%     disp('which variables will be used for the model')
% end

% idx for data that contains at least some information
idx_someData = ~all(idx,2);
ids_no_data = [];
if ~all(idx_someData)
    disp('some of the wells had no data')
    ids_no_data = ids(~idx_someData,:);
%     disp({'Plate:', 'Well'})
%     disp(ids_no_data)
end

ids = ids(idx_someData,:);
data4LDcmp = data4LDcmp(idx_someData,:);
var_names = {'Slope 2-3', 'Slope 3-4', 'Slope 2-4',...
             'DTime 2-3', 'DTime 3-4', 'DTime 2-4',...
             'LDratio 2', 'LDratio 3', 'LDratio 4',...
             'time 2', 'time 3', 'time 4',...
             'n cells 2', 'n cells 3', 'n cells 4'};

end

