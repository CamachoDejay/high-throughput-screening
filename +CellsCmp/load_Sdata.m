function [ data4Scmp, ids, var_names, main_dir, ids_no_data ] = load_Sdata( init_dir )
%LOAD_CONTROL Load all data related to the SHAPE comparison. Now cleaning
%of data occurs later on the code, once we know the variables to be used 
%for the model.
%   Detailed explanation goes here
% path to main folder containing all the contours folders
[main_dir] = uigetdir(init_dir, 'Select the directory that contains all plates');
clear init_dir                             

% Find all folders in the directory
[ PlateFolders ] = LoadTools.subFolderList( main_dir );

% load relevant data
dataLD = [];
dataS  = [];
for i = 1:length(PlateFolders)
    pi_path = [main_dir filesep PlateFolders(i).name filesep 'Contours'...
                                            filesep 'class_live_dead_stats.csv'];
    T = readtable([pi_path]);
    tmp = cell(size(T,1),1);
    tmp(:,1) = {PlateFolders(i).name};
    T.Plate = tmp;
    dataLD = [dataLD; T];
    
    pi_path = [main_dir filesep PlateFolders(i).name filesep 'Contours'...
                                            filesep 'class_multi_4_unk_counts.csv'];
    T = readtable([pi_path]);
    tmp = cell(size(T,1),1);
    tmp(:,1) = {PlateFolders(i).name};
    T.Plate = tmp;
    dataS = [dataS; T];
    
end

% check that all is as expected
nt  = (size(dataLD,2)-3)/6; % number of time points expected
assert(nt==4,'script assumnes that we have 4 time points - problems data LD')

nt  = (size(dataS,2)-3)/7; % number of time points expected
assert(nt==4,'script assumnes that we have 4 time points - problems data Shape')

% load the time stamp
t_stamps = [dataLD.TimeStamp1 dataLD.TimeStamp2 dataLD.TimeStamp3 dataLD.TimeStamp4];
% calculate the delta in time
delta_time = [t_stamps(:,3)-t_stamps(:,2), t_stamps(:,4)-t_stamps(:,3), t_stamps(:,4)-t_stamps(:,2)];
% clear out first time stamp 
t_stamps = t_stamps(:,2:4);
% load LD ratios
LD_ratios = [dataLD.LiveRatio1 dataLD.LiveRatio2 dataLD.LiveRatio3 dataLD.LiveRatio4];
% calculate the deltas of live ratio
delta_LD = [LD_ratios(:,3)-LD_ratios(:,2), LD_ratios(:,4)-LD_ratios(:,3), LD_ratios(:,4)-LD_ratios(:,2)];
% calculate slopes for LD
LD_slopes = delta_LD./delta_time;

% now we calculate the total number of cells
live_cells = [dataLD.Live1 dataLD.Live2 dataLD.Live3 dataLD.Live4];
dead_cells = [dataLD.Dead1 dataLD.Dead2 dataLD.Dead3 dataLD.Dead4];
total_cells = live_cells + dead_cells;

% remember that only live cells are classified by shape
% load number of LONG cells
L_cells = [dataS.Long1 dataS.Long2 dataS.Long3 dataS.Long4];
% load number of NORMAL cells
N_cells = [dataS.Normal1 dataS.Normal2 dataS.Normal3 dataS.Normal4];
% load number of ROUND cells
R_cells = [dataS.Round1 dataS.Round2 dataS.Round3 dataS.Round4];
% load number of SMALL cells
S_cells = [dataS.Small1 dataS.Small2 dataS.Small3 dataS.Small4];
% load number of UNKNOWN cells
U_cells = [dataS.Unknown1 dataS.Unknown2 dataS.Unknown3 dataS.Unknown4];
% load number of multy class cells
M_cells = [dataS.Confused1 dataS.Confused2 dataS.Confused3 dataS.Confused4];

% tmp = L_cells + N_cells + R_cells + S_cells + U_cells - M_cells;
% calculate ratios
LR = L_cells ./ live_cells;
NR = N_cells ./ live_cells;
RR = R_cells ./ live_cells;
SR = S_cells ./ live_cells;
UR = U_cells ./ live_cells;
MR = M_cells ./ live_cells;
% calculate deltas
LR_delta = [LR(:,3)-LR(:,2), LR(:,4)-LR(:,3), LR(:,4)-LR(:,2)];
NR_delta = [NR(:,3)-NR(:,2), NR(:,4)-NR(:,3), NR(:,4)-NR(:,2)];
RR_delta = [RR(:,3)-RR(:,2), RR(:,4)-RR(:,3), RR(:,4)-RR(:,2)];
SR_delta = [SR(:,3)-SR(:,2), SR(:,4)-SR(:,3), SR(:,4)-SR(:,2)];
UR_delta = [UR(:,3)-UR(:,2), UR(:,4)-UR(:,3), UR(:,4)-UR(:,2)];
MR_delta = [MR(:,3)-MR(:,2), MR(:,4)-MR(:,3), MR(:,4)-MR(:,2)];
% calculate the slopes
LR_slopes = LR_delta./delta_time;
NR_slopes = NR_delta./delta_time;
RR_slopes = RR_delta./delta_time;
SR_slopes = SR_delta./delta_time;
UR_slopes = UR_delta./delta_time;
MR_slopes = MR_delta./delta_time;

%% calculate new number based on time point 2
nCellsT2 = [dataLD.Live2 dataLD.Live2 dataLD.Live2 dataLD.Live2];

% calculate ratios
LR2 = L_cells ./ nCellsT2;
NR2 = N_cells ./ nCellsT2;
RR2 = R_cells ./ nCellsT2;
SR2 = S_cells ./ nCellsT2;
UR2 = U_cells ./ nCellsT2;
MR2 = M_cells ./ nCellsT2;
% calculate deltas
LR_delta2 = [LR2(:,3)-LR2(:,2), LR2(:,4)-LR2(:,3), LR2(:,4)-LR2(:,2)];
NR_delta2 = [NR2(:,3)-NR2(:,2), NR2(:,4)-NR2(:,3), NR2(:,4)-NR2(:,2)];
RR_delta2 = [RR2(:,3)-RR2(:,2), RR2(:,4)-RR2(:,3), RR2(:,4)-RR2(:,2)];
SR_delta2 = [SR2(:,3)-SR2(:,2), SR2(:,4)-SR2(:,3), SR2(:,4)-SR2(:,2)];
UR_delta2 = [UR2(:,3)-UR2(:,2), UR2(:,4)-UR2(:,3), UR2(:,4)-UR2(:,2)];
MR_delta2 = [MR2(:,3)-MR2(:,2), MR2(:,4)-MR2(:,3), MR2(:,4)-MR2(:,2)];
% calculate the slopes
LR_slopes2 = LR_delta2./delta_time;
NR_slopes2 = NR_delta2./delta_time;
RR_slopes2 = RR_delta2./delta_time;
SR_slopes2 = SR_delta2./delta_time;
UR_slopes2 = UR_delta2./delta_time;
MR_slopes2 = MR_delta2./delta_time;

%% calculate new parameters of interest for taiyeb
totCellsT2 = total_cells(:,2);
totCellsT2 = repmat(totCellsT2,1,3);
% Longratio_total2 3 = absolute number of long cells at T3/ Total number of cells (alive +dead) at T2
LR_Tot2.val  = L_cells(:,2:4) ./ totCellsT2;
LR_Tot2.name = {'LongRatio 2T2', 'LongRatio 3T2', 'LongRatio 4T2'};
% normalratio_total2 2 = absolute number of normal cells at T2/ Total number of cells (alive +dead) at T2
NR_Tot2.val  = N_cells(:,2:4) ./ totCellsT2;
NR_Tot2.name = {'NormalRatio 2T2', 'NormalRatio 3T2', 'NormalRatio 4T2'};
% roundratio_total2 2 = absolute number of round cells at T2/ Total number of cells (alive +dead) at T2
RR_Tot2.val  = R_cells(:,2:4) ./ totCellsT2;
RR_Tot2.name = {'RoundRatio 2T2', 'RoundRatio 3T2', 'RoundRatio 4T2'};
% smallratio_total2 2 = absolute number of small cells at T2/ Total number of cells (alive +dead) at T2
SR_Tot2.val  = S_cells(:,2:4) ./ totCellsT2;
SR_Tot2.name = {'SmallRatio 2T2', 'SmallRatio 3T2', 'SmallRatio 4T2'};
% unknownratio_total2 4 = absolute number of unknown cells at T4/ Total number of cells (alive +dead) at T2
UR_Tot2.val  = U_cells(:,2:4) ./ totCellsT2;
UR_Tot2.name = {'UnknownRatio 2T2', 'UnknownRatio 3T2', 'UnknownRatio 4T2'};
% multiratio_total2 4 = absolute number of multi cells at T4/ Total number of cells (alive +dead) at T2
MR_Tot2.val  = M_cells(:,2:4) ./ totCellsT2;
MR_Tot2.name = {'MultiRatio 2T2', 'MultiRatio 3T2', 'MultiRatio 4T2'};


%% naming things a bit better
% total count
% total number of long cells
longCellsN.val  = L_cells(:,2:4);
longCellsN.name = {'Long 2', 'Long 3', 'Long 4'};
% total number of normal cells
normalCellsN.val  = N_cells(:,2:4);
normalCellsN.name = {'Normal 2', 'Normal 3', 'Normal 4'};
% total number of round cells
roundCellsN.val  = R_cells(:,2:4);
roundCellsN.name = {'Round 2', 'Round 3', 'Round 4'};
% total number of small cells
smallCellsN.val  = S_cells(:,2:4);
smallCellsN.name = {'Small 2', 'Small 3', 'Small 4'};
% total number of unknown cells
unkCellsN.val  = U_cells(:,2:4);
unkCellsN.name = {'Unknown 2', 'Unknown 3', 'Unknown 4'};
% total number of multiclass cells
mulCellsN.val  = M_cells(:,2:4);
mulCellsN.name = {'Multi 2', 'Multi 3', 'Multi 4'};

% live dead ratio
LDratio.val  = LD_ratios(:,2:4);
LDratio.name = {'LDratio 2', 'LDratio 3', 'LDratio 4'};

% shape ratios slopes - normalized to timepoint 2
% long
LRslopeT2.val  = LR_slopes2;
LRslopeT2.name = {'LongSlope2 2-3', 'LongSlope2 3-4', 'LongSlope2 2-4'};
% normal
NRslopeT2.val  = NR_slopes2;
NRslopeT2.name = {'NormalSlope2 2-3', 'NormalSlope2 3-4', 'NormalSlope2 2-4'};
% round
RRslopeT2.val  = RR_slopes2;
RRslopeT2.name = {'RoundSlope2 2-3', 'RoundSlope2 3-4', 'RoundSlope2 2-4'};
% small
SRslopeT2.val  = SR_slopes2;
SRslopeT2.name = {'SmallSlope2 2-3', 'SmallSlope2 3-4', 'SmallSlope2 2-4'};
% unknown
URslopeT2.val  = UR_slopes2;
URslopeT2.name = {'UnknownSlope2 2-3', 'UnknownSlope2 3-4', 'UnknownSlope2 2-4'};
% multi
MRslopeT2.val  = MR_slopes2;
MRslopeT2.name = {'MultiSlope2 2-3', 'MultiSlope2 3-4', 'MultiSlope2 2-4'};

% ratios relative to time point 2
% long
longRT2.val  = LR2(:,2:4);
longRT2.name = {'LongRatio2 2', 'LongRatio2 3', 'LongRatio2 4'};
% normal
normalRT2.val  = NR2(:,2:4);
normalRT2.name = {'NormalRatio2 2', 'NormalRatio2 3', 'NormalRatio2 4'};
% round
roundRT2.val  = RR2(:,2:4);
roundRT2.name = {'RoundRatio2 2', 'RoundRatio2 3', 'RoundRatio2 4'};
% small
smallRT2.val  = SR2(:,2:4);
smallRT2.name = {'SmallRatio2 2', 'SmallRatio2 3', 'SmallRatio2 4'};
% unknown
unkRT2.val  = UR2(:,2:4);
unkRT2.name = {'UnknownRatio2 2', 'UnknownRatio2 3', 'UnknownRatio2 4'};
% multi
mulRT2.val  = MR2(:,2:4);
mulRT2.name = {'MultiRatio2 2', 'MultiRatio2 3', 'MultiRatio2 4'};

% shape ratios slopes - normalized to each time
% long
LRslope.val  = LR_slopes;
LRslope.name = {'LongSlope 2-3', 'LongSlope 3-4', 'LongSlope 2-4'};
% normal
NRslope.val  = NR_slopes;
NRslope.name = {'NormalSlope 2-3', 'NormalSlope 3-4', 'NormalSlope 2-4'};
% round
RRslope.val  = RR_slopes;
RRslope.name = {'RoundSlope 2-3', 'RoundSlope 3-4', 'RoundSlope 2-4'};
% small
SRslope.val  = SR_slopes;
SRslope.name = {'SmallSlope 2-3', 'SmallSlope 3-4', 'SmallSlope 2-4'};
% unknown
URslope.val  = UR_slopes;
URslope.name = {'UnknownSlope 2-3', 'UnknownSlope 3-4', 'UnknownSlope 2-4'};
% multi
MRslope.val  = MR_slopes;
MRslope.name = {'MultiSlope 2-3', 'MultiSlope 3-4', 'MultiSlope 2-4'};


% ratio
% long
longR.val  = LR(:,2:4);
longR.name = {'LongRatio 2', 'LongRatio 3', 'LongRatio 4'};
% normal
normalR.val  = NR(:,2:4);
normalR.name = {'NormalRatio 2', 'NormalRatio 3', 'NormalRatio 4'};
% round
roundR.val  = RR(:,2:4);
roundR.name = {'RoundRatio 2', 'RoundRatio 3', 'RoundRatio 4'};
% small
smallR.val  = SR(:,2:4);
smallR.name = {'SmallRatio 2', 'SmallRatio 3', 'SmallRatio 4'};
% unknown
unkR.val  = UR(:,2:4);
unkR.name = {'UnknownRatio 2', 'UnknownRatio 3', 'UnknownRatio 4'};
% multi
mulR.val  = MR(:,2:4);
mulR.name = {'MultiRatio 2', 'MultiRatio 3', 'MultiRatio 4'};

% TODO

% time diff
dTimes.val  = delta_time;
dTimes.name = {'DTime 2-3', 'DTime 3-4', 'DTime 2-4'};

% time stamp
tStamp.val  = t_stamps;
tStamp.name = {'time 2', 'time 3', 'time 4'};

% number of live cells
liveCells.val  = live_cells(:,2:4);
liveCells.name = {'live cells 2', 'live cells 3', 'live cells 4'};

% total number of cells
totCells.val  = total_cells(:,2:4);
totCells.name = {'n cells 2', 'n cells 3', 'n cells 4'};

%%
% now we arrange the data and give it as an output
data4Scmp = [longCellsN.val, normalCellsN.val, roundCellsN.val, smallCellsN.val, unkCellsN.val, mulCellsN.val,...
             LDratio.val,...
             LRslopeT2.val, NRslopeT2.val, RRslopeT2.val, SRslopeT2.val, URslopeT2.val, MRslopeT2.val,...
             longRT2.val, normalRT2.val, roundRT2.val, smallRT2.val, unkRT2.val, mulRT2.val,...
             LRslope.val, NRslope.val, RRslope.val, SRslope.val, URslope.val, MRslope.val,...
             longR.val, normalR.val, roundR.val, smallR.val, unkR.val, mulR.val,...
             LR_Tot2.val, NR_Tot2.val, RR_Tot2.val, SR_Tot2.val, UR_Tot2.val, MR_Tot2.val,...
             dTimes.val, tStamp.val,...
             liveCells.val, totCells.val];
         
ids = [dataLD.Plate dataLD.Well_Name];
idx = isnan(data4Scmp);
% idx for data that have no info at all
% idx1 = all(idx,2);
% % % this are the idx for data that is missing only some element
% % idx2 = and(~all(idx,2), any(idx,2));
% % ids_miss_data = ids(idx2,:);
% % if ~isempty(ids_miss_data)
% %     warning('some of the wells have missing data, below a list')
% %     disp({'Plate:', 'Well'})
% %     disp(ids_miss_data)
% %     disp({'However, now cleaning of the data occurs later on once we know',...
% %           'which variables will be used for the model'})
% % end

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
data4Scmp = data4Scmp(idx_someData,:);

var_names = [longCellsN.name, normalCellsN.name, roundCellsN.name, smallCellsN.name, unkCellsN.name, mulCellsN.name,...
             LDratio.name,...
             LRslopeT2.name, NRslopeT2.name, RRslopeT2.name, SRslopeT2.name, URslopeT2.name, MRslopeT2.name,...
             longRT2.name, normalRT2.name, roundRT2.name, smallRT2.name, unkRT2.name, mulRT2.name,...
             LRslope.name, NRslope.name, RRslope.name, SRslope.name, URslope.name, MRslope.name,...
             longR.name, normalR.name, roundR.name, smallR.name, unkR.name, mulR.name,...
             LR_Tot2.name, NR_Tot2.name, RR_Tot2.name, SR_Tot2.name, UR_Tot2.name, MR_Tot2.name,...
             dTimes.name, tStamp.name,...
             liveCells.name, totCells.name];

end

