function [ x, names, id, cpath, time_stamp ] = getValuesFromWell( PlateData, Well, t2look)
% Loads variable values for cells in a well
%   Detailed explanation goes here


well_pointer = PlateData.findWell(Well, t2look);
x = [];
names = [];
id = [];
cpath = [];
time_stamp = [];
    
if isempty(well_pointer)
    % could not find the well
    warning(['Could not find the well folder for well: ' Well '; time: ' num2str(t2look)])
    return
else
    if isempty(well_pointer.contour_path)
        % could not find the cell contrours
        warning(['Could not find the contour folder for well: ' Well '; time: ' num2str(t2look)])
        return
    end        
end

WellData = Core.Data.WellDataSet(well_pointer);
cpath = WellData.info.contour_path;
cpath = cpath(1:end-19);

% im = WellData.images(:,3);
% f_names = WellData.descriptors.names;
x = WellData.descriptors.values;
names = WellData.descriptors.names;

if isempty(x)
    id = [];
    time_stamp = [];
else
    id = WellData.images(:,1);
    time_stamp = WellData.images(:,5);
    time_stamp = mean(cell2mat(time_stamp));
end
% T_unk = array2table(f_vals,...
%     'VariableNames',f_names);


end

