function [ S, names ] = LDstats( ypredLD, modelValid )
%LDSTATS calculates live dead stats for a single well
%   S is an array that contains the Cells [Alive Dead Unknown LiveRatio unkownRatio],
%   note that for live ratio I only consider cells of known status


S = nan(1,5);
names = {'Alive', 'Dead', 'SPE95', 'LiveRatio', 'SPE95Ratio'};

% finding cells that are of unknown status
t    = sum(ypredLD,2);
idxU = find(t==2 | t==0);
% counting how many cells are unknown
nUnk = size(idxU,1);
assert(nUnk==0,'Unexpected behaviour, in our LD all should know their status')

% keep track of only known cells is not needed anymore due to the way
% we clasify the cells, they all know their status
% yKno = ypredLD(t==1,:);

% check the SPE95 value
% modelValid = 0, all is good;
% modelValid = 1, suspicious but ok;
% modelValid = 2, better not to take it into account.
% in general all values larger than 0 are above SP95, all values larger
% than 1 are above SPE99.
SPE95 = modelValid>0;
nSPE95 = sum(SPE95);
        

% total number of cells of known status
nCells = size(ypredLD,1);
% total number of cells alive and dead and storing in S
S(1,1:2) = sum(ypredLD,1);

% live ratio without considering the unkown cells
Lr = S(1)/nCells;

% storing info in S
S(1,3) = nSPE95;
S(1,4) = Lr;
S(1,5) = nSPE95./(nCells+nUnk);

end

