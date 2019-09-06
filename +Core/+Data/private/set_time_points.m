function [ contour_paths ] = set_time_points( contour_paths, expected_n_time_points )
%FIND_TIME_POINTS Summary of this function goes here
%   Detailed explanation goes here

Well_rows = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
Well_cols = {'01', '02', '03', '04', '05', '06', '07', '08', '09',...
                                                         '10', '11', '12'};

well_names = {contour_paths.Well};
seq_info   = {contour_paths.Sequence};
contour_paths(end).TimePoint = [];
% Iterate over each row of the 96 well plate (letters)

Remove_ind = [];

for row_i = 1:length(Well_rows)
    % iterate over each col of the 96 well plate (numbers) 
    for col_i = 1:length(Well_cols)
        % name of the cell
        W_name = [Well_rows{row_i} Well_cols{col_i}];
        % find Well
        IndexC = strfind(well_names,W_name);
        Index  = find(not(cellfun('isempty', IndexC)));
        clear IndexC

        % find all time points for that well, determine number of time
        % points
        seq_names     = unique(seq_info(Index));
        time_points_n = length(seq_names);
        seq_values    = cell2mat([cellfun(@str2num,seq_names,'un',0)]);

        if time_points_n == expected_n_time_points
            tmp_vals = seq_values;
            for t = 1:time_points_n
                [~, t_ind] = min(tmp_vals);
                seq_values(2,t_ind) = t;
                tmp_vals(1,t_ind) = inf;
                S_name  = seq_names{seq_values(2,:)==t};
                IndexC2 = strfind(seq_info,S_name);
                Index2   = find(not(cellfun('isempty', IndexC2)));
                contour_paths(Index2).TimePoint = t;

            end
            clear tmp_vals
            
        else
            Remove_ind = [Remove_ind Index];

        end

    end
end

contour_paths(Remove_ind) = [];
            
end

