function [dataOut, hdensIds] = removeHighDensity(dataStruc,nc_lim)
%REMOVEHIGHDENSITY Summary of this function goes here
%   Detailed explanation goes here

varName = {'n cells 2'};
nCellData = CellsCmp.getNamedData(dataStruc, varName);
idxHighDensity = nCellData.data > nc_lim;
dataOut.data = dataStruc.data(~idxHighDensity,:);
dataOut.ids  = dataStruc.ids(~idxHighDensity,:);
dataOut.vars = dataStruc.vars;

% ids for the high density wells that have been removed
hdensIds = dataStruc.ids(idxHighDensity,:);
hdensIds(:,3) = num2cell(nCellData.data(idxHighDensity));

if any(idxHighDensity)
    disp('Some of the data had to be removed as it contain too many cells')
%     disp({'Plate:', 'Well', 'nCells'})
%     disp(hdensIds)
end

