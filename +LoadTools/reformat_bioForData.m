function [ rafadata ] = reformat_bioForData( bio_for_data )
%changes the data coming from bio format into something I like to work with
%   Detailed explanation goes here

x_dim = size(bio_for_data{1,1}{1,1},1);
y_dim = size(bio_for_data{1,1}{1,1},2);
n_fra = size(bio_for_data,1);

field_1     = 'Image';
values_1    = cell(n_fra,1);
frame_info  = cell(n_fra,1);

for i = 1 : size(bio_for_data,1)
values_1{i} = bio_for_data{i,1}{1,1};

allKeys =keySet(bio_for_data{i,2});
allValues = bio_for_data{i,2}.values;
Values = cell(allValues.toArray);
Keys = cell(allKeys.toArray);
% number_of_fields = allValues.size;
h_i = {Keys{:,1};Values{:,1}};
frame_info{i} = h_i';

end

rafadata.movie = struct(field_1,values_1);
rafadata.n_frames = n_fra;
rafadata.x_dim = x_dim;
rafadata.y_dim = y_dim;

end

