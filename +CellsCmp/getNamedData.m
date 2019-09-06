function [out, missDataIds] = getNamedData(dataStruct,varNames)
%GETNAMEDDATA gets data from structure acording to var_names
%   Detailed explanation goes here

[C, idx4m, ~] = intersect(dataStruct.vars, varNames, 'stable');
assert(length(C)==length(varNames),'Not all vars are in the input data')
assert(all(strcmp(C,varNames)), 'Not all vars are in the input data')

data = dataStruct.data;
data = data(:,idx4m);

% cleaning for missing data
idx_missData = any(isnan(data),2);
% storing identifier for data removed due to missing elements
missDataIds = dataStruct.ids(idx_missData,:);
if any(idx_missData)
    disp('Some of the data had to be removed as it did not contain all wanted variables')
%     disp({'Plate:', 'Well'})
%     disp(missDataIds)
end
data = data(~idx_missData,:);
ids  = dataStruct.ids(~idx_missData,:);

% storing output
out.data = data;
out.ids = ids;
out.vars = dataStruct.vars(idx4m);


end

