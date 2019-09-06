function [ xld ] = getWantedVars( x, names, wanted_vars )
%GETWANTEDVARS gets the wanted variables from the array x in order to
%calculate the LD status
%   Detailed explanation goes here

[C,inames,~] = intersect(names,wanted_vars, 'stable');
assert(length(C)==length(wanted_vars),'problems with variables')
assert(all(strcmp(C, wanted_vars)),'problems with variables');
xld = x(:,inames);

end

