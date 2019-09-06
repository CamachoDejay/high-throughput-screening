function [idx_95, idx_99, SPE_S, T2pred, sNameData, missData, highDens]=svd_cmp(sample,model)

% Initialisation
if strcmp(model.stand,'global')
    warning('global standardization');
    standGroup = false;
elseif strcmp(model.stand, 'batch')
    disp('batch standardization')
    standGroup = true;
end
% Model
% u = model.u;
% s = model.s;
v = model.v;
% limits
T2limit95 = model.limits.T295;
T2limit99 = model.limits.T299;

SPElimit95 = model.limits.SPE95;
SPElimit99 = model.limits.SPE99;

% values used for standardization: mean and std of the control
model_mean = model.mean_val;
model_std = model.std_val;

% value used to calculate the T2 of the sample: var_us = var(u*s); where u
% and s come from the SVD model.
var_us = model.var_us;

% removing well with high density
[sNameData, hDensIds] = removeHighDensity(sample,model.max_cells);
highDens = cell2table(hDensIds,'VariableNames',{'Plate' 'Well' 'nCells'});

% loading correct variables from sample
[sNameData, missDataIds] = CellsCmp.getNamedData(sNameData,model.var_names);
sNameData.dir = sample.dir;
missData = cell2table(missDataIds,'VariableNames',{'Plate' 'Well'});



% data to work with
sdata = sNameData.data;
% Standardization of the control and sample
%   centering and scaling: removing mean and dividing by std
if ~standGroup
    % Sample: note that sample is standardized in reference to the control 
    totalMean = repmat(model_mean,size(sdata,1),1);
    totalStd  = repmat(model_std,size(sdata,1),1);
	Sp = (sdata-totalMean)./totalStd;
else
    disp('Doing group-wise centering and scaling')
    ids = sNameData.ids;
    groups = unique(ids(:,1));
    nGroup = length(groups);
    Sp = zeros(size(sdata));
    for i = 1:nGroup
        currentGr = groups{i};
        groupIdx  = strcmp(ids(:,1), currentGr);
        groupData = sdata(groupIdx,:);
        groupSp   = zscore(groupData);
        Sp(groupIdx,:) = groupSp;
    end
    
end

% PREDICTION:
% using the model obtained from the control to predict the sample
%   1) calculating the Hotellings T^2 for the sample and control
t_S=Sp*v;
% t_C=u*s;
T2pred=sum(t_S.^2./repmat(var_us,size(t_S,1),1),2);
%   2) predicting the values of the sample using the model 
Spred = t_S*v';
%   3) square prediction error for the sample
SPE_S=sum((Sp-Spred).^2,2);

% Graphical output
% control charts
figure(3)
semilogy(1:size(Sp,1),SPE_S,'.b','MarkerSize',5)
% plot(1:size(Sp,1),SPE_S,'.b','MarkerSize',5)
hold on
line([0 size(Sp,1)+1],[SPElimit95 SPElimit95],'Color','k','LineStyle','--','LineWidth',2);
line([0 size(Sp,1)+1],[SPElimit99 SPElimit99],'Color','k','LineStyle','-','LineWidth',2);
legend({'Control';'95% limit';'99% limit'},'Location','Best');
axis tight
ax=axis;
axis([0 size(Sp,1)+1 ax(3) ax(4)])
xlabel('sample #ID','FontWeight','bold','FontSize',16)
ylabel('squared prediction error','FontWeight','bold','FontSize',16)
box off
set(gcf,'Color','w')
set(gca,'FontSize',16,'FontWeight','bold')
legend boxoff
hold off

figure(4)
semilogy(1:size(Sp,1),T2pred,'.b','MarkerSize',5)
% plot(1:size(Sp,1),T2pred,'.b','MarkerSize',5)
hold on
line([0 size(Sp,1)+1],[T2limit95 T2limit95],'Color','k','LineStyle','--','LineWidth',2);
line([0 size(Sp,1)+1],[T2limit99 T2limit99],'Color','k','LineStyle','-','LineWidth',2);
legend({'Control';'95% limit';'99% limit'},'Location','Best');
axis tight
ax=axis;
axis([0 size(Sp,1)+1 ax(3) ax(4)])
xlabel('sample #ID','FontWeight','bold','FontSize',16)
ylabel('Hotelling''s T^2','FontWeight','bold','FontSize',16)
box off
set(gcf,'Color','w')
set(gca,'FontSize',16,'FontWeight','bold')
legend boxoff
hold off

% if idx_out = 0 then sample is same as control
% if idx_out = 1 then sample is above SPE limit only
% if idx_out = 2 then sample is above T2 limit only
% if idx_out = 3 then sample is above both limits

idx_SPE = SPE_S > SPElimit95;
idx_T2 = T2pred > T2limit95;
idx_SPET2 = and(idx_SPE, idx_T2);
idx_SPE(idx_SPET2) = false;
idx_T2(idx_SPET2) = false;
idx_95 = zeros(size(idx_SPE));
idx_95(idx_SPE) = 1;
idx_95(idx_T2) = 2;
idx_95(idx_SPET2) = 3;

idx_SPE = SPE_S > SPElimit99;
idx_T2 = T2pred > T2limit99;
idx_SPET2 = and(idx_SPE, idx_T2);
idx_SPE(idx_SPET2) = false;
idx_T2(idx_SPET2) = false;
idx_99 = zeros(size(idx_SPE));
idx_99(idx_SPE) = 1;
idx_99(idx_T2) = 2;
idx_99(idx_SPET2) = 3;


return
