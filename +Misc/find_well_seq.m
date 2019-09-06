function [ in_fram_prop ] = find_well_seq( FileName, in_fram_prop )
% This function find the well and sequence information from a given
% FileName, and then it stores it on the frame properties structure.
%   Detailed explanation goes here

% find well information
tmp_str = 'Well';
well_ind = strfind(FileName, tmp_str);
assert(~ isempty (well_ind),'Cant find well information')
well_ind = well_ind + length(tmp_str);

tmp_str = '_';
well_end = strfind(FileName, tmp_str);
assert(~ isempty (well_end),'Cant find well information')
well_end = well_end(1) - 1;

Well = FileName(well_ind:well_end);
clear tmp_str well_ind well_end

% find sequence information
tmp_str = 'Seq';
seq_ind = strfind(FileName, tmp_str);
assert(~ isempty (seq_ind),'Cant find sequence information')
seq_ind = seq_ind + length(tmp_str);

tmp_str = '.';
seq_end = strfind(FileName, tmp_str);
assert(~ isempty (seq_end),'Cant find sequence information')
seq_end = seq_end(1) - 1;

Seq = FileName(seq_ind:seq_end);
clear tmp_str seq_ind seq_end

% storing of Sequence and well information
in_fram_prop.Well = Well;
in_fram_prop.Seq = Seq;

end

