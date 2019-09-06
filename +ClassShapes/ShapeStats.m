function [ S, names, Scounts ] = ShapeStats( ypredS, ClassNames, Allowed )
%SHAPESTATS calculates shape stats for a single well
%   Detailed explanation goes here

nClass = length(ClassNames);
% Find allowed confusions, I will keep track of indices
l = size(Allowed,1);
Allowed_idx = zeros(l,nClass,2);
for i =1:l
    A      = Allowed{i,1};
    goesTo = Allowed{i,2};
    [~,tmp,~] = intersect(ClassNames,A, 'stable');
    Allowed_idx(i,tmp,1) = 1;
    Allowed_idx(i,:,2) = strcmp(ClassNames,goesTo);
end

clear A goesTo tmp i

% array that contain the nCells in all classes
Scounts = nan(1,nClass+2);
names   = [ClassNames {'Unknown', 'Confused', 'Bad'}];

% finding cells that do not belong to any class
t    = sum(ypredS,2);
idxU = (t==0);
% counting how many cells do not belong to any class
nUnk = sum(idxU);

% keep track of cells which belong to a class
yClass = ypredS(~idxU,:);

% now we check for cells that belong to more than one class and we see if
% that confusion is allowed or not.
tmp    = sum(yClass,2);
idxC   = find(tmp>1);

% test = yClass(idxC,:)
YY  = [];
YYc = [];
% at the moment I only removed not allowed confusions
for i = idxC(:)'
    y = yClass(i,:);
    
    c_allowed = false;
    for j = 1:size(Allowed_idx,1)
        if all(y == Allowed_idx(j,:,1))
            c_allowed = true;
%            yClass(i,:) = Allowed_idx(j,:,2);          
        end        
    end
    
    if ~c_allowed
        Ytmp = yClass(i,:);
        if isempty(YY)
            YY = [YY; Ytmp];
            YYc = 1;
        else
            t = ismember(YY,Ytmp,'rows');
            if ~any(t)
                YY = [YY; Ytmp];
                YYc(end+1) = 1; 
            else
                YYc(t) = YYc(t)+1;
            end
        end
        
        % here where not allowed confusions are removed
         yClass(i,:) = 0;
    end
end

% % now that we corrected the allowed confusions we check how many wrong
% % asignments remain.
% if the cell still belongs to more than one class then confisuion is
% allowed and we did not fore a class onto it
tmp    = sum(yClass,2);
idxC   = (tmp>1);
nConfused = sum(idxC);
% if the cell does not belong to any class is because it was a not allowed
% confusion
idxC   = (tmp==0);
nConfused2 = sum(idxC);

% create an array taht contains only the known cells
yKno = yClass(~idxC,:);

% total number of cells of known class
nCells = size(yKno,1);

% sum over all classes
Scounts(1,1:nClass) = sum(yKno,1);
Scounts(1,nClass+1) = nUnk;
Scounts(1,nClass+2) = nConfused;
Scounts(1,nClass+3) = nConfused2;

% ratio considering only known cells
S = Scounts(1,1:nClass)./nCells;

% S contains only the ratio of each class.
% Scounts is the number of cells in each class followed by the number of
% initially unkown cells, cells that belong to more than a class but are
% allowed and finally cells that got confused but are not allowed. 

end

