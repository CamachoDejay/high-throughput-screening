function [ WellList ] = generateWellList
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
l = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H'};
n = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};
WellList = cell(96,1);
c=1;
for li = 1:length(l)
    for ni = 1:length(n)
        WellList{c} = [l{li} n{ni}];        
        c=c+1;
    end
end
clear l n c

end

