function [ ypreddum, ypred, ind ] = ypred_modelSPE( model, x )
%YPRED_MODELSPE All cells are wither alive or dead but I keep track of
%those that fall outside of expected behaviour
%   Detailed explanation goes here

xs    = (x-repmat(model.Mean.X,size(x,1),1))./repmat(model.Std.X,size(x,1),1);

ypred = xs*model.B;
% ypred = ((x-repmat(model.Mean.X,size(x,1),1))./repmat(model.Std.X,size(x,1),1))*model.B;
ypred = (ypred.*repmat(model.Std.Y,size(ypred,1),1))+repmat(model.Mean.Y,size(ypred,1),1);

[~,ind]=max(ypred,[],2);
% [~,ind]=max(ypred,2);
% ind=ind';

ypreddum = zeros(size(x,1),2);
ypreddum(ind==1,1) = 1;
ypreddum(ind==2,2) = 1;

res = xs-xs*model.Wst*model.P';
SPE = sum(res.^2,2);
ind = zeros(size(x,1),1);
i95 = SPE>model.SPElimit095; 
ind(i95) = 1;
% ypreddum(i95,:) = 0;
i99 = SPE>model.SPElimit099; 
ind(i99) = 2;
% ypreddum(i99,:) = 0;

end




% % xs=(x-repmat(model.Mean.X,size(x,1),1))./repmat(model.Std.X,size(x,1),1);
% % res=xs-xs*model.Wst*model.P';
% % SPE=sum(res.^2,2);
% % ind=zeros(size(x,1),1);
% % ind(SPE>model.SPElimit095)=1;
% % ind(SPE>model.SPElimit099)=2;

